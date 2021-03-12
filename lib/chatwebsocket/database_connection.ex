defmodule ChatWebsocket.DatabasConnection do
  def test() do
    {:ok, conn} = Xandra.start_link(nodes: ["creepytoast.ddns.net:9042"])

    with {:ok, prepared} <- Xandra.prepare(conn, "SELECT * from test.chat_test"),
         {:ok, page = %Xandra.Page{}} <- Xandra.execute(conn, prepared, []),
         do: Enum.to_list(page)
  end
end
