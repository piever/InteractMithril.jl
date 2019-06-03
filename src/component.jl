struct MithrilComponent{T, S}<:AbstractWidget{T, S}
    template::JSString
    data::NamedTuple
end

function (m::MithrilComponent{T, S})(; kwargs...) where {T, S}
    MithrilComponent{T, S}(m.template, merge(m.data, values(kwargs)))
end

Widgets.render(m::MithrilComponent) = mithril(m.template, m.data)

Observables.observe(m::MithrilComponent) = m.data.value
