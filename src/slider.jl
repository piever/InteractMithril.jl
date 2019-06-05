function medianvalue(min, max, step)
    rg = min:step:max
    rg[div(length(rg), 2)+1]
end

function slider(; min = 0, max = 100, step = 1, value = nothing, type = "", kwargs...)
    (min isa AbstractObservable) || (min = Observable(min))
    (max isa AbstractObservable) || (max = Observable(max))
    (step isa AbstractObservable) || (step = Observable(step))
    value === nothing && (value = medianvalue(min[], max[], step[]))
    (value isa AbstractObservable) || (value = Observable(value))
    
    oninput = js"function() {data.value = parseFloat(this.value);}"
    m = input(; min = min, max = max, step = step, value = value, type = "range",
              oninput = oninput, selector = "input.slider", kwargs...)
    MithrilWidget{:slider}(component(m), value)
end
