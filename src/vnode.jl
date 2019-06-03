struct VNode{T}
    tag::T
    children::Vector{Any}
    attrs::Dict{Symbol, Any}
    function VNode(tag::T, args...; kwargs...) where {T}
        new{T}(tag, args, Dict{Symbol, Any}(kwargs))
    end
end


