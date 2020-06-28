defmodule Acceptance.Ast.FootnotesTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 2]
  import EarmarkAstDsl

  describe "Footnotes" do

    test "without errors" do
      markdown = "foo[^1] again\n\n[^1]: bar baz"
      ast      = [
                {"p", '', ["foo", {"a", [{"href", "#fn:1"}, {"id", "fnref:1"}, {"class", "footnote"}, {"title", "see footnote"}], ["1"], %{}}, " again"], %{}},
                {
                  "div",
                  [{"class", "footnotes"}],
                  [
                    {"hr", '', '', %{}},
                    {
                      "ol",
                      '',
                      [
                        {
                          "li",
                          [{"id", "fn:1"}],
                          [
                            {
                              "p",
                              '',
                              ["bar baz", {"a", [{"class", "reversefootnote"}, {"href", "#fnref:1"}, {"title", "return to article"}], ["&#x21A9;"], %{}}],
                            %{}}
                          ],
                        %{}}
                      ],
                    %{}}
                  ],
                %{}}
              ]
        messages = []

        assert as_ast(markdown, footnotes: true) == {:ok, ast, messages}
    end

    test "undefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^2]: bar baz"
      ast      = p("foo[^1]\nhello")
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert as_ast(markdown, footnotes: true) == {:error, [ast], messages}
    end

    test "undefined footnotes (none at all)" do
      markdown = "foo[^1]\nhello"
      ast      = p("foo[^1]\nhello")
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert as_ast(markdown, footnotes: true) == {:error, [ast], messages}
    end

    test "illdefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^1]:bar baz"
      ast      = [p("foo[^1]\nhello"), p("[^1]:bar baz")]
      messages = [
        {:error, 1, "footnote 1 undefined, reference to it ignored"},
        {:error, 4, "footnote 1 undefined, reference to it ignored"}]

      assert as_ast(markdown, footnotes: true) == {:error, ast, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
