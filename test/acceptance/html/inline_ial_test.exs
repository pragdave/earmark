defmodule Acceptance.Html.InlineIalTest do
  use Support.AcceptanceTestCase

  describe "IAL no errors" do
    test "link with simple ial" do
      markdown = "[link](url){: .classy}"
      html = gen({:p, {:a, [class: "classy", href: "url"], "link"}})
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Error Handling" do

    test "illegal format line two" do
      markdown = "a line\n[link](url) {:incorrect x=y}"
      html = para(["a line\n", {:a, [href: "url", x: "y"], "link"}])
      messages = [{:warning, 2, "Illegal attributes [\"incorrect\"] ignored in IAL"}]

      assert as_html(markdown) == {:error, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
