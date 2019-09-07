defmodule Acceptance.Transform.BasicTest do
  use ExUnit.Case, async: true

  import Earmark.Transform
  import Support.Helpers, only: [parse_html: 1]

  describe "simple ASTs" do
    test "plain old para (POP)" do
      ast      =  [{"p", [], ["POP"]}]
      html     = [ "<p>", "  POP", "</p>" ] |> Enum.join("\n")

      assert transform(ast) == html
    end
    test "two paragraphs, one with atts" do
      html     = "<p hello=\"world\">Before</p>\n<p>After</p>\n"
      ast      = parse_html(html)
      # [{"p", [{"hello", "world"}], ["Before"]}, {"p", [], ["After"]}]
    end
  end
  
end
