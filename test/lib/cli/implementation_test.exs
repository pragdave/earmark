defmodule Test.Cli.ImplementationTest do
  use ExUnit.Case

  import Earmark.Cli.Implementation
  import Support.Earmark.SysInterface.Mock, only: [mock_stdio: 1]

  doctest Earmark.Cli.Implementation, import: true

  describe "stdio" do
    test "w/o --eex" do
      mock_stdio(["- one\n- two"])
      expected = {:stdio, "<ul>\n  <li>\none  </li>\n</ul>\n"}
      result = run([])
      assert result == expected
    end
    test "with --eex" do
      mock_stdio(["<%= 1+1 %>"])
      expected = {:stdio, "<p>\n2</p>\n"}
      result = run(~W[--eex])
      assert result == expected
    end
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
  
  describe "illegal options" do
    test "--unknown" do
      assert run(~W[--unknown]) == {:stderr, "Illegal options --unknown"}
    end
    test "mix of correct and incorrect" do
      assert run(~W[-h -i --code-class-prefix elixir --unknown]) == {:stderr, "Illegal options -i, --unknown"}
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
