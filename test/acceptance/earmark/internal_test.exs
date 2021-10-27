defmodule Test.Acceptance.Earmark.InternalTest do
  use ExUnit.Case

  doctest Earmark.Internal, import: true

  import Earmark.Internal

  describe "from_file" do
    test "with no eex" do
      result = from_file!("test/fixtures/include/no_eex.md")
      assert result == "<p>\n&lt;%= this will be verbatim %&gt;</p>\n"
    end

    test "with eex" do
      result = from_file!("test/fixtures/include/basic.md.eex")
      assert result == "<h1>\nHeadline Level 1</h1>\n"
    end
  end

end
