defmodule Chatwebsocket.Structs.Message do
  defstruct [:author, :content, :inserted]

  def create_message(%{"author" => author, "content" => content}) do
    %Chatwebsocket.Structs.Message{author: author, content: content, inserted: DateTime.utc_now()}
  end
end
