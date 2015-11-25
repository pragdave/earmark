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
  
  # closes_pending_inline_code
  [
    # description                                        opener line    result
    { "empty line -> not closing for single backquote" , "`"  , ""    , "`" },
    { "empty line -> not closing for double backquote" , "``" , ""    , "``" },
    { "single backquote closes single backquote"       , "`"  , "`"   , true },
    { "double backquote closes double backquote"       , "``" , " ``" , true },
    { "pair of single backquotes does not close single backquote", "`", "alpha ` beta`", "`"},
    { "odd number of single backquotes closes single backquote", "`", "` ` `", true},
    { "escapes do not close",                            "`", "`  ` \\`", "`"},
    { "single backquote in quotes does not close single backquote", "`", "`` ` ``", "`"},
    { "triple backqoute is closed but double is opened", "```", "``` `` ``", "``"},
    { "triple backqoute is closed but single is opened", "```", "``` `` ``` ``` `", "`"},
    ] |> Enum.each( fn { description, opener, line, result } ->
           test(description) do
             assert closes_pending_inline_code(unquote(line), unquote(opener)) == unquote(result)
           end
         end)
         
end
