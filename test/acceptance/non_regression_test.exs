defmodule Acceptance.NonRegressionTest do
  use ExUnit.Case
  import Support.Performance, only: [convert_file: 2]

  describe "Just assure that nothing really bad happenes when we convert some common Markdown" do
    test "READMEs" do
      convert_file("elixir_readmes.md", :html)
    end

    test "hexdocs" do
      convert_file("elixir_hexdocs.md", :html)
    end
  end
end
