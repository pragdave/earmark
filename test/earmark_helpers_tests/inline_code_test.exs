defmodule Helpers.InlineCodeTest do
  use ExUnit.Case
  import Earmark.Helpers, only: [still_pending_inline_code: 2, pending_inline_code: 1]

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
  
  # still_pending_inline_code
  [
    # description                                        opener line    result
    { "empty line -> not closing for single backquote" , "`"  , ""    , "`" },
    { "empty line -> not closing for double backquote" , "``" , ""    , "``" },
    { "single backquote closes single backquote"       , "`"  , "`"   , false },
    { "double backquote closes double backquote"       , "``" , " ``" , false },
    { "pair of single backquotes does not close single backquote", "`", "alpha ` beta`", "`"},
    { "odd number of single backquotes closes single backquote", "`", "` ` `", false},
    { "escapes do not close",                            "`", "`  ` \\`", "`"},
    { "single backquote in quotes does not close single backquote", "`", "`` ` ``", "`"},
    { "triple backqoute is closed but double is opened", "```", "``` ``", "``"},
    { "triple backqoute is closed but single is opened", "```", "``` `` ``` ``` `", "``"},
    { "backquotes before closing do not matter",         "``", "` ``", false},
    { "backquotes before closing do not matter (reopening case)", "``", "` `` ```", "```"},
    { "backquotes before closing and after opening do not matter", "``", "` `` ``` ````", "```"},
  ] |> Enum.each( fn { description, opener, line, result } ->
         test(description) do
           assert still_pending_inline_code(unquote(line), unquote(opener)) == unquote(result)
         end
       end)
         
end
