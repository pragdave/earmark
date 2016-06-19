defmodule Helpers.InlineCodeTest.InlineCodeOpenedTest do
  use ExUnit.Case
  import Earmark.Helpers.LookaheadHelpers, only: [inline_code_opened?: 1]
  [
    { "empty line -> not a pending inline code", "", nil },
    { "no backquotes -> not a pending inline code", "Hello World", nil },
    { "closed backquotes --> not a pending inline code", "`a ``` b`c", nil },
    { "pair of backquotes, nested structs -> not pending", "`1 `` 2` `` ` `` >`< `` >`<", nil},
    { "pair of backquotes, some escapes -> not pending", "`1 `` 2` `` ` `` >`< `` \\`>`<", nil},

    { "one single backquote -> pending(`)", "`", "`" },
    { "one double backquote -> pending(``)", "``", "``" },
    { "triple backquote after some text -> pending(```)", "alpha```", "```" },
    { "single backquote in between -> pending(`)", "`1 `` 2` `` ` `` >`< ``", "`"},
    { "single backquote in between, some escapes -> pending(`)", "`1 `` 2` `` ` `` \\`>`< ``", "`"},
  ] |> Enum.each(fn { description, line, result } -> 
           test("inline_code_opened?: #{description}") do
             assert inline_code_opened?(unquote(line)) == unquote(result)
           end
         end)
end
