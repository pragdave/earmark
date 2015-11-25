defmodule Helpers.InlineCodeTest do
  use ExUnit.Case
  import Earmark.Helpers, only: [closes_pending_inline_code: 2, pending_inline_code: 1]

  # pending_inline_code
  [
    { "empty line -> not a pending inline code", "", false },
    { "no backquotes -> not a pending inline code", "Hello World", false },
    { "closed backquotes --> not a pending inline code", "`a ``` b`c", false },
    { "pair of backquotes, nested structs -> not pending", "`1 `` 2` `` ` `` >`< `` >`<", false},
    { "pair of backquotes, some escapes -> not pending", "`1 `` 2` `` ` `` >`< `` \\`>`<", false},

    { "one single backquote -> pending(`)", "`", "`" },
    { "one double backquote -> pending(``)", "``", "``" },
    { "triple backquote after some text -> pending(```)", "alpha```", "```" },
    { "single backquote in between -> pending(`)", "`1 `` 2` `` ` `` >`< ``", "`"},
    { "single backquote in between, some escapes -> pending(`)", "`1 `` 2` `` ` `` \\`>`< ``", "`"}

  ] |> Enum.each(fn { description, line, result } -> 
           test(description) do
             assert pending_inline_code(unquote(line)) == unquote(result)
           end
         end)
  
end
