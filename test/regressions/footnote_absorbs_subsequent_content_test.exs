defmodule Regressions.FootnoteAbsorbsSubsequentContentTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_ast: 2]

  test "content after a footnote definition stays at the top level" do
    markdown = """
    Before first[^1].

    [^1]: First footnote.

    Between footnotes[^2].

    [^2]: Second footnote.

    After all.
    """

    {:ok, ast, _} = as_ast(markdown, gfm: true, footnotes: true)

    assert [
             {"p", [], ["Before first", {"a", _, ["1"], %{}}, "."], %{}},
             {"p", [], ["Between footnotes", {"a", _, ["2"], %{}}, "."], %{}},
             {"p", [], ["After all."], %{}},
             {"div", [{"class", "footnotes"}],
              [
                {"hr", [], [], %{}},
                {"ol", [],
                 [
                   {"li", [{"id", "fn:1"}],
                    [
                      {"a", _, ["&#x21A9;"], %{}},
                      {"p", [], ["First footnote."], %{}}
                    ], %{}},
                   {"li", [{"id", "fn:2"}],
                    [
                      {"a", _, ["&#x21A9;"], %{}},
                      {"p", [], ["Second footnote."], %{}}
                    ], %{}}
                 ], %{}}
              ], %{}}
           ] = ast
  end
end

# SPDX-License-Identifier: Apache-2.0
