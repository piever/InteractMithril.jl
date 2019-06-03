struct MithrilComponent{T, S}<:AbstractWidget{T, S}
    template::JSString
    data::NamedTuple
    observe::AbstractObservable{S}
    function MithrilComponent{T}(template::JSString, data::NamedTuple, observe::AbstractObservable{S}) where {T, S}
        new{T, S}(template, data, observe)
    end
end

MithrilComponent{T}(template, data) where {T} = MithrilComponent{T}(template, data, get(data, :value, Observable(nothing))) 

template(m::MithrilComponent) = getfield(m, :template)
data(m::MithrilComponent) = getfield(m, :data)

Widgets.render(m::MithrilComponent) = mithril(template(m), data(m))

Observables.observe(m::MithrilComponent) = Observables.observe(getfield(m, :observe))

Base.propertynames(m::MithrilComponent) = propertynames(data(m))
Base.getproperty(m::MithrilComponent, s::Symbol) = getproperty(data(m), s)[]
function Base.setproperty!(m::MithrilComponent, s::Symbol, val)
    setindex!(getproperty(data(m), s), val)
end

