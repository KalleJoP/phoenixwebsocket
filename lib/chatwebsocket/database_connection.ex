defmodule Chatwebsocket.DatabaseConnection do
  def select_channel_messages(channel) do
    with {:ok, prepared} <-
           Xandra.prepare(
             :kloenschnack_connection,
             "SELECT * FROM kloenschnack.messages WHERE channel_id = :channel"
           ),
         {:ok, page = %Xandra.Page{}} <-
           Xandra.execute(:kloenschnack_connection, prepared, %{"channel" => channel}),
         do: Enum.to_list(page)
  end

  def insert_message(channel, message = %Chatwebsocket.Structs.Message{}) do
    prepared_insert =
      Xandra.prepare!(
        :kloenschnack_connection,
        "INSERT INTO kloenschnack.messages (channel_id,message_id, author, content, inserted)
        VALUES (:channel_id, :message_id, :author, :content, :inserted)"
      )

    {:ok, snowflake} = Snowflake.next_id()

    Xandra.execute!(:kloenschnack_connection, prepared_insert, %{
      "channel_id" => channel,
      "message_id" => snowflake,
      "author" => message.author,
      "content" => message.content,
      "inserted" => message.inserted
    })
  end

  def select_rooms_from_user(author) do
    with {:ok, prepared} <-
           Xandra.prepare(
             :kloenschnack_connection,
             "SELECT channel_id FROM kloenschnack.messages where author = :author group by channel_id"
           ),
         {:ok, page = %Xandra.Page{}} <-
           Xandra.execute(:kloenschnack_connection, prepared, %{
             "author" => author
           }),
         do:
           Enum.to_list(page)
           |> take_default_channel("channel1")
           |> take_default_channel("channel2")
           |> append_default_channels()
  end

  defp take_default_channel(list, filter) do
    Enum.filter(list, fn item ->
      channel_id = Map.get(item, "channel_id")
      channel_id != filter
    end)
  end

  defp append_default_channels(list) do
    list ++ [%{"channel_id" => "channel1"}, %{"channel_id" => "channel2"}]
  end
end
