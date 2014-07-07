defmodule LineTest do
  use ExUnit.Case

  alias Earmark.Line
  
     id1 = ~S{[ID1]: http://example.com  "The title"}
     id2 = ~S{[ID2]: http://example.com  'The title'}
     id3 = ~S{[ID3]: http://example.com  (The title)}
     id4 = ~S{[ID4]: http://example.com}
     id5 = ~S{[ID5]: <http://example.com>  "The title"}
     
    [ 
     { "",         %Line.Blank{} },
     { "        ", %Line.Blank{} },

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
     { "``` java", %Line.Fence{delimiter: "```", language: "java", line: "``` jave"} },
     { "```java",  %Line.Fence{delimiter: "```", language: "java", line: "```java"} },
     { "~~~",      %Line.Fence{delimiter: "~~~", language: "",     line: "~~~"} },
     { "~~~ java", %Line.Fence{delimiter: "~~~", language: "java", line: "~~~ java"} },
     { "~~~java",  %Line.Fence{delimiter: "~~~", language: "java", line: "~~~java"} },

     { "<pre>",             %Line.HtmlOpenTag{tag: "pre", content: "<pre>"} },
     { "<pre class='123'>", %Line.HtmlOpenTag{tag: "pre", content: "<pre class='123'>"} },
     { "</pre>",            %Line.HtmlCloseTag{tag: "pre"} },

     { id1, %Line.IdDef{id: "ID1", url: "http://example.com", title: "The title"} },
     { id2, %Line.IdDef{id: "ID2", url: "http://example.com", title: "The title"} },
     { id3, %Line.IdDef{id: "ID3", url: "http://example.com", title: "The title"} },
     { id4, %Line.IdDef{id: "ID4", url: "http://example.com", title: ""} },
     { id5, %Line.IdDef{id: "ID5", url: "http://example.com", title: "The title"} },

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
    ]
    |> Enum.each(fn { text, type } -> 
         test("line: '" <> text <> "'") do
           struct = unquote(Macro.escape type)
           struct = %{ struct | line: unquote(text) }
           assert Line.type_of(unquote(text)) == struct
         end
       end)

end
