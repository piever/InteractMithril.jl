to_observable(o::Observable) = o
to_observable(o::AbstractObservable) = Observables.observe(o)
to_observable(o) = Observable(o)

function mithril(template::JSString, data)
    s = Scope(imports =
        [
         "https://unpkg.com/mithril@next/mithril.js",
         "https://www.gitcdn.xyz/repo/piever/InteractResources/v0.4.0/bulma/main_confined.min.css"
        ]
    )
    datanames = String[]
    for (key, val) in pairs(data)
        skey = string(key)
        setobservable!(s, skey, to_observable(val))
        push!(datanames, skey)
        onjs(s[skey], js"function (value) {this.m.redraw()}")
    end
    onimport(s, js"""
    function (m) {
        this.m = m;
        function addProperty(obj, name) {
            Object.defineProperty(obj, name, {
                get: function() {return _webIOScope.getObservableValue(name);},
                set: function(val) {_webIOScope.setObservableValue(name, val);}
            });
        }
        function Data(names) {
            var key;
            for (key of names) {addProperty(this, key);}
        }
        var data = new Data($datanames);
        var template = $template;
        m.mount(_webIOScope.dom, {view: function () {return m("div.interact-widget", m(template));}})
    }
    """)
    return s
end
