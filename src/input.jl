function input(;
               value,
               type = Observable("text"),
               disabled = Observable(false),
               style = Observable(""),
               class = Observable("")
              )

    template = js"""
    {
        view: function (vnode) {
            return m("input", {
                type: data.type,
                value: data.value,
                disabled: data.disabled,
                style: data.style,
                class: data.class,
                oninput: function () {data.value = this.value;}
            });
        }
    }
    """
    attrs = (value = value, type = type, disabled = disabled, style = style, class = class)
    return MithrilComponent{:input, eltype(value)}(template, attrs)
end
