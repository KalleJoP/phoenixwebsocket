defmodule Chatwebsocket.DatabaseConnection do
  def select_channel_messages(channel) do
    with {:ok, prepared} <-
           Xandra.prepare(
             :kloenschnack_connection,
             "SELECT messages FROM kloenschnack.channel WHERE name = :channel"
           ),
         {:ok, page = %Xandra.Page{}} <-
           Xandra.execute(:kloenschnack_connection, prepared, %{"channel" => channel}),
         do: Enum.to_list(page)
  end

  def insert_new_channel(channel) do
    prepared_insert =
      Xandra.prepare!(
        :kloenschnack_connection,
        "INSERT INTO kloenschnack.channel (name,messages) VALUES (:channel, :messages)"
      )

    messages = []

    Xandra.execute!(:kloenschnack_connection, prepared_insert, %{
      "channel" => channel,
      "messages" => messages
    })
  end

  def update_channel_message(channel, message = %Chatwebsocket.Structs.Message{}) do
    prepared_insert =
      Xandra.prepare!(
        :kloenschnack_connection,
        "UPDATE kloenschnack.channel SET messages = messages + :message WHERE name = :channel"
      )

    messages = [
      %{
        "author" => message.author,
        "content" => message.content,
        "inserted" => message.inserted
      }
    ]

    Xandra.execute!(:kloenschnack_connection, prepared_insert, %{
      "channel" => channel,
      "message" => messages
    })
  end

  def check_channel_existing(channel) do
    with {:ok, prepared} <-
           Xandra.prepare(
             :kloenschnack_connection,
             "SELECT * FROM kloenschnack.channel WHERE name = :channel"
           ),
         {:ok, page = %Xandra.Page{}} <-
           Xandra.execute(:kloenschnack_connection, prepared, %{"channel" => channel}),
         do: check_if_list_empty(Enum.to_list(page))
  end

  defp check_if_list_empty(list) do
    if List.first(list) == nil do
      false
    else
      true
    end
  end
end
