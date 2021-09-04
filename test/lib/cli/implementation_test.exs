defmodule Test.Cli.ImplementationTest do
  use ExUnit.Case

  import Earmark.Cli.Implementation
  import Support.Earmark.SysInterface.Mock, only: [mock_stdio: 1]

  doctest Earmark.Cli.Implementation, import: true

  test "stdio as input" do
    mock_stdio(["- one\n- two"])
    expected = {:stdio, "<ul>\n  <li>\none  </li>\n</ul>\n"}
    result = run([])
    assert result == expected
  end

  describe "version" do
    test "--version" do
      assert run(~W[--version]) == {:stdio, Earmark.version}
    end
    test "-v" do
      assert run(~W[-v]) == {:stdio, Earmark.version}
    end
  end

  describe "help" do
    test "--help" do
      {:stderr, help_text} = run(~W[--help])
      help_lines = help_text
      |> String.split("\n")
      |> Enum.take(5)
      assert help_lines == ["usage:", "", "   earmark --help", "   earmark --version", "   earmark [ options... <file> ]"]
    end
    test "-h" do
      {:stderr, help_text} = run(~W[-h])
      help_lines = help_text
      |> String.split("\n")
      |> Enum.drop(3)
      |> Enum.take(5)
      assert help_lines == ["   earmark --version", "   earmark [ options... <file> ]", "", "convert file from Markdown to HTML.", ""]
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
