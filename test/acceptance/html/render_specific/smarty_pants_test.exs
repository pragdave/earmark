defmodule Acceptance.Html.RenderSpecific.SmartyPantsTest do
  use Support.AcceptanceTestCase

  @open_sgl_smarty  "\u2018"
  @close_sgl_smarty "\u2019"
  @open_dbl_smarty  "\u201c"
  @close_dbl_smarty "\u201d"

  describe "smarty pants on" do
    test "paired double" do
      markdown = "a \"double\" quote"
      html     = para("a #{dbl_quote("double")} quote")
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "unpaired double" do
      markdown = "a \"double\" \"quote"
      html     = para("a #{dbl_quote("double")} #{@open_dbl_smarty}quote")
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "two doubles" do
      markdown = "a \"double\" \"quote\""
      html     = para("a #{dbl_quote("double")} #{dbl_quote("quote")}")
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "paired single" do 
      markdown = "a 'single' quote"
      html     = para("a #{sgl_quote("single")} quote")
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "unpaired single" do
      markdown = "a 'single' 'quote"
      html     = para("a #{sgl_quote("single")} #{@open_sgl_smarty}quote")
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "two singles" do
      markdown = "a 'single' 'quote'"
      html     = para("a #{sgl_quote("single")} #{sgl_quote("quote")}")
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "a mess" do
      markdown = ~s{"a" 'messy' "affair"}
      html     = [dbl_quote("a"), sgl_quote("messy"), dbl_quote("affair")]
      |> Enum.join(" ")
      |> para()
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
  
  defp dbl_quote(str), do: Enum.join([@open_dbl_smarty, str, @close_dbl_smarty]) 
  defp sgl_quote(str), do: Enum.join([@open_sgl_smarty, str, @close_sgl_smarty]) 
end
