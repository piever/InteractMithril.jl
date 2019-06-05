to_observable(o::Observable) = o
to_observable(o::AbstractObservable) = Observables.observe(o)
to_observable(o) = Observable(o)

const JSONContext = JSON.Writer.StructuralContext
const JSONSerialization = JSON.Serializations.CommonSerialization

struct MithrilSerialization <: JSONSerialization end

JSON.show_json(io::JSONContext, ::MithrilSerialization, x::JSString) = print(io, x)

printjs(io::IO, val) = JSON.show_json(io, MithrilSerialization(), val)

print_component(io::IO, x) = printjs(io, x) 
print_component(io::IO, f::Function) = f(io)
print_component(io::IO, s::JSString) = print(io, s)

function print_component(io::IO, n::Node)
    print(io, "m(")
    printjs(io, instanceof(n).tag)
    print(io, ", {")
    properties = props(n)
    attributes = get(properties, :attributes, Dict())
    events = get(properties, :events, Dict())
    pairs = Iterators.flatten([attributes, properties, ("on$key" => val for (key, val) in events)])
    for (key, val) in pairs
        key in (:attributes, :events) && continue
        printjs(io, key)
        print(io, ": ")
        printjs(io, val)
        print(io, ",")
    end
    print(io, "}")
    print(io, ", [")
    for child in children(n)
        print_component(io, child)
        print(io, ", ")
    end
    print(io, "])")
end

struct MithrilComponent{T}
    template::T
    data::NamedTuple
    function MithrilComponent(template::T, data::NamedTuple) where {T}
        new{T}(template, map(to_observable, data))
    end
end

template(m::MithrilComponent) = getfield(m, :template)
data(m::MithrilComponent) = getfield(m, :data)
is_vnode(m::MithrilComponent) = getfield(m, :is_vnode)

Base.propertynames(m::MithrilComponent) = propertynames(data(m))
Base.getproperty(m::MithrilComponent, s::Symbol) = getproperty(data(m), s)[]
function Base.setproperty!(m::MithrilComponent, s::Symbol, val)
    setindex!(getproperty(data(m), s), val)
end

WebIO.render(m::MithrilComponent) = WebIO.render(Scope(m))

function print_component(io::IO, m::MithrilComponent{<:Node})
    print(io, "{view: () => ")
    print_component(io, template(m))
    print(io, "}")
end

print_component(io::IO, m::MithrilComponent) = print_component(io, template(m))

function WebIO.Scope(m::MithrilComponent)
    s = Scope(imports =
        [
         "https://unpkg.com/mithril@next/mithril.js",
         "https://www.gitcdn.xyz/repo/piever/InteractResources/v0.4.0/bulma/main_confined.min.css"
        ]
    )
    datanames = String[]
    for (key, val) in pairs(data(m))
        skey = string(key)
        setobservable!(s, skey, to_observable(val))
        push!(datanames, skey)
        onjs(s[skey], js"function (value) {this.m.redraw()}")
    end
    io = IOBuffer()
    print(io, js"""
    function (m) {
        this.m = m;
        function addProperty(obj, name) {
            Object.defineProperty(obj, name, {
                get: function() {return _webIOScope.getObservableValue(name);},
                set: function(val) {_webIOScope.setObservableValue(name, val);}
            });
        }
        function Data(names) {
            var key;
            for (key of names) {addProperty(this, key);}
        }
        var data = new Data($datanames);
    """)
    print(io, "var template = ")
    print_component(io, m)
    print(io, ";\n")
    print(io, "m.mount(_webIOScope.dom, {view: function () {return m('div.interact-widget', m(template));}});\n}")
    onimport(s, JSString(String(take!(io))))
    return s
end

struct MithrilWidget{T, S}<:AbstractWidget{T, S}
    m::MithrilComponent
    observe::AbstractObservable{S}
    function MithrilWidget{T}(m::MithrilComponent, observe::AbstractObservable{S}) where {T, S}
        new{T, S}(m, observe)
    end
end

component(mw::MithrilWidget) = getfield(mw, 1)
Observables.observe(mw::MithrilWidget) = getfield(mw, 2)

Base.propertynames(mw::MithrilWidget) = propertynames(component(mw))
Base.getproperty(mw::MithrilWidget, s::Symbol) = getproperty(component(mw), s)
Base.setproperty!(mw::MithrilWidget, s::Symbol, val) = setproperty!(component(mw), s, val)
Widgets.render(mw::MithrilWidget) = WebIO.render(component(mw))
