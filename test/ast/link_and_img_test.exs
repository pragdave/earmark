defmodule Acceptance.LinkAndImgTest do
  use ExUnit.Case

  describe "Link reference definitions" do

    test "link with title" do
      markdown = "[foo]: /url \"title\"\n\n[foo]\n"
      # html     = "<p><a href=\"/url\" title=\"title\">foo</a></p>\n"
      ast = {"p", [], [{"a", [{"href", "/url"}, {"title", "title"}], ["foo"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "this ain't no link" do
      markdown = "[foo]: /url \"title\"\n\n[bar]\n"
      # html     = "<p>[bar]</p>\n"
      ast = {"p", [], ["[bar]"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "img with title" do
      markdown = "[foo]: /url \"title\"\n\n![foo]\n"
      # html     = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
      ast = {"p", [], [{"img", [{"src", "/url"}, {"alt", "foo"}, {"title", "title"}], []}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "this ain't no img (and no link)" do
      markdown = "[foo]: /url \"title\"\n\n![bar]\n"
      # html     = "<p>![bar]</p>\n"
      ast = {"p", [], ["![bar]"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "strange syntaxes exist in Markdown" do
      markdown = "[foo]\n\n[foo]: url\n"
      # html = "<p><a href=\"url\" title=\"\">foo</a></p>\n"
      ast = {"p", [], [{"a", [{"href", "url"}, {"title", ""}], ["foo"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "sometimes strange text is just strange text" do
      markdown = "[foo]: /url \"title\" ok\n"
      # html     = "<p>[foo]: /url &quot;title&quot; ok</p>\n"
      ast = {"p", [], ["[foo]: /url &quot;title&quot; ok"]}
      messages = []

      assert Earmark.Interface.html(markdown, smartypants: false) == {:ok, ast, messages}

      # html     = "<p>[foo]: /url “title” ok</p>\n"
      ast = {"p", [], ["[foo]: /url “title” ok"]}
      assert Earmark.Interface.html(markdown, smartypants: true) == {:ok, ast, messages}
    end

    test "guess how this one is rendered?" do
      markdown = "[foo]: /url \"title\"\n"
      # html     = ""
      ast = []
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "or this one, but you might be wrong" do
      markdown = "# [Foo]\n[foo]: /url\n> bar\n"
      # html     = "<h1><a href=\"/url\" title=\"\">Foo</a></h1>\n<blockquote><p>bar</p>\n</blockquote>\n"
      ast = [{"h1", [], [{"a", [{"href", "/url"}, {"title", ""}], ["Foo"]}]}, {"blockquote", [], [{"p", [], ["bar"]}]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

  end

  describe "Link and Image imbrication" do

    test "empty (remains such)" do
      markdown = ""
      # html     = ""
      ast = []
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "inner is a link, not outer" do
      markdown = "[[text](inner)]outer"
      # html     = "<p>[<a href=\"inner\">text</a>]outer</p>\n"
      ast = {"p", [], ["[", {"a", [{"href", "inner"}], ["text"]}, "]outer"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "unless your outer is syntactically a link of course" do
      markdown = "[[text](inner)](outer)"
      # html = "<p><a href=\"outer\">[text](inner)</a></p>\n"
      ast = {"p", [], [{"a", [{"href", "outer"}], ["[text](inner)"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "as with this img" do
      markdown = "![[text](inner)](outer)"
      # html     = "<p><img src=\"outer\" alt=\"[text](inner)\"/></p>\n"
      ast = {"p", [], [{"img", [{"src", "outer"}, {"alt", "[text](inner)"}], []}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "headaches ahead (and behind us)" do
      markdown = "[![moon](moon.jpg)](/uri)\n"
      # html     = "<p><a href=\"/uri\"><img src=\"moon.jpg\" alt=\"moon\"/></a></p>\n"
      ast = {"p", [], [{"a", [{"href", "/uri"}], [{"img", [{"src", "moon.jpg"}, {"alt", "moon"}], []}]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "lost in space" do
      markdown = "![![moon](moon.jpg)](sun.jpg)\n"
      # html = "<p><img src=\"sun.jpg\" alt=\"![moon](moon.jpg)\"/></p>\n"
      ast = {"p", [], [{"img", [{"src", "sun.jpg"}, {"alt", "![moon](moon.jpg)"}], []}]}
      messages = []
      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end
  end

  describe "Links" do
    test "titled link" do
      markdown = "[link](/uri \"title\")\n"
      # html     = "<p><a href=\"/uri\" title=\"title\">link</a></p>\n"
      ast = {"p", [], [{"a", [{"href", "/uri"}, {"title", "title"}], ["link"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "titled link, with depreacted quote missmatch" do
      markdown = "[link](/uri \"title')\n"
      # html     = "<p><a href=\"/uri\" title=\"title\">link</a></p>\n"
      ast = {"p", [], [{"a", [{"href", "/uri"}, {"title", "title"}], ["link"]}]}
      messages = [{:warning, 1, "deprecated, missmatching quotes will not be parsed as matching in v1.3"}]

      assert Earmark.Interface.html(markdown) == {:error, ast, messages}
    end

    test "no title" do
      markdown = "[link](/uri))\n"
      # html     = "<p><a href=\"/uri\">link</a>)</p>\n"
      ast = {"p", [], [{"a", [{"href", "/uri"}], ["link"]}, ")"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "let's go nowhere" do
      markdown = "[link]()\n"
      # html = "<p><a href=\"\">link</a></p>\n"
      ast = {"p", [], [{"a", [{"href", ""}], ["link"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "nowhere in a bottle" do
      markdown = "[link](())\n"
      # html = "<p><a href=\"()\">link</a></p>\n"
      ast = {"p", [], [{"a", [{"href", "()"}], ["link"]}]}
      messages = []
      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end
  end

  describe "Images" do
    test "title" do
      markdown = "![foo](/url \"title\")\n"
      # html     = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
      ast = {"p", [], [{"img", [{"src", "/url"}, {"alt", "foo"}, {"title", "title"}], []}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "ti tle (why not)" do
      markdown = "![foo](/url \"ti tle\")\n"
      # html     = "<p><img src=\"/url\" alt=\"foo\" title=\"ti tle\"/></p>\n"
      ast = {"p", [], [{"img", [{"src", "/url"}, {"alt", "foo"}, {"title", "ti tle"}], []}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "titles become strange" do
      markdown = "![foo](/url \"ti() tle\")\n"
      # html     = "<p><img src=\"/url\" alt=\"foo\" title=\"ti() tle\"/></p>\n"
      ast = {"p", [], [{"img", [{"src", "/url"}, {"alt", "foo"}, {"title", "ti() tle"}], []}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "as does everything else" do
      markdown = "![f[]oo](/url \"ti() tle\")\n"
      # html     = "<p><img src=\"/url\" alt=\"f[]oo\" title=\"ti() tle\"/></p>\n"
      ast = {"p", [], [{"img", [{"src", "/url"}, {"alt", "f[]oo"}, {"title", "ti() tle"}], []}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "alt goes crazy" do
      markdown = "![foo[([])]](/url 'title')\n"
      # html     = "<p><img src=\"/url\" alt=\"foo[([])]\" title=\"title\"/></p>\n"
      ast = {"p", [], [{"img", [{"src", "/url"}, {"alt", "foo[([])]"}, {"title", "title"}], []}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "alt goes crazy, with deprecation warnings" do
      markdown = "\n![foo[([])]](/url 'title\")\n"
      # html     = "<p><img src=\"/url\" alt=\"foo[([])]\" title=\"title\"/></p>\n"
      ast = {"p", [], [{"img", [{"src", "/url"}, {"alt", "foo[([])]"}, {"title", "title"}], []}]}
      messages = [{:warning, 2, "deprecated, missmatching quotes will not be parsed as matching in v1.3"}]

      assert Earmark.Interface.html(markdown) == {:error, ast, messages}
    end

    test "url escapes of course" do
      markdown = "![foo](/url no title)\n"
      # html     = "<p><img src=\"/url%20no%20title\" alt=\"foo\"/></p>\n"
      ast = {"p", [], [{"img", [{"src", "/url%20no%20title"}, {"alt", "foo"}], []}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

  end

  describe "Autolinks" do
    test "that was easy" do
      markdown = "<http://foo.bar.baz>\n"
      # html     = "<p><a href=\"http://foo.bar.baz\">http://foo.bar.baz</a></p>\n"
      ast = {"p", [], [{"a", [{"href", "http://foo.bar.baz"}], ["http://foo.bar.baz"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "as was this" do
      markdown = "<irc://foo.bar:2233/baz>\n"
      # html     = "<p><a href=\"irc://foo.bar:2233/baz\">irc://foo.bar:2233/baz</a></p>\n"
      ast = {"p", [], [{"a", [{"href", "irc://foo.bar:2233/baz"}], ["irc://foo.bar:2233/baz"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "good ol' mail" do
      markdown = "<mailto:foo@bar.baz>\n"
      # html     = "<p><a href=\"mailto:foo@bar.baz\">foo@bar.baz</a></p>\n"
      ast = {"p", [], [{"a", [{"href", "mailto:foo@bar.baz"}], ["foo@bar.baz"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "we know what mail is" do
      markdown = "<foo@bar.example.com>\n"
      # html     = "<p><a href=\"mailto:foo@bar.example.com\">foo@bar.example.com</a></p>\n"
      ast = {"p", [], [{"a", [{"href", "mailto:foo@bar.example.com"}], ["foo@bar.example.com"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "not really a link" do
      markdown = "<>\n"
      # html = "<p>&lt;&gt;</p>\n"
      ast = {"p", [], ["&lt;&gt;"]}
      messages = []
      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

  end

end
