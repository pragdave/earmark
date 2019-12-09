defmodule Acceptance.Plaintext.PlaintextTests do
  use ExUnit.Case, async: true

  import Earmark, only: [as_plaintext: 1]

  test "remove basic markup" do
    markdown = "*Emphasized* text."
    plaintext = "Emphasized text."

    assert as_plaintext(markdown) == {:ok, plaintext}
  end

  test "keep newlines while removing markup" do
    markdown = "*Line one*\n[Line two](http://example.com)\nLine **three**"
    plaintext = "Line one\nLine two\nLine three"

    assert as_plaintext(markdown) == {:ok, plaintext}
  end

  test "invalid markup" do
    markdown = "This is a [broken](http://link){:blah}."

    assert {:error, [{:warning, _, _}]} = as_plaintext(markdown)
  end
end
