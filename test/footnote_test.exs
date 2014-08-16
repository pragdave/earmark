defmodule FootnoteTest do
  use ExUnit.Case

  alias Earmark.Inline
  alias Earmark.Block.FnDef

  def test_footnotes do
    [ {"fn-a", %FnDef{id: ""}}
    ]
    |> Enum.into(HashDict.new)
  end

  def context do
    ctx = put_in(%Earmark.Context{}.options.footnotes, true)
    ctx = put_in(ctx.footnotes, test_footnotes)
    Inline.update_context(ctx)
  end

  def convert(string) do
    Inline.convert(string, context)
  end

  test "smoke" do
    result = convert("hello")
    assert result == "hello"
  end

  test "basic footnote link" do
    result = convert(~s{a footnote[^fn-a] in text})
    assert result == ~s[a footnote<a href=\"#fn:1\" id=\"fnref:1\" class="footnote" title="see footnote">1</a> in text]
  end

end
