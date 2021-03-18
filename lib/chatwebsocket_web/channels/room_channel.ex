defmodule ChatwebsocketWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:" <> id, _message, socket) do
    send(self(), {:after_join, %{id: id}})
    {:ok, socket}
  end

  def handle_info({:after_join, msg}, socket) do
    channel = msg.id

    if !Chatwebsocket.DatabaseConnection.check_channel_existing(channel) do
      Chatwebsocket.DatabaseConnection.insert_new_channel(channel)
    end

    messages = Chatwebsocket.DatabaseConnection.select_channel_messages(channel)

    push(socket, "room_messages", %{
      body: messages
    })

    {:noreply, socket}
  end

  def handle_info({:wrong_room, _msg}, socket) do
    push(socket, "wrong_room", %{
      body: %{
        error: "Es gibt gerade nur room:lobby"
      }
    })

    {:noreply, socket}
  end

  def handle_in("new_msg", msg, socket = %Phoenix.Socket{}) do
    converted_msg = Chatwebsocket.Structs.Message.create_message(msg)

    with "room:" <> id <- socket.topic do
      Chatwebsocket.DatabaseConnection.update_channel_message(
        id,
        converted_msg
      )
    end

    broadcast!(socket, "new_msg", Map.from_struct(converted_msg))

    {:noreply, socket}
  end

  def handle_in(_, _msg, socket) do
    push(socket, "msg_not_existing", %{
      body: %{
        existing_msg: [
          "new_msg"
        ]
      }
    })

    {:noreply, socket}
  end
end
