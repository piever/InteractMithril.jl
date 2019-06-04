module InteractMithril

using WebIO: Node, instanceof, props, children, Scope, JSString, @js_str, onimport,
             setobservable!, onjs, WebIO
using Widgets: AbstractWidget, Widgets
using Observables: on, Observable, AbstractObservable, ObservablePair, Observables
using Dates
using Colors: Colorant, hex

export mithril, MithrilComponent

include("mithril.jl")
include("component.jl")
include("node.jl")
include("input.jl")
include("slider.jl")
include("optioninput.jl")

end # module
