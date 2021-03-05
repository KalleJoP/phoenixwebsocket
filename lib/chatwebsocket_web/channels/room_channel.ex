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
end
