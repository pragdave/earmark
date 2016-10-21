defmodule Parser.VoidElementTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Block

  [
    {"area as void element", [~s{<area shape="rect" coords="there">}], [
      %Block.HtmlOther{attrs: nil, html: [~s{<area shape="rect" coords="there">}]}
    ]},
    {"area backwards compatibility", [~s{<area src="hello"></area>}], [
      %Block.HtmlOther{attrs: nil, html: [~s{<area src="hello"></area>}]}
    ]},

    {"br as void element", [~s{<br>}], [
      %Block.HtmlOther{attrs: nil, html: [~s{<br>}]}
    ]},
    {"br backwards compatibility", [~s{<br></br>}], [
      %Block.HtmlOther{attrs: nil, html: [~s{<br></br>}]}
    ]},

    {"hr as void element", [~s{<hr>}], [
      %Block.HtmlOther{attrs: nil, html: [~s{<hr>}]}
    ]},
    {"hr backwards compatibility", [~s{<hr></hr>}], [
      %Block.HtmlOther{attrs: nil, html: [~s{<hr></hr>}]}
    ]},

    {"img as void element", [~s{<img src="hello">}], [
      %Block.HtmlOther{attrs: nil, html: ["<img src=\"hello\">"]}
    ]},
    {"img backwards compatibility", [~s{<img src="hello"></img>}], [
      %Block.HtmlOther{attrs: nil, html: ["<img src=\"hello\"></img>"]}
    ]},
    ] |> Enum.each( fn {description, input, expect} ->
      test( description ) do
        {result, _} = Parser.parse(unquote(input))
        assert result == unquote(Macro.escape expect)
      end
    end)
end
