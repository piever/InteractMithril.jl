# InteractMithril

An experimental attempt to rewrite Interact based on the [Mithril](https://mithril.js.org/) framework. The idea is to generate Mithril components from Julia, where the logic is managed via some `Observables` that sync relevant variables between JavaScript and Julia and the fronted Mithril takes care of keeping the rendered app in sync.

## Examples

```julia
using InteractMithril
ui = InteractMithril.slider(class = "is-primary")
```

is the usual slider object. `ui.class = "is-danger"` changes the class on the rendered object. Similary, `ui.min`, `ui.max`, `ui.step` et cetera can all be changed in real time.

### Input

`InteractMithril.input` wraps inputs in HTML, for example:

```julia
ui = InteractMithril.input(type="text", value = "")
```

now `ui.type = "number"` turns it into a spinbox, and `ui.disabled = true` disables it.


## Creating components from nodes

Components can be created that refer the data via a global `data` variable, for example:

```julia
using WebIO
n = node(:div, node(:input, checked = js"data.checked", attributes=Dict("type" => "checkbox")), node(:label, "label", style=Dict("color" => js"data.color")));
ui = MithrilComponent(n, (checked = true, color = "red"))
```

and now `ui.checked = false` will uncheck the checkbox and `ui.color = "blue"` will recolor the text. Note however that here user input could get the checkbox and the observable out of sync (whereas in the `input` example there are event handlers to ensure the value stays synced).

## TODO

- Optimize string generation
- Figure out correct abstractions and nesting
- See if something like https://mithril.js.org/integrating-libs.html#nouislider-example can be used to embed a WebIO `Scope`


