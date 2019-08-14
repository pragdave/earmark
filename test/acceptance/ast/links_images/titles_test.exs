defmodule Acceptance.Ast.LinksImages.TitlesTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 1, as_html: 1]

  describe "Links with titles" do
    test "two titled links" do
      mark_tmp = "[link](/uri \"title\")"
      markdown = "#{ mark_tmp } #{ mark_tmp }\n"
      ast      = [{"p", [], [{"a", [{"href", "/uri"}, {"title", "title"}], ["link"]}, " ", {"a", [{"href", "/uri"}, {"title", "title"}], ["link"]}]}] |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "titled link" do
      markdown = "[link](/uri \"title\")\n"
      html = "<p><a href=\"/uri\" title=\"title\">link</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "titled, followed by untitled" do
      markdown = "[a](a 't') [b](b)"
      ast      = [{"p", [], [{"a", [{"href", "a"}, {"title", "t"}], ["a"]}, " ", {"a", [{"href", "b"}], ["b"]}]}] |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "titled, follwoed by untitled and titled" do
      markdown = "[a](a 't') [b](b) [c](c 't')"
      ast      = [{"p", [], [{"a", [{"href", "a"}, {"title", "t"}], ["a"]}, " ", {"a", [{"href", "b"}], ["b"]}, " ", {"a", [{"href", "c"}, {"title", "t"}], ["c"]}]}] |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "titled, followed by two untitled" do
      markdown = "[a](a 't') [b](b) [c](c)"
       ast      = [{"p", [], [{"a", [{"href", "a"}, {"title", "t"}], ["a"]}, " ", {"a", [{"href", "b"}], ["b"]}, " ", {"a", [{"href", "c"}], ["c"]}]}] |> IO.inspect
       messages = []

       assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "titled, followed by 2 untitled, (quotes interspersed)" do
      markdown = "[a](a 't') [b](b) 'xxx' [c](c)"
       ast      = [{"p", [], [{"a", [{"href", "a"}, {"title", "t"}], ["a"]}, " ", {"a", [{"href", "b"}], ["b"]}, " 'xxx' ", {"a", [{"href", "c"}], ["c"]}]}] |> IO.inspect
       messages = []

       assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "titled, followed by 2 untitled, (quotes inside parens interspersed)" do
      markdown = "[a](a 't') [b](b) ('xxx') [c](c)"
       ast      = [{"p", [], [{"a", [{"href", "a"}, {"title", "t"}], ["a"]}, " ", {"a", [{"href", "b"}], ["b"]}, " ('xxx') ", {"a", [{"href", "c"}], ["c"]}]}] |> IO.inspect
       messages = []

       assert as_ast(markdown) == {:ok, ast, messages}
    end


    @tag :ast
    test "titled link, with deprecated quote mismatch" do
      markdown = "[link](/uri \"title')\n"
      html = "<p><a href=\"/uri%20%22title&#39;\">link</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect

      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "Images, and links with titles" do
    @tag :ast
    test "two titled images, different quotes" do
      markdown = ~s{![a](a 't') ![b](b "u")}
      ast      = [{"p", [], [{"img", [{"src", "a"}, {"alt", "a"}, {"title", "t"}], []}, " ", {"img", [{"src", "b"}, {"alt", "b"}, {"title", "u"}], []}]}] |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "two titled images, same quotes" do
      markdown = ~s{![a](a "t") ![b](b "u")}
      ast      = [{"p", [], [{"img", [{"src", "a"}, {"alt", "a"}, {"title", "t"}], []}, " ", {"img", [{"src", "b"}, {"alt", "b"}, {"title", "u"}], []}]}] |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "image and link, same quotes" do
      markdown = ~s{![a](a "t") hello [b](b "u")}
      html = ~s{<p><img src="a" alt="a" title="t"/> hello <a href="b" title="u">b</a></p>\n}
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end 

    @tag :ast
    test "link and untitled image, and image, same quotes" do
      markdown = ~s{[a](a 't')![between](between)![b](b 'u')}
      html = ~s{<p><a href="a" title="t">a</a><img src="between" alt="between"/><img src="b" alt="b" title="u"/></p>\n}
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

end
