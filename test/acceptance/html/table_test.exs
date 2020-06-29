defmodule Acceptance.Html.TableTest do
  use Support.AcceptanceTestCase
  
  describe "Tables and IAL" do
    test "as mentioned above" do
      markdown = "|a|b|\n|d|e|\n{:#the-table}"
      html     = "<table id=\"the-table\">\n  <tbody>\n    <tr>\n      <td style=\"text-align: left;\">\na      </td>\n      <td style=\"text-align: left;\">\nb      </td>\n    </tr>\n    <tr>\n      <td style=\"text-align: left;\">\nd      </td>\n      <td style=\"text-align: left;\">\ne      </td>\n    </tr>\n  </tbody>\n</table>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "GFM Tables" do
    test "do not need spaces around mid `\|`" do
      markdown = "a|b\n-|-\nd|e\n"
      html     = "<table>\n  <thead>\n    <tr>\n      <th style=\"text-align: left;\">\na      </th>\n      <th style=\"text-align: left;\">\nb      </th>\n    </tr>\n  </thead>\n  <tbody>\n    <tr>\n      <td style=\"text-align: left;\">\nd      </td>\n      <td style=\"text-align: left;\">\ne      </td>\n    </tr>\n  </tbody>\n</table>\n"
      messages = []

      assert as_html(markdown, gfm_tables: true) == {:ok, html, messages}
    end

    test "do not need spaces around mid `\|` but w/o gfm_tables this is no good" do
      markdown = "a|b\n-|-\nd|e\n"
      html     = "<p>\na|b\n-|-\nd|e</p>\n"
      messages = []

      assert as_html(markdown, gfm_tables: false) == {:ok, html, messages}
    end
    test "however a header line needs to be used" do
      markdown = "a|b\nd|e\n"
      html     = "<p>\na|b\nd|e</p>\n"
      messages = []

      assert as_html(markdown, gfm_tables: true) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
