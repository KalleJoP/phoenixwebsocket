defmodule Chatwebsocket.Structs.Message do
  defstruct [:author, :content, :inserted]

  def create_message(%{"author" => author, "content" => content}) do
    %Chatwebsocket.Structs.Message{
      author: author,
      content: content,
      inserted: get_local_datetime()
    }
  end

  defp get_local_datetime() do
    {:ok, datetime} =
      NaiveDateTime.local_now()
      |> DateTime.from_naive("Etc/UTC")

    datetime
  end
end
