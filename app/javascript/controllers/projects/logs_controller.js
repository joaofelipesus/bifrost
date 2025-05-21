import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="projects--logs"
export default class extends Controller {
  static targets = [
    "projectId",  // project id used on event route
    "logTail",    // div with displayed logs
    "tailLogsButton", "stopTailLogsButton", "clearLogsButton" // iteration buttons
  ]

  connect() { }

  tailLogs () {
    this.eventSource = new EventSource(`${this._projectId()}/logs`)

    this.eventSource.onmessage = function(event) {
      // Handle the incoming data
      const logTail = document.getElementById('log-tail');

      if (logTail) {
        const newLog = document.createElement('div');
        newLog.textContent = JSON.parse(event.data).message;
        logTail.appendChild(newLog);
        logTail.scrollTop = logTail.scrollHeight; // Scroll to the bottom
      }
    }

    this.eventSource.onerror = function(error) {
      console.error('EventSource failed:', error)
      // Handle the error
    }

    this._activateFetchingLoggsButton()
    this._enableStopFollowLogs()
  }

  stopTailLogs() {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;

      // return buttons to original status
      this._resetFollowLogsButton()
      this._resetStopLogsButton()
    }
  }

  clearLogs () {
    while (this.logTailTarget.firstChild) {
      this.logTailTarget.removeChild(this.logTailTarget.firstChild);
    }
  }

  _projectId () {
    return this.tailLogsButtonTarget.dataset.projectId
  }

  _activateFetchingLoggsButton () {
    this.tailLogsButtonTarget.classList.remove('btn-sm-success')
    this.tailLogsButtonTarget.classList.add('btn-sm-outline-success')
    this.tailLogsButtonTarget.classList.add('cursor-not-allowed')
    this.tailLogsButtonTarget.textContent = 'Fetching logs'
  }

  _enableStopFollowLogs () {
    this.stopTailLogsButtonTarget.classList.remove('btn-sm-outline-danger')
    this.stopTailLogsButtonTarget.classList.remove('cursor-not-allowed')
    this.stopTailLogsButtonTarget.classList.add('btn-sm-danger')
  }

  _resetFollowLogsButton () {
    this.tailLogsButtonTarget.classList.add('btn-sm-success')
    this.tailLogsButtonTarget.classList.remove('btn-sm-outline-success')
    this.tailLogsButtonTarget.classList.remove('cursor-not-allowed')
    this.tailLogsButtonTarget.textContent = 'Follow logs'
  }

  _resetStopLogsButton () {
    this.stopTailLogsButtonTarget.classList.add('btn-sm-outline-danger')
    this.stopTailLogsButtonTarget.classList.add('cursor-not-allowed')
    this.stopTailLogsButtonTarget.classList.remove('btn-sm-danger')
  }
}
