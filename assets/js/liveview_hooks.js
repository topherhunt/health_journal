let Hooks = {}

Hooks.Autofocus = {
  mounted() {
    this.el.focus()
    this.el.selectionStart = 9999;
    // this.el.selectionEnd = 9999;
  }
}

Hooks.ShowNotification = {
  mounted() {
    let text = this.el.dataset.text
    console.log("Issuing notification.")

    if (Notification.permission === "granted") {
      let opts = {body: text, requireInteraction: true}
      new Notification("Update your Health Journal", opts);
    }
  }
}

export default Hooks
