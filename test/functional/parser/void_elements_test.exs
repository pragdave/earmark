defmodule Parser.VoidElementTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Block

  [
    {"area as void element", [~s{<area shape="rect" coords="there">}], [
      %Block.HtmlOther{lnb: 1, attrs: nil, html: [~s{<area shape="rect" coords="there">}]}
    ]},
    {"area backwards compatibility", [~s{<area src="hello"></area>}], [
      %Block.HtmlOther{lnb: 1, attrs: nil, html: [~s{<area src="hello"></area>}]}
    ]},

    {"br as void element", [~s{<br>}], [
      %Block.HtmlOther{lnb: 1, attrs: nil, html: [~s{<br>}]}
    ]},
    {"br backwards compatibility", [~s{<br></br>}], [
      %Block.HtmlOther{lnb: 1, attrs: nil, html: [~s{<br></br>}]}
    ]},

    {"hr as void element", [~s{<hr>}], [
      %Block.HtmlOther{lnb: 1, attrs: nil, html: [~s{<hr>}]}
    ]},
    {"hr backwards compatibility", [~s{<hr></hr>}], [
      %Block.HtmlOther{lnb: 1, attrs: nil, html: [~s{<hr></hr>}]}
    ]},

    {"img as void element", [~s{<img src="hello">}], [
      %Block.HtmlOther{lnb: 1, attrs: nil, html: ["<img src=\"hello\">"]}
    ]},
    {"img backwards compatibility", [~s{<img src="hello"></img>}], [
      %Block.HtmlOther{lnb: 1, attrs: nil, html: ["<img src=\"hello\"></img>"]}
    ]},
    ] |> Enum.each( fn {description, input, expect} ->
      test( description ) do
        {result, _, _} = Parser.parse(unquote(input))
        assert result == unquote(Macro.escape expect)
      end
    end)
end
