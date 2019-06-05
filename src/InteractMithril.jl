module InteractMithril

using WebIO: Node, instanceof, props, children, Scope, JSString, @js_str, onimport,
             setobservable!, onjs, WebIO
using Widgets: AbstractWidget, Widget, Widgets
using Observables: on, Observable, AbstractObservable, ObservablePair, Observables
using Dates
using Colors: Colorant, hex

import JSON

export mithril, MithrilComponent

include("component.jl")
include("input.jl")
include("slider.jl")
include("optioninput.jl")

end # module
