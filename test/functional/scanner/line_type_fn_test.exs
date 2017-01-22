defmodule Functional.Scanner.LineTypeFnTest do
  use ExUnit.Case

  alias Earmark.Line

  id1 = ~S{[ID1]: http://example.com  "The title"}
  id2 = ~S{[ID2]: http://example.com  'The title'}
  id3 = ~S{[ID3]: http://example.com  (The title)}
  id4 = ~S{[ID4]: http://example.com}
  id5 = ~S{[ID5]: <http://example.com>  "The title"}
  id6 = ~S{ [ID6]: http://example.com  "The title"}
  id7 = ~S{  [ID7]: http://example.com  "The title"}
  id8 = ~S{   [ID8]: http://example.com  "The title"}
  id9 = ~S{    [ID9]: http://example.com  "The title"}

  id10 = ~S{[ID10]: /url/ "Title with "quotes" inside"}
  id11 = ~S{[ID11]: http://example.com "Title with trailing whitespace" }

  [
    #
    # Some simple examples from the footnotes: false tests
    #
    { "        ", %Line.Blank{} },
    { "---",   %Line.Ruler{type: "-"} },
    { "* *",   %Line.ListItem{type: :ul, bullet: "*", content: "*"} },
    { "_ _ _", %Line.Ruler{type: "_"} },
    { "__",    %Line.Text{content: "__"} },
    { "# H1",       %Line.Heading{level: 1, content: "H1"} },
    { "## H2",      %Line.Heading{level: 2, content: "H2"} },
    { "####### H7", %Line.Text{content: "####### H7"} },

    { "> quote",    %Line.BlockQuote{content: "quote"} },
    { ">quote",     %Line.Text{content: ">quote"} },

    #1234567890
    { "   a",        %Line.Text{content: "   a"} },
    { "    b",       %Line.Indent{level: 1, content: "b"} },
    { "          e", %Line.Indent{level: 2, content: "  e"} },

    { "``` java", %Line.Fence{delimiter: "```", language: "java", line: "``` java"} },
    { "~~~",      %Line.Fence{delimiter: "~~~", language: "",     line: "~~~"} },
    { "``` hello ```", %Line.Text{content: "``` hello ```"} },

    { "<pre class='123'>", %Line.HtmlOpenTag{tag: "pre", content: "<pre class='123'>"} },
    { "</pre>",            %Line.HtmlCloseTag{tag: "pre"} },
    { "<pre>a</pre>",      %Line.HtmlOneLine{tag: "pre", content: "<pre>a</pre>"} },

    #
    # IDS and Footnotes are important to be distinct
    { id1, %Line.IdDef{id: "ID1", url: "http://example.com", title: "The title"} },
    { id2, %Line.IdDef{id: "ID2", url: "http://example.com", title: "The title"} },
    { id3, %Line.IdDef{id: "ID3", url: "http://example.com", title: "The title"} },
    { id4, %Line.IdDef{id: "ID4", url: "http://example.com", title: ""} },
    { id5, %Line.IdDef{id: "ID5", url: "http://example.com", title: "The title"} },
    { id6, %Line.IdDef{id: "ID6", url: "http://example.com", title: "The title"} },
    { id7, %Line.IdDef{id: "ID7", url: "http://example.com", title: "The title"} },
    { id8, %Line.IdDef{id: "ID8", url: "http://example.com", title: "The title"} },
    { id9, %Line.Indent{content: "[ID9]: http://example.com  \"The title\"",
        level: 1,       line: "    [ID9]: http://example.com  \"The title\""} },

      {id10, %Line.IdDef{id: "ID10", url: "/url/", title: "Title with \"quotes\" inside"}},
      {id11, %Line.IdDef{id: "ID11", url: "http://example.com", title: "Title with trailing whitespace"}},

      #
      # Footnote Definitions
      #
      { "[^1]: bar baz",  %Line.FnDef{content: "bar baz", id: "1"}},

      #
      # or not
      #
      { "[^1]: bar",  %Line.IdDef{id: "^1", inside_code: false, line: "[^1]: bar",
                       lnb: 42, title: "", url: "bar"}},

          ]
  |> Enum.each(fn { text, type } ->
    test("line(footnotes: true): '" <> text <> "'") do
      struct = unquote(Macro.escape type)
      struct = %{ struct | line: unquote(text), lnb: 42 }
      assert Line.type_of({unquote(text), 42}, %Earmark.Options{footnotes: true}, false) == struct
    end
  end)

end
