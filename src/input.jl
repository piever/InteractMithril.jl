const default_input_attrs = (
                             value = "",
                             type = "text",
                             disabled = false,
                             style = "",
                             class = "input",
                             changes = 0
                            )

function input(; kwargs...)

    datavals = merge(default_input_attrs, values(kwargs))
    data = map(to_observable, datavals)

    attrs = Dict(key => js"data[$key]" for key in keys(data))
    attrs[:oninput] = js"function () {data.value = this.value;}"
    attrs[:onchange] = js"function () {data.changes = data.changes + 1;}"

    template = js"{view: function (vnode) {return m('input', $attrs);}}"

    return MithrilComponent{:input}(template, data)
end

_parse(::Type{S}, x) where{S} = parse(S, x)
function _parse(::Type{Dates.Time}, x)
    segments = split(x, ':')
    length(segments) >= 2 && all(!isempty, segments) || return nothing
    h, m = parse.(Int, segments)
    Dates.Time(h, m)
end

function _string(x::Dates.Time)
    h = Dates.hour(x)
    m = Dates.minute(x)
    string(lpad(h, 2, "0"), ":", lpad(m, 2, "0"))
end
_string(x::Dates.Date) = string(x)
_string(x::Colorant) = "#"*hex(x)
_string(::Nothing) = ""

for (func, typ, type) in [(:timepicker, :(Dates.Time), "time"), (:datepicker, :(Dates.Date), "date"), (:colorpicker, Colorant, "color")]
    @eval function $func(; value = nothing, type = "", kwargs...)
        (value isa AbstractObservable) || (value = Observable{Union{$typ, Nothing}}(value))
        f = _string
        g = t -> _parse($typ, t)
        string_value = Observable{String}(f(value[]))
        ObservablePair(value, string_value, f = f, g = g)
        m = input(; value = string_value, type = $type, kwargs...)
        MithrilComponent{$(Expr(:quote, func))}(template(m), data(m), value)
    end
end
