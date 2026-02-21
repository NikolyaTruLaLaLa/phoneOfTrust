import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { token: String }

  connect() {
    this.typingTimer = null
    this.inputTarget.addEventListener("input", this.debouncedSend.bind(this))
  }

  disconnect() {
    clearTimeout(this.typingTimer)
  }

  debouncedSend() {
    clearTimeout(this.typingTimer)
    this.typingTimer = setTimeout(() => {
      this.sendTyping(this.inputTarget.value)
    }, 20)
  }

  sendTyping(text) {
    fetch("/send_typing", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({
        text: {
          visitors_token: this.tokenValue,
          content: text
        }
      })
    })
  }
}