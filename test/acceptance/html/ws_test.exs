defmodule Acceptance.Html.WSTest do
  use Support.AcceptanceTestCase

  describe "do not add spurious WS (c.f. #371)" do

    test "making a point" do
      markdown = "**making a**."
      messages = []
      html     = "<p>\n<strong>making a</strong>.</p>\n"

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "we shall not separate" do
      markdown = "_man_ shall **not** _separate_."
      messages = []
      html     = "<p>\n<em>man</em> shall <strong>not</strong> <em>separate</em>.</p>\n"

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "we can be strong, may I emphasize that" do
      markdown = "**_we_**_are_*__strong__*."
      messages = []
      html     = "<p>\n<strong><em>we</em></strong><em>are</em><em><strong>strong</strong></em>.</p>\n"

      assert as_html(markdown) == {:ok, html, messages}
      
    end
  end
end
