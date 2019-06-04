module InteractMithril

using WebIO: Scope, JSString, @js_str, onimport, setobservable!, onjs, WebIO
using Widgets: AbstractWidget, Widgets
using Observables: on, Observable, AbstractObservable, ObservablePair, Observables
using Dates, Base64
using Colors: Colorant, hex

include("mithril.jl")
include("component.jl")
include("input.jl")
include("slider.jl")

end # module
