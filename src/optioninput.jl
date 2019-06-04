function checkboxes(; options, value, multiple = true)
    if multiple
        update = js"""
        var vec = data.value;
        var val = option.value;
        var idx = vec.indexOf(val);
        idx >= 0 ? vec.splice(idx, 1) : vec.push(val);
        data.value = vec;
        """
        check = js"data.value.indexOf(option.value) >= 0"
    else 
        update = js"data.value = option.value;"
        check = js"option.value == data.value"
    end
    template = js"""
    {
        view: function () {
            var list = data.options;
            console.log(list);
            var children = list.map(function (option) {
                return m("div.field", [
                    m("input", {
                        type: "checkbox",
                        value: option.value,
                        checked: $check,
                        onchange: function (e) {
                            console.log('updating');
                            $update
                        }}),
                    m("label", option.name)
                ])
            })
            return m("div", children);
        }
    }
    """
    MithrilComponent{:checkboxes}(template, (options = options, value = value))
end 
