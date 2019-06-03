module InteractMithril

using WebIO: Scope, JSString, @js_str, onimport, setobservable!, onjs, WebIO
using Widgets: AbstractWidget, Widgets
using Observables: Observable, Observables

include("mithril.jl")
include("component.jl")
include("input.jl")

end # module
