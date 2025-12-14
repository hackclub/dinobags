import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["logs", "toggle", "input", "suggestions"]
  static values = { 
    lines: { type: Number, default: 100 },
    interval: { type: Number, default: 2000 },
    completionsUrl: { type: String, default: "/admin/tools/console/completions" }
  }

  connect() {
    this.consumer = null
    this.subscription = null
    this.refreshTimer = null
    this.selectedIndex = -1
    this.suggestions = []
  }

  disconnect() {
    this.stopRefresh()
  }

  toggleLive(event) {
    if (event.target.checked) {
      this.startRefresh()
    } else {
      this.stopRefresh()
    }
  }

  startRefresh() {
    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create(
      { channel: "LogsChannel" },
      {
        connected: () => {
          this.requestLogs()
          this.refreshTimer = setInterval(() => this.requestLogs(), this.intervalValue)
        },
        disconnected: () => {
          this.stopTimer()
        },
        received: (data) => {
          if (data.logs && this.hasLogsTarget) {
            this.logsTarget.textContent = data.logs
            this.logsTarget.scrollTop = this.logsTarget.scrollHeight
          }
        }
      }
    )
  }

  requestLogs() {
    if (this.subscription) {
      this.subscription.perform("request_logs", { lines: this.linesValue })
    }
  }

  stopTimer() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
      this.refreshTimer = null
    }
  }

  stopRefresh() {
    this.stopTimer()
    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
    }
    if (this.consumer) {
      this.consumer.disconnect()
      this.consumer = null
    }
  }

  async onInput(event) {
    const query = event.target.value
    if (query.length < 1) {
      this.hideSuggestions()
      return
    }

    try {
      const response = await fetch(`${this.completionsUrlValue}?query=${encodeURIComponent(query)}`)
      if (response.ok) {
        this.suggestions = await response.json()
        this.showSuggestions()
      }
    } catch (error) {
      console.error("Autocomplete error:", error)
    }
  }

  onKeydown(event) {
    if (!this.hasSuggestionsTarget || this.suggestions.length === 0) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, this.suggestions.length - 1)
        this.highlightSuggestion()
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.highlightSuggestion()
        break
      case "Tab":
        if (this.suggestions.length > 0) {
          event.preventDefault()
          const index = this.selectedIndex >= 0 ? this.selectedIndex : 0
          this.selectSuggestion(this.suggestions[index])
        }
        break
      case "Escape":
        this.hideSuggestions()
        break
    }
  }

  showSuggestions() {
    if (!this.hasSuggestionsTarget || this.suggestions.length === 0) {
      this.hideSuggestions()
      return
    }

    this.selectedIndex = -1
    this.suggestionsTarget.innerHTML = this.suggestions
      .map((s, i) => `<div class="suggestion" data-index="${i}" data-action="click->console#clickSuggestion">${s}</div>`)
      .join("")
    this.suggestionsTarget.style.display = "block"
  }

  hideSuggestions() {
    if (this.hasSuggestionsTarget) {
      this.suggestionsTarget.style.display = "none"
      this.suggestionsTarget.innerHTML = ""
    }
    this.selectedIndex = -1
  }

  highlightSuggestion() {
    if (!this.hasSuggestionsTarget) return
    const items = this.suggestionsTarget.querySelectorAll(".suggestion")
    items.forEach((item, i) => {
      item.classList.toggle("selected", i === this.selectedIndex)
    })
  }

  clickSuggestion(event) {
    const index = parseInt(event.target.dataset.index)
    this.selectSuggestion(this.suggestions[index])
  }

  selectSuggestion(value) {
    if (this.hasInputTarget) {
      this.inputTarget.value = value
      this.inputTarget.focus()
    }
    this.hideSuggestions()
  }
}
