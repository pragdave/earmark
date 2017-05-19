defmodule Unit.Global.MessagesTest do
  use ExUnit.Case

  alias Earmark.Global.Messages, as: M

  setup do
    M.start_link()
    :ok
  end

  test "empty" do
    assert M.pop_all_messages() == []
  end

  describe "sequential updates" do
    test "one" do
      M.add_message({:error, 1, "unknown"})
      assert M.pop_all_messages() == [{:error, 1, "unknown"}]
    end
    test "more" do
      M.add_message({:error, 43, "known"})
      M.add_message({:error, 1, "unknown"})
      M.add_message({:error, 42, "secret"})

      assert M.pop_all_messages() == [
        {:error, 1, "unknown"},
        {:error, 42, "secret"},
        {:error, 43, "known"},
      ]
    end
  end

  describe "parallel updates" do
    test "many" do
      text = "afrziqojiooahc"
      messages = String.split(text, "")
                  |> Enum.zip(Stream.iterate(1, &(&1+1)))
                  |> Enum.to_list()

      expected_messages = messages
                          |> Enum.map(&mk_message/1)

      expected_messages
      |> Enum.reverse()
      |> Earmark.pmap(&M.add_message/1)

      assert M.pop_all_messages() == expected_messages
    end

    test "many with add_message and add_all_messages" do
      messages =
      [{:error, 11, "eleven"},
       [{:error, 2, "two"}, {:error, 1, "one"}],
       {:error, 42, "answer"},
       [{:error, 3, "three"}, {:error, 10, "ten"}, {:error, 0, "zero"}]]



      messages
      |> Earmark.pmap(&add_message_or_messages/1)

      assert M.pop_all_messages() == (
        messages
        |> List.flatten()
        |> Enum.sort(&compare/2))

    end
  end

  defp compare({_,l,_}, {_,r,_}), do: l <= r

  defp add_message_or_messages(t={_,_,_}), do: M.add_message(t)
  defp add_message_or_messages(list), do: M.add_messages(list)

  defp mk_message({mess, lnb}), do: {:error, lnb, mess}


end
