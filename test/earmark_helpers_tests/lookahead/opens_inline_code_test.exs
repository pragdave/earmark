
defmodule Helpers.InlineCodeTest.OpensInlineCodeTest do
  use ExUnit.Case
  import Earmark.Helpers.LookaheadHelpers, only: [opens_inline_code: 1]
  [
    { "empty line -> not a pending inline code", "", {nil, 0} },
    { "escaped backquotes -> not a pending inline code", "\\`", {nil, 0}},
    { "no backquotes -> not a pending inline code", "Hello World", {nil, 0} },
    { "closed backquotes --> not a pending inline code", "`a ``` b`c", {nil, 0} },
    { "pair of backquotes, nested structs -> not pending", "`1 `` 2` `` ` `` >`< `` >`<", {nil, 0}},
    { "pair of backquotes, some escapes -> not pending", "`1 `` 2` `` ` `` >`< `` \\`>`<", {nil, 0}},
    { "pair of backquotes, some escaped escapes -> not pending", "`1 `` 2` `` ` `` >`< `` \\\\\\`>`<", {nil, 0}},
    { "single backquote in between, some escaped escapes -> not pending two", "`1 `` 2` `` ` `` \\\\`` >``<", {nil, 0}},

    { "one single backquote -> pending(`)", "`", {"`", 42} },
    { "escaped escape backquotes -> pending(``)", "\\\\`` ", {"``",42} },
    { "one double backquote -> pending(``)", "``", {"``", 42} },
    { "triple backquote after some text -> pending(```)", "alpha```", {"```", 42} },
    { "single backquote in between -> pending(`)", "`1 `` 2` `` ` `` >`< ``", {"`", 42}},
    { "single backquote in between, some escapes -> pending(`)", "`1 `` 2` `` ` `` \\`>`< ``", {"`", 42}},
    { "pair of backquotes, some escaped escapes -> pending", "`1 `` 2` `` ` `` ` `` \\\\`>`<", {"`",42}},
    { "single backquote in between, some escaped escapes -> pending one", "`1 `` 2` `` ` `` \\\\\\`` >``<", {"`", 42}},
  ] |> Enum.each(fn { description, line, result } ->
           test(description) do
             assert opens_inline_code(%{line: unquote(line), lnb: 42}) == unquote(result)
           end
         end)
end

# SPDX-License-Identifier: Apache-2.0
