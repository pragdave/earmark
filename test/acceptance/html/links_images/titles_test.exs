defmodule Acceptance.Html.LinksImages.TitlesTest do
  use Support.AcceptanceTestCase

  describe "Links with titles" do
    test "two titled links" do
      mark_tmp = "[link](/uri \"title\")"
      markdown = "#{ mark_tmp } #{ mark_tmp }\n"
      link     = {:a, [href: "/uri", title: "title"], "link"}
      html     =  para([link, link])
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Images, and links with titles" do
    test "two titled images, different quotes" do
      markdown = ~s{![a](a 't') ![b](b "u")}
      html     = para([
        {:img, [src: "a", alt: "a", title: "t"], nil},
        {:img, [src: "b", alt: "b", title: "u"], nil}])
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

end
