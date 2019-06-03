function input(; value, type = Observable("text"), disabled = Observable(false))
    template = js"""
    {
        view: function (vnode) {
            return m("input", {
                type: data.type,
                value: data.value,
                disabled: data.disabled,
                oninput: function () {data.value = this.value;}
            });
        }
    }
    """
    attrs = (value = value, type = type, disabled = disabled)
    return MithrilComponent{:input, eltype(value)}(template, attrs)
end
