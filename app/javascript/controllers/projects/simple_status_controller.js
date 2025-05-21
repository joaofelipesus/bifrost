import { Controller } from "@hotwired/stimulus"
import { FetchRequest } from '@rails/request.js'

// NOTE: make pooling to display if a project is up or not
// Connects to data-controller="projects--simple-status"
export default class extends Controller {
  static targets = [
    "simpleStatusSection",   // project reference
    "upLabel", "downLabel",  // label with app current status
  ]

  async connect() {
    this.downLabelTarget.classList.add('hidden')
    this.upLabelTarget.classList.add('hidden')

    this.poolingInterval = setInterval(() => {
      this.poolingProjectTatus()
    }, 1000)
  }

  async poolingProjectTatus () {
    const projectId = this.simpleStatusSectionTarget.dataset.projectId
    const request = new FetchRequest('get', `/projects/${projectId}/status`)
    const response = await request.perform()
    if (response.ok) {
      const data = await response.json
      if (data.status == "UP") {
        this.downLabelTarget.classList.add('hidden')
        this.upLabelTarget.classList.remove('hidden')
      } else {
        this.upLabelTarget.classList.add('hidden')
        this.downLabelTarget.classList.remove('hidden')
      }
    }
  }
}
