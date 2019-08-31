defmodule Regressions.I270IncorrectPurelinkDeprecationWarningTest do
  use ExUnit.Case, async: true

  test "correct link in warning" do
    markdown = "http://some.url"
    html     = "<p>#{markdown}</p>\n"
    messages = [
      {:deprecation, 1,
    "The string \"#{markdown}\" will be rendered as a link if the option `pure_links` is enabled.\nThis will be the case by default in version 1.4.\nDisable the option explicitly with `false` to avoid this message."}
    ]

    assert Earmark.as_html(markdown) == {:ok, html, messages}
  end
end
