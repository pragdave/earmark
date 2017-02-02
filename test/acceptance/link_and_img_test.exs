defmodule Acceptance.LinkAndImgTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1, as_html: 2]

  # describe "Link reference definitions" do

    test "link with title" do
      markdown = "[foo]: /url \"title\"\n\n[foo]\n"
      html     = "<p><a href=\"/url\" title=\"title\">foo</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "this ain't no link" do
      markdown = "[foo]: /url \"title\"\n\n[bar]\n"
      html     = "<p>[bar]</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "img with title" do
      markdown = "[foo]: /url \"title\"\n\n![foo]\n"
      html     = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "this ain't no img (and no link)" do
      markdown = "[foo]: /url \"title\"\n\n![bar]\n"
      html     = "<p>![bar]</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "strange syntaxes exist in Markdown" do
      markdown = "[foo]\n\n[foo]: url\n"
      html = "<p><a href=\"url\" title=\"\">foo</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "sometimes strange text is just strange text" do
      markdown = "[foo]: /url \"title\" ok\n"
      html     = "<p>[foo]: /url &quot;title&quot; ok</p>\n"
      messages = []

      assert as_html(markdown, smartypants: false) == {:ok, html, messages}

      html     = "<p>[foo]: /url “title” ok</p>\n"
      assert as_html(markdown, smartypants: true) == {:ok, html, messages}
    end

    test "guess how this one is rendered?" do
      markdown = "[foo]: /url \"title\"\n"
      html     = ""
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "or this one, but you might be wrong" do
      markdown = "# [Foo]\n[foo]: /url\n> bar\n"
      html     = "<h1><a href=\"/url\" title=\"\">Foo</a></h1>\n<blockquote><p>bar</p>\n</blockquote>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    # end

    # describe "Link and Image imbrication" do

      test "empty (remains such)" do
        markdown = ""
        html     = ""
        messages = []

        assert as_html(markdown) == {:ok, html, messages}
      end

      test "inner is a link, not outer" do
        markdown = "[[text](inner)]outer"
        html     = "<p>[<a href=\"inner\">text</a>]outer</p>\n"
        messages = []

        assert as_html(markdown) == {:ok, html, messages}
      end

      test "unless your outer is syntactically a link of course" do
        markdown = "[[text](inner)](outer)"
        html = "<p><a href=\"outer\">[text](inner)</a></p>\n"
        messages = []

        assert as_html(markdown) == {:ok, html, messages}
      end

      test "as with this img" do
        markdown = "![[text](inner)](outer)"
        html     = "<p><img src=\"outer\" alt=\"[text](inner)\"/></p>\n"
        messages = []

        assert as_html(markdown) == {:ok, html, messages}
      end

      test "headaches ahead (and behind us)" do
        markdown = "[![moon](moon.jpg)](/uri)\n"
        html     = "<p><a href=\"/uri\"><img src=\"moon.jpg\" alt=\"moon\"/></a></p>\n"
        messages = []

        assert as_html(markdown) == {:ok, html, messages}
      end

      test "lost in space" do
        markdown = "![![moon](moon.jpg)](sun.jpg)\n"
        html = "<p><img src=\"sun.jpg\" alt=\"![moon](moon.jpg)\"/></p>\n"
        messages = []
        assert as_html(markdown) == {:ok, html, messages}
      end
      # end

      # describe "Links" do
        test "titled link" do
          markdown = "[link](/uri \"title\")\n"
          html     = "<p><a href=\"/uri\" title=\"title\">link</a></p>\n"
          messages = []

          assert as_html(markdown) == {:ok, html, messages}
        end

        test "no title" do
          markdown = "[link](/uri))\n"
          html     = "<p><a href=\"/uri\">link</a>)</p>\n"
          messages = []

          assert as_html(markdown) == {:ok, html, messages}
        end

        test "let's go nowhere" do
          markdown = "[link]()\n"
          html = "<p><a href=\"\">link</a></p>\n"
          messages = []

          assert as_html(markdown) == {:ok, html, messages}
        end

        test "nowhere in a bottle" do
          markdown = "[link](())\n"
          html = "<p><a href=\"()\">link</a></p>\n"
          messages = []
          assert as_html(markdown) == {:ok, html, messages}
        end
        # end

        # describe "Images" do
          test "title" do
            markdown = "![foo](/url \"title\")\n"
            html     = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
            messages = []

            assert as_html(markdown) == {:ok, html, messages}
          end

          test "ti tle (why not)" do
            markdown = "![foo](/url \"ti tle\")\n"
            html     = "<p><img src=\"/url\" alt=\"foo\" title=\"ti tle\"/></p>\n"
            messages = []

            assert as_html(markdown) == {:ok, html, messages}
          end

          test "titles become strange" do
            markdown = "![foo](/url \"ti() tle\")\n"
            html     = "<p><img src=\"/url\" alt=\"foo\" title=\"ti() tle\"/></p>\n"
            messages = []

            assert as_html(markdown) == {:ok, html, messages}
          end

          test "as does everything else" do
            markdown = "![f[]oo](/url \"ti() tle\")\n"
            html     = "<p><img src=\"/url\" alt=\"f[]oo\" title=\"ti() tle\"/></p>\n"
            messages = []

            assert as_html(markdown) == {:ok, html, messages}
          end

          test "alt goes crazy" do
            markdown = "![foo[([])]](/url 'title')\n"
            html     = "<p><img src=\"/url\" alt=\"foo[([])]\" title=\"title\"/></p>\n"
            messages = []

            assert as_html(markdown) == {:ok, html, messages}
          end

          test "url escapes of coure" do
            markdown = "![foo](/url no title)\n"
            html     = "<p><img src=\"/url%20no%20title\" alt=\"foo\"/></p>\n"
            messages = []

            assert as_html(markdown) == {:ok, html, messages}
          end

          # end

          # describe "Autolinks" do
            test "that was easy" do
              markdown = "<http://foo.bar.baz>\n"
              html     = "<p><a href=\"http://foo.bar.baz\">http://foo.bar.baz</a></p>\n"
              messages = []

              assert as_html(markdown) == {:ok, html, messages}
            end

            test "as was this" do
              markdown = "<irc://foo.bar:2233/baz>\n"
              html     = "<p><a href=\"irc://foo.bar:2233/baz\">irc://foo.bar:2233/baz</a></p>\n"
              messages = []

              assert as_html(markdown) == {:ok, html, messages}
            end

            test "good ol' mail" do
              markdown = "<mailto:foo@bar.baz>\n"
              html     = "<p><a href=\"mailto:foo@bar.baz\">foo@bar.baz</a></p>\n"
              messages = []

              assert as_html(markdown) == {:ok, html, messages}
            end

            test "we know what mail is" do
              markdown = "<foo@bar.example.com>\n"
              html     = "<p><a href=\"mailto:foo@bar.example.com\">foo@bar.example.com</a></p>\n"
              messages = []

              assert as_html(markdown) == {:ok, html, messages}
            end

            test "not really a link" do
              markdown = "<>\n"
              html = "<p>&lt;&gt;</p>\n"
              messages = []
              assert as_html(markdown) == {:ok, html, messages}
            end
            # end
end
