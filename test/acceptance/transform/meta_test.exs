defmodule Acceptance.Transform.MetaTest do
  use ExUnit.Case

  import Support.AstHelpers, only: [ast_from_md: 1]
  import Earmark.Transformers.Html
  
  describe "pre and verbatim" do
    @pre """
          some code
    """
    test "base case w/o verbatim" do
      ast = ast_from_md(@pre)
      expected = "<pre><code>  some code</code></pre>\n"

      assert ast_to_html(ast) == expected
    end
    test "base case with verbatim" do
      [{"pre", atts, children}] = ast_from_md(@pre)
      expected = "<pre><code>  some code</code></pre>\n"

      assert ast_to_html([{"pre", atts, children, %{meta: %{verbatim: true}}}]) == expected
    end
  end
end
