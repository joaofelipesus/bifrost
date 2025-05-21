import consumer from "channels/consumer"

consumer.subscriptions.create("ProjectContainerLogsChannel", {
  connected() {
    // console.log('connected')
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // console.log(data)
  }
});
