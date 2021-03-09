defmodule ChatwebsocketWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    send(self(), {:after_join, {}})

    {:ok, socket}
  end

  def handle_info({:after_join, _msg}, socket) do
    broadcast!(socket, "hello_daniel", %{
      body: %{
        message: "Hey"
      }
    })

    {:noreply, socket}
  end

  def handle_in("new_msg", msg, socket) do
    IO.inspect(msg)

    broadcast!(socket, "new_msg", %{
      body: %{
        message: "Klappt"
      }
    })

    {:noreply, socket}
  end
end
