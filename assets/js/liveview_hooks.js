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
      new Notification(text);
    } else if (Notification.permission !== "denied") {
      Notification.requestPermission().then(function(perm) {
        if (perm === "granted") {
          new Notification(text);
        }
      })
    }
  }
}

export default Hooks
