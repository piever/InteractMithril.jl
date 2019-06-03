struct MithrilComponent{T, S}<:AbstractWidget{T, S}
    template::JSString
    data::NamedTuple
end

template(m::MithrilComponent) = getfield(m ,:template)
data(m::MithrilComponent) = getfield(m ,:data)

function (m::MithrilComponent{T, S})(; kwargs...) where {T, S}
    MithrilComponent{T, S}(template(m), merge(data(m), values(kwargs)))
end

Widgets.render(m::MithrilComponent) = mithril(template(m), data(m))

Observables.observe(m::MithrilComponent) = data(m).value

Base.getproperty(m::MithrilComponent, s::Symbol) = getproperty(data(m), s)[]
function Base.setproperty!(m::MithrilComponent, s::Symbol, val)
    setindex!(getproperty(data(m), s), val)
end

