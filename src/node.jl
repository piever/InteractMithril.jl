template(x) = x
consumed_template(x) = template(x)

# TODO: avoid allocating an insame amount of strings!
consumed_template(n::Node) = js"m($(template(n)))"
function template(n::Node)
    properties = props(n)
    attributes = Dict{Symbol, Any}()
    for (key, val) in  get(properties, :attributes, Dict())
        attributes[Symbol(key)] = val
    end

    style = get(properties, :style, nothing)
    style === nothing || get!(attributes, :style, style)
    className = get(properties, :className, nothing)
    className === nothing || get!(attributes, :class, className)

    for (key, val) in get(properties, :events, Dict{Symbol, Any}())
        newkey = Symbol(:on, key)
        get!(attributes, newkey, val)
    end
    for (key, val) in properties
        (key in (:style, :className, :events, :attributes)) || get!(attributes, key, val)
    end

    tag = instanceof(n).tag
    templated_children = map(consumed_template, children(n))

    return js"""
    {
        view: function () {
            var attrs = $attributes;
            return m($tag, attrs, ($templated_children)); 
        }
    }
    """
end

function MithrilComponent{T}(n::Node, data::NamedTuple = NamedTuple()) where {T}
    MithrilComponent{T}(template(n), data)
end
