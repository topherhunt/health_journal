let Hooks = {}

Hooks.Autofocus = {
  mounted() {
    this.el.focus()
    this.el.selectionStart = 9999;
    // this.el.selectionEnd = 9999;
  }
}

export default Hooks
