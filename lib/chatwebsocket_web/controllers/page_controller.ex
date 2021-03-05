defmodule ChatwebsocketWeb.PageController do
  use ChatwebsocketWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
