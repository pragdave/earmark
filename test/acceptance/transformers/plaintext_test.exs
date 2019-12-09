defmodule Acceptance.Transformers.PlaintextTests do
  use ExUnit.Case, async: true

  doctest Earmark.Transformers.Plaintext, import: true

  describe "markdown_to_plaintext" do

    test "remove basic markup" do
      markdown = "*Emphasized* text."
      plaintext = "Emphasized text."

      assert as_plaintext(markdown) == {:ok, plaintext, []}
    end

    test "keep newlines while removing markup" do
      markdown = "*Line one*\n[Line two](http://example.com)\nLine **three**"
      plaintext = "Line one\nLine two\nLine three"

      assert as_plaintext(markdown) == {:ok, plaintext, []}
    end


    test "an example with block elements" do
      markdown = """
      1. Item One
      1. Item Two
         > Block
      """
      plaintext = "Item OneItem TwoBlock"

      assert as_plaintext(markdown) == {:ok, plaintext, []}
    end

  end

  describe "ast_to_plaintext" do
    test "assure meta is supported" do
      ast = [{"div", [], ["xxx"], %{meta: %{verbatim: true}}}]

      assert Earmark.Transformers.Plaintext.ast_to_plaintext(ast) == "xxx"
    end
  end

  defp as_plaintext(markdown), do: Earmark.Transformers.Plaintext.markdown_to_plaintext(markdown)
end
