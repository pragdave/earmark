defmodule Earmark.Context do
  defstruct options:  %Earmark.Options{},
            links:    Map.new,
            rules:    nil,
            footnotes: Map.new

  @doc """
  Append messages to `context.options.messages`
  """
  def add_messages(context, messages)
  def add_messages(context, messages) when is_list(messages) do
    options = context.options
    %{context | options: %{ options | messages: options.messages ++ messages }}
  end
  def add_messages(context, messages), do: add_messages(context, [messages])

  @doc """
  Access `context.options.messages`
  """
  def messages(context), do: context.options.messages

end
