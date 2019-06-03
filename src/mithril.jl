function mithril(template::JSString, data)
    s = Scope(imports =
        ["https://unpkg.com/mithril@next/mithril.js"]
    )
    datanames = String[]
    for (key, val) in pairs(data)
        skey = string(key)
        setobservable!(s, skey, val)
        push!(datanames, skey)
        onjs(s[skey], js"function (val) {this.m.redraw()}")
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
        m.mount(_webIOScope.dom, {view: function () {return m(template);}})
    }
    """)
    return s
end
