defmodule Acceptance.Transform.MetaTest do
  use ExUnit.Case

  import Support.AstHelpers, only: [ast_from_md: 1]
  import Earmark.Transform
  
  # Needs to pass with #359
  @moduletag :wip
  describe "pre and verbatim" do
    @pre """
          some code
    """
    test "base case w/o verbatim" do
      ast = ast_from_md(@pre)
      expected = "<pre><code>  some code</code></pre>\n"

      assert transform(ast) == expected
    end
    test "base case with verbatim" do
      [{"pre", atts, children, _}] = ast_from_md(@pre)
      expected = "<pre><code>  some code</code></pre>\n"

      assert transform([{"pre", atts, children, %{verbatim: true}}]) == expected
    end
  end
end
