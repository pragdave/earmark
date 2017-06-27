defmodule Acceptance.EscapeTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1, as_html: 2]

  # describe "Escapes" do
    test "dizzy?" do
      markdown = "\\\\!\\\\\""
      # html     = "<p>\\!\\“</p>\n"
      ast = {"p", [], ["\\!\\“"]}
      messages = []

      assert Earmark.Interface.html(markdown, smartypants: true) == {:ok, ast, messages}

      # html     = "<p>\\!\\&quot;</p>\n"
      ast = {"p", [], ["\\!\\&quot;"]}
      assert Earmark.Interface.html(markdown, smartypants: false) == {:ok, ast, messages}
    end

    test "obviously" do
      markdown = "\\`no code"
      # html     = "<p>`no code</p>\n"
      ast = {"p", [], ["`no code"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "less obviously - escpe the escapes" do
      markdown = "\\\\` code`"
      # html     = "<p>\\<code class=\"inline\">code</code></p>\n"
      ast = {"p", [], ["\\", {"code", [{"class", "inline"}], ["code"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "don't ask me" do
      markdown = "\\\\ \\"
      # html     = "<p>\\ \\</p>\n"
      ast = {"p", [], ["\\ \\"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "a plenty of nots" do
      markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
      # html     = "<p>*not emphasized*\n[not a link](/foo)\n`not code`\n1. not a list\n* not a list\n# not a header\n[foo]: /url &quot;not a reference&quot;</p>\n"
      ast = {"p", [], ["*not emphasized*\n[not a link](/foo)\n`not code`\n1. not a list\n* not a list\n# not a header\n[foo]: /url &quot;not a reference&quot;"]}
      messages = [{:warning, 3, "Closing unclosed backquotes ` at end of input" }]

      assert Earmark.Interface.html(markdown, smartypants: false) == {:error, ast, messages}
    end

    test "let us escape (again)" do
      markdown = "\\\\*emphasis*\n"
      # html = "<p>\\<em>emphasis</em></p>\n"
      ast = {"p", [], ["\\", {"em", [], ["emphasis"]}]}
      messages = []
      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end
  # end
end
