defmodule ChatwebsocketWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", %{"username" => username}, socket) do
    send(self(), {:sent_rooms, username})
    {:ok, socket}
  end

  def join("room:" <> id, _message, socket) do
    send(self(), {:after_join, %{id: id}})
    {:ok, socket}
  end

  def handle_info({:after_join, msg}, socket) do
    channel = msg.id

    messages = Chatwebsocket.DatabaseConnection.select_channel_messages(channel)

    push(socket, "room_messages", %{
      body: messages
    })

    {:noreply, socket}
  end

  def handle_info({:sent_rooms, username}, socket) do
    IO.inspect(username)

    broadcast!(socket, "recieve_rooms", %{
      body: Chatwebsocket.DatabaseConnection.select_rooms_from_user(username)
    })

    {:noreply, socket}
  end

  def handle_in("new_msg", msg, socket = %Phoenix.Socket{}) do
    converted_msg = Chatwebsocket.Structs.Message.create_message(msg)

    with "room:" <> id <- socket.topic do
      Chatwebsocket.DatabaseConnection.insert_message(
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
