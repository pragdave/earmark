defmodule Earmark.Global.Messages do
  @moduledoc """
  Instead of carrying error messages and warnings around we register them
  in this agent and retrieve them at the end when all scanning, parsing
  and rendering tasks are joined again for the final result.
  """
  @doc false
  def start_link do 
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @doc """
  Retrieve all messages
  """
  def get_all_messages do 
    Agent.get(__MODULE__, &sorted_messages/1)
  end

  @doc """
  Add a message in the format specified
  """
  def add_message(msg={_severity, lnb, _description}) when is_number(lnb) do 
    Agent.update(__MODULE__, &([msg | &1]))
  end

  @doc """
  Add many messages with `add_message`
  """
  def add_messages(messages), do: messages |> Enum.each(&add_message/1)

  defp sorted_messages(messages) do 
    messages
    |> Enum.sort(fn( {_, llnb, _}, {_, rlnb, _}) -> llnb <= rlnb end)
    |> Enum.uniq()  # This kludge allows an easier implementation of 
                    # deprecation warnings in 1.2, can be removed in
                    # 1.3
  end

end
