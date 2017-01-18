defmodule Functional.Scanner.LineTypeTest do
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
    { "",         %Line.Blank{} },
    { "        ", %Line.Blank{} },

    { "<!-- comment -->", %Line.HtmlComment{complete: true} },
    { "<!-- comment",     %Line.HtmlComment{complete: false} },

    { "- -",   %Line.ListItem{type: :ul, bullet: "-", content: "-"} },
    { "- - -", %Line.Ruler{type: "-"} },
    { "--",    %Line.SetextUnderlineHeading{level: 2} },
    { "---",   %Line.Ruler{type: "-"} },

    { "* *",   %Line.ListItem{type: :ul, bullet: "*", content: "*"} },
    { "* * *", %Line.Ruler{type: "*"} },
    { "**",    %Line.Text{content: "**"} },
    { "***",   %Line.Ruler{type: "*"} },

    { "_ _",   %Line.Text{content: "_ _"} },
    { "_ _ _", %Line.Ruler{type: "_"} },
    { "__",    %Line.Text{content: "__"} },
    { "___",   %Line.Ruler{type: "_"} },

    { "# H1",       %Line.Heading{level: 1, content: "H1"} },
    { "## H2",      %Line.Heading{level: 2, content: "H2"} },
    { "### H3",     %Line.Heading{level: 3, content: "H3"} },
    { "#### H4",    %Line.Heading{level: 4, content: "H4"} },
    { "##### H5",   %Line.Heading{level: 5, content: "H5"} },
    { "###### H6",  %Line.Heading{level: 6, content: "H6"} },
    { "####### H7", %Line.Text{content: "####### H7"} },

    { "> quote",    %Line.BlockQuote{content: "quote"} },
    { ">    quote", %Line.BlockQuote{content: "   quote"} },
    { ">quote",     %Line.Text{content: ">quote"} },

    #1234567890
    { "   a",        %Line.Text{content: "   a"} },
    { "    b",       %Line.Indent{level: 1, content: "b"} },
    { "      c",     %Line.Indent{level: 1, content: "  c"} },
    { "        d",   %Line.Indent{level: 2, content: "d"} },
    { "          e", %Line.Indent{level: 2, content: "  e"} },

    { "```",      %Line.Fence{delimiter: "```", language: "",     line: "```"} },
    { "``` java", %Line.Fence{delimiter: "```", language: "java", line: "``` java"} },
    { " ``` java", %Line.Fence{delimiter: "```", language: "java", line: " ``` java"} },
    { "```java",  %Line.Fence{delimiter: "```", language: "java", line: "```java"} },
    { "```language-java",  %Line.Fence{delimiter: "```", language: "language-java"} },
    { "```language-élixir",  %Line.Fence{delimiter: "```", language: "language-élixir"} },

    { "~~~",      %Line.Fence{delimiter: "~~~", language: "",     line: "~~~"} },
    { "~~~ java", %Line.Fence{delimiter: "~~~", language: "java", line: "~~~ java"} },
    { "  ~~~java",  %Line.Fence{delimiter: "~~~", language: "java", line: "  ~~~java"} },
    { "~~~ language-java", %Line.Fence{delimiter: "~~~", language: "language-java"} },
    { "~~~ language-élixir",  %Line.Fence{delimiter: "~~~", language: "language-élixir"} },

    { "``` hello ```", %Line.Text{content: "``` hello ```"} },
    { "```hello```", %Line.Text{content: "```hello```"} },
    { "```hello world", %Line.Text{content: "```hello world"} },

    { "<pre>",             %Line.HtmlOpenTag{tag: "pre", content: "<pre>"} },
    { "<pre class='123'>", %Line.HtmlOpenTag{tag: "pre", content: "<pre class='123'>"} },
    { "</pre>",            %Line.HtmlCloseTag{tag: "pre"} },

    { "<pre>a</pre>",      %Line.HtmlOneLine{tag: "pre", content: "<pre>a</pre>"} },

    { "<area>",              %Line.HtmlOneLine{tag: "area", content: "<area>"} },
    { "<area/>",             %Line.HtmlOneLine{tag: "area", content: "<area/>"} },
    { "<area class='a'>",    %Line.HtmlOneLine{tag: "area", content: "<area class='a'>"} },

    { "<br>",              %Line.HtmlOneLine{tag: "br", content: "<br>"} },
    { "<br/>",             %Line.HtmlOneLine{tag: "br", content: "<br/>"} },
    { "<br class='a'>",    %Line.HtmlOneLine{tag: "br", content: "<br class='a'>"} },

    { "<hr>",              %Line.HtmlOneLine{tag: "hr", content: "<hr>"} },
    { "<hr/>",             %Line.HtmlOneLine{tag: "hr", content: "<hr/>"} },
    { "<hr class='a'>",    %Line.HtmlOneLine{tag: "hr", content: "<hr class='a'>"} },

    { "<img>",              %Line.HtmlOneLine{tag: "img", content: "<img>"} },
    { "<img/>",             %Line.HtmlOneLine{tag: "img", content: "<img/>"} },
    { "<img class='a'>",    %Line.HtmlOneLine{tag: "img", content: "<img class='a'>"} },

    { "<wbr>",              %Line.HtmlOneLine{tag: "wbr", content: "<wbr>"} },
    { "<wbr/>",             %Line.HtmlOneLine{tag: "wbr", content: "<wbr/>"} },
    { "<wbr class='a'>",    %Line.HtmlOneLine{tag: "wbr", content: "<wbr class='a'>"} },

    { "<h2>Headline</h2>",               %Line.HtmlOneLine{tag: "h2", content: "<h2>Headline</h2>"} },
    { "<h2 id='headline'>Headline</h2>", %Line.HtmlOneLine{tag: "h2", content: "<h2 id='headline'>Headline</h2>"} },

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


      { "* ul1", %Line.ListItem{ type: :ul, bullet: "*", content: "ul1"} },
      { "+ ul2", %Line.ListItem{ type: :ul, bullet: "+", content: "ul2"} },
      { "- ul3", %Line.ListItem{ type: :ul, bullet: "-", content: "ul3"} },

      { "*     ul1", %Line.ListItem{ type: :ul, bullet: "*", content: "ul1"} },
      { "*ul1",      %Line.Text{content: "*ul1"} },

      { "1. ol1",          %Line.ListItem{ type: :ol, bullet: "1.", content: "ol1"} },
      { "12345.      ol1", %Line.ListItem{ type: :ol, bullet: "12345.", content: "ol1"} },
      { "1.ol1", %Line.Text{ content: "1.ol1"} },

      { "=",        %Line.SetextUnderlineHeading{level: 1} },
      { "========", %Line.SetextUnderlineHeading{level: 1} },
      { "-",        %Line.SetextUnderlineHeading{level: 2} },
      { "= and so", %Line.Text{content: "= and so"} },

      { "   (title)", %Line.Text{content: "   (title)"} },

      { "{: .attr }",       %Line.Ial{attrs: ".attr"} },
      { "{:.a1 .a2}",       %Line.Ial{attrs: ".a1 .a2"} },

      { "  | a | b | c | ", %Line.TableLine{content: "  | a | b | c | ",
          columns: ~w{a b c} } },
      { "  | a         | ", %Line.TableLine{content: "  | a         | ",
          columns: ~w{a} } },
      { "  a | b | c  ",    %Line.TableLine{content: "  a | b | c  ",
          columns: ~w{a b c} } },
      { "  a \\| b | c  ",  %Line.TableLine{content: "  a \\| b | c  ",
          columns: [ "a | b",  "c"] } },

      #
      # Footnote Definitions but no footnote option
      #
      { "[^1]: bar baz", %Earmark.Line.Text{content: "[^1]: bar baz", inside_code: false,
                       line: "[^1]: bar baz", lnb: 42}},
      #
      # Plugins
      #
      { "$$",                       %Line.Plugin{prefix: "", content: ""}},
      { "$$ ",                      %Line.Plugin{prefix: "", content: ""}},
      { "$$pfx ",                   %Line.Plugin{prefix: "pfx", content: ""}},
      { "$$pfx",                    %Line.Plugin{prefix: "pfx", content: ""}},

      { "$$ my line for plugin",    %Line.Plugin{prefix: "", content: "my line for plugin"}},
      { "$$pfx my line for plugin", %Line.Plugin{prefix: "pfx", content: "my line for plugin"}},

          ]
  |> Enum.each(fn { text, type } ->
    test("line: '" <> text <> "'") do
      struct = unquote(Macro.escape type)
      struct = %{ struct | line: unquote(text), lnb: 42 }
      assert Line.type_of({unquote(text), 42}, false) == struct
    end
  end)

end
