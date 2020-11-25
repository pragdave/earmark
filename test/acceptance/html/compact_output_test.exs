defmodule Acceptance.Html.CompactModeTest do
  use Support.AcceptanceTestCase

  describe "Compact output option" do
    test "avoids creating newlines" do
      markdown = "# h1\n## h2\n### h3\n\n**bold** text *italics*\n>blockquote\n1. list element\n2. list element \n\n `code` [link](http://example.com)"
      {:ok, html, _} = as_html(markdown, compact_output: true)
      refute html =~ "\n"
    end
   test "preserves newlines in code blocks" do
     markdown = """
                ```elixir
                  Earmark.as_html!(markdown, compact_output: true)
                  Earmark.as_html!(markdown, compact_output: false)
                ```
               """
     expected = "<pre><code class=\"elixir\">   Earmark.as_html!(markdown, compact_output: true)\n   Earmark.as_html!(markdown, compact_output: false)</code></pre>"
     {:ok, html, _} = as_html(markdown, compact_output: true)
     assert html == expected
   end
  end
end
