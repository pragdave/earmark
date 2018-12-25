defmodule Acceptance.Gfm.AutolinksTest do
  use ExUnit.Case

  # import Support.GfmHelpers, only: [gfm: 1, no_gfm: 1]
  import Support.AssertionHelper

  describe "autolinks inside `<` & `>` (explicit autolinks)" do
    # GFM Example 580
    acceptance(
      "<http://foo.bar.baz>",
      ~s{<p><a href="http://foo.bar.baz">http://foo.bar.baz</a></p>}
    )

    acceptance(
      "<http://foo.bar.baz>",
      ~s{<p><a href="http://foo.bar.baz">http://foo.bar.baz</a></p>},
      gfm: false
    )

    # GFM Example 581
    acceptance(
      "<http://foo.bar.baz/test?q=hello&id=22&boolean>",
      ~s{<p><a href="http://foo.bar.baz/test?q=hello&amp;id=22&amp;boolean">http://foo.bar.baz/test?q=hello&amp;id=22&amp;boolean</a></p>}
    )

    acceptance(
      "<http://foo.bar.baz/test?q=hello&id=22&boolean>",
      ~s{<p><a href="http://foo.bar.baz/test?q=hello&amp;id=22&amp;boolean">http://foo.bar.baz/test?q=hello&amp;id=22&amp;boolean</a></p>},
      gfm: false
    )

  end
end
