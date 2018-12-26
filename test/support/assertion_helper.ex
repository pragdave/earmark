defmodule Support.AssertionHelper do

  defmacro assert_error act, exp, messages do
    quote bind_quoted: [act: act, exp: exp, messages: messages] do
      actual = 
      case act do
        {status, html, messages1} -> {status, String.replace(html, ~r{\n+}, ""), messages1}
      end
      expected = String.replace exp, ~r{\n+}, ""
      assert actual == {:ok, expected, messages} 
    end
  end

  defmacro assert_ok act, exp do
    quote bind_quoted: [act: act, exp: exp] do
      actual = 
      case act do
        {status, html, messages} -> {status, String.replace(html, ~r{\n+}, ""), messages}
      end
      expected = String.replace exp, ~r{\n+}, ""
      assert actual == {:ok, expected, []} 
    end
  end

  defmacro acceptance(md, html, options \\ []) do
    gfm      = Keyword.get(options, :gfm, true) 
    messages = Keyword.get(options, :messages, [])
    _acceptance(md, html, gfm, messages)
  end

  defp _acceptance(md, html, gfm, []) do
    quote do
      test "#{unquote(md)} becomes #{unquote(html)} with #{unquote(gfm)}" do
        actual = if unquote(gfm) do
          Earmark.as_html(unquote(md))
        else
          Earmark.as_html(unquote(md), %Earmark.Options{gfm: false})
        end
        assert_ok(actual, unquote(html))
      end
    end
  end
  defp _acceptance(md, html, gfm, messages) do
    quote do
      test "#{unquote(md)} becomes #{unquote(html)} with #{unquote(gfm)}" do
        actual = if unquote(gfm) do
          Earmark.as_html(unquote(md))
        else
          Earmark.as_html(unquote(md), %Earmark.Options{gfm: false})
        end
        assert_error(actual, unquote(html), unquote(messages))
      end
    end
  end
end
