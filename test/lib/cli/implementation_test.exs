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
end
#  SPDX-License-Identifier: Apache-2.0
