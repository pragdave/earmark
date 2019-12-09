defmodule Acceptance.Transformers.Html.Utf8Test do
  use ExUnit.Case, async: true
  import Support.Html1Helpers
  
  @moduletag :html1
  describe "valid rendering" do
    test "pure link" do
      markdown = " foo (http://test.com)… bar"
      html     = para([
        " foo (",
        {:a, ~s{href="http://test.com"},"http://test.com"},
        ")… bar"])
      
      {:ok, output, []} = to_html1(markdown)
      assert String.valid?(output)
      assert output == html
    end
  end
end
