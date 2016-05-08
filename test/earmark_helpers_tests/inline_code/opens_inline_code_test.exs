
defmodule Helpers.InlineCodeTest.OpensInlineCodeTest do
  use ExUnit.Case
  import Earmark.Helpers.InlineCodeHelpers, only: [opens_inline_code: 1]
  [
    { "empty line -> not a pending inline code", "", {nil, false} },
    { "no backquotes -> not a pending inline code", "Hello World", {nil, false} },
    { "closed backquotes --> not a pending inline code", "`a ``` b`c", {nil, false} },
    { "pair of backquotes, nested structs -> not pending", "`1 `` 2` `` ` `` >`< `` >`<", {nil, false}},
    { "pair of backquotes, some escapes -> not pending", "`1 `` 2` `` ` `` >`< `` \\`>`<", {nil, false}},

    { "one single backquote -> pending(`)", "`", {"`", true} },
    { "one double backquote -> pending(``)", "``", {"``", true} },
    { "triple backquote after some text -> pending(```)", "alpha```", {"```", true} },
    { "single backquote in between -> pending(`)", "`1 `` 2` `` ` `` >`< ``", {"`", true}},
    { "single backquote in between, some escapes -> pending(`)", "`1 `` 2` `` ` `` \\`>`< ``", {"`", true}}
  ] |> Enum.each(fn { description, line, result } -> 
           test(description) do
             assert opens_inline_code(unquote(line)) == unquote(result)
           end
         end)
end
