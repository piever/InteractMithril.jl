const default_attrs = (disabled = false, style = "", class = "", changes = 0)
const default_input_attrs = merge(default_attrs, (value = "", type = "text"))

function input(;
               oninput = js"function () {data.value = this.value;}",
               onchange = js"function () {data.changes = data.changes + 1;}", 
               selector = "input.input",
               kwargs...)

    datavals = merge(default_input_attrs, values(kwargs))
    data = map(to_observable, datavals)

    attrs = Dict(key => js"data[$key]" for key in keys(data))
    attrs[:oninput] = oninput
    attrs[:onchange] = onchange
    template = js"m($selector, $attrs)"

    return MithrilWidget{:input}(MithrilComponent(template, data), data.value)
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
_string(x) = string(x)
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
        MithrilWidget{$(Expr(:quote, func))}(component(m), value)
    end
end

function spinbox(; value = Observable{Union{Int, Nothing}}(nothing), type = "", kwargs...)
    if !isa(value, AbstractObservable)
        T = value === nothing ? Union{Int, Nothing} : Union{typeof(value), Nothing}
        value = Observable{T}(value)
    end
    jsvalue = Observable{Any}(value[])
    m = input(; value = jsvalue, type = "number", kwargs...)

    excluded = Function[]

    push!(excluded, on(value) do val
        str = jsvalue[]
        if !isa(str, AbstractString) || tryparse(Float64, str) != val
            jsvalue[notify = !in(excluded)] = val
        end
    end)

    push!(excluded, on(jsvalue) do val
        if val isa AbstractString
            res = tryparse(Float64, val)
            res !== nothing && (value[notify = !in(excluded)] = res)
        end
    end)
    
    MithrilWidget{:spinbox}(component(m), value)
end

const default_button_attrs = merge(default_attrs, (changes = 0,))

function button(children...; kwargs...)
    datavals = merge(default_button_attrs, values(kwargs))
    data = map(to_observable, datavals)

    attrs = Dict(key => js"data[$key]" for key in keys(data))
    attrs[:onclick] = js"function () {data.changes = data.changes + 1;}"

    template = js"m('button.button', $attrs, $children)"
    MithrilWidget{:button}(MithrilComponent(template, data), data.changes)
end
