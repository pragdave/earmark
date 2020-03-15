defmodule Acceptance.Html.TableTest do
  use Support.AcceptanceTestCase
  
  describe "Tables and IAL" do
    test "as mentioned above" do
      markdown = "|a|b|\n|d|e|\n{:#the-table}"
      html     = gen({:table, [id: "the-table"],
        {:tbody, [
          {:tr, [{:td, [style: "text-align: left;"], "a"},
            {:td, [style: "text-align: left;"], "b"}]},
          {:tr, [{:td, [style: "text-align: left;"], "d"},
            {:td, [style: "text-align: left;"], "e"}
          ]}]}})
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "GFM Tables" do
    test "do not need spaces around mid `\|`" do
      markdown = "a|b\n-|-\nd|e\n"
      html     = 
      """
      <table>
        <thead>
          <tr>
            <th style=\"text-align: left;\">
              a
            </th>
            <th style=\"text-align: left;\">
              b
            </th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td style=\"text-align: left;\">
              d
            </td>
            <td style=\"text-align: left;\">
              e
            </td>
          </tr>
        </tbody>
      </table>
      """
      messages = []

      assert as_html(markdown, gfm_tables: true) == {:ok, html, messages}
    end

    test "do not need spaces around mid `\|` but w/o gfm_tables this is no good" do
      markdown = "a|b\n-|-\nd|e\n"
      html     = "<p>\n  a|b\n-|-\nd|e\n</p>\n"
      messages = []

      assert as_html(markdown, gfm_tables: false) == {:ok, html, messages}
    end
    test "however a header line needs to be used" do
      markdown = "a|b\nd|e\n"
      html     = "<p>\n  a|b\nd|e\n</p>\n"
      messages = []

      assert as_html(markdown, gfm_tables: true) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
