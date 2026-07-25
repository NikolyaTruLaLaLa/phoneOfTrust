import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { token: String }

  connect() {
    this.typingTimer = null
    this.boundDebouncedSend = this.debouncedSend.bind(this)
    this.boundHandleKeydown = this.handleKeydownEnter.bind(this)
    this.inputTarget.addEventListener("input", this.boundDebouncedSend)
    this.inputTarget.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    clearTimeout(this.typingTimer)
    this.inputTarget.removeEventListener("input", this.boundDebouncedSend)
    this.inputTarget.removeEventListener("keydown", this.boundHandleKeydown)
  }

  debouncedSend() {
    clearTimeout(this.typingTimer)
    this.typingTimer = setTimeout(() => {
      this.sendTyping(this.inputTarget.value)
    }, 20)
  }

  handleKeydownEnter(event){
    if (event.key == "Enter"){
      event.preventDefault()
      clearTimeout(this.typingTimer)
      this.sendTyping("")
    }
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