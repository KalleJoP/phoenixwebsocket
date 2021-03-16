defmodule ChatwebsocketWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    send(self(), {:after_join, {}})

    {:ok, socket}
  end

  def join("room:" <> _id, _message, socket) do
    send(self(), {:after_join, {}})
    {:ok, socket}
  end

  def handle_info({:after_join, _msg}, socket) do
    push(socket, "room_messages", %{
      body: [
        %{
          message: "Hey",
          author: "Bot"
        }
      ]
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

  def handle_in("new_msg", msg, socket) do
    IO.inspect(msg)

    broadcast!(socket, "new_msg", msg)

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
