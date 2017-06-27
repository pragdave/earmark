defmodule Acceptance.DiverseTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1]

  describe "etc" do
    test "entiy" do
      markdown = "`f&ouml;&ouml;`\n"
      # html     = "<p><code class=\"inline\">f&amp;ouml;&amp;ouml;</code></p>\n"
      ast = {"p", [], [{"code", [{"class", "inline"}], ["f&amp;ouml;&amp;ouml;"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "spaec preserving" do
      markdown = "Multiple     spaces\n"
      # html     = "<p>Multiple     spaces</p>\n"
      ast = {"p", [], ["Multiple     spaces"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "syntax errors" do
      markdown ="A\nB\n="
      # html     = "<p>A\nB</p>\n<p></p>\n"
      ast = [{"p", [], ["A\nB"]}, {"p", [], []}]
      messages = [{:warning, 3, "Unexpected line =" }]

      assert Earmark.Interface.html(markdown) == {:error, ast, messages}
    end
   end

end
