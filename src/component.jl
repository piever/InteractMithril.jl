const JSONContext = JSON.Writer.StructuralContext
const JSONSerialization = JSON.Serializations.CommonSerialization

struct MithrilSerialization <: JSONSerialization end

JSON.show_json(io::JSONContext, ::MithrilSerialization, x::JSString) = print(io, x)

printjs(io::IO, val) = JSON.show_json(io, MithrilSerialization(), val)

print_vnode(io::IO, x) = printjs(io, x) 
print_vnode(io::IO, f::Function) = f(io)
print_vnode(io::IO, s::JSString) = print(io, s)

function print_vnode(io::IO, n::Node)
    print(io, "m(")
    printjs(io, instanceof(n).tag)
    print(io, ", {")
    properties = props(n)
    attributes = get(properties, :attributes, Dict())
    for (key, val) in Iterators.flatten([attributes, properties])
        key in (:attributes, :events) && continue
        print(io, key, ": ")
        printjs(io, val)
        print(io, ",")
    end
    for (key, val) in get(properties, :events, Dict())
        print(io, "on", key, ": ")
        printjs(io, val)
        print(io, ", ")
    end
    print(io, "}")
    print(io, ", [")
    for child in children(n)
        print_vnode(io, child)
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

Base.propertynames(m::MithrilComponent) = propertynames(data(m))
Base.getproperty(m::MithrilComponent, s::Symbol) = getproperty(data(m), s)[]
function Base.setproperty!(m::MithrilComponent, s::Symbol, val)
    setindex!(getproperty(data(m), s), val)
end

WebIO.render(m::MithrilComponent) = WebIO.render(Scope(m))

function WebIO.Scope(m::MithrilComponent)
    mithril(data(m)) do io 
        print_vnode(io, template(m))
    end
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
WebIO.render(mw::MithrilWidget) = WebIO.render(component(mw))
