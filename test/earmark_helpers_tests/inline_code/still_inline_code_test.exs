defmodule Helpers.InlineCodeTest.StillInlineCodeTest do
  use ExUnit.Case
  import Earmark.Helpers.InlineCodeHelpers, only: [still_inline_code: 2]
  [
    { "empty line -> not closing for single backquote" , "`"  , ""    , {"`", false} },
    { "empty line -> not closing for double backquote" , "``" , ""    , {"``", false} },
    { "single backquote closes single backquote"       , "`"  , "`"   , {nil, false} },
    { "double backquote closes double backquote"       , "``" , " ``" , {nil, false} },
    { "pair of single backquotes does not close single backquote", "`", "alpha ` beta`", {"`", true}},
    { "odd number of single backquotes closes single backquote", "`", "` ` `", {nil, false}},
    { "escapes do not close",                            "`", "\\`", {"`", false}},
    { "escapes do not close, same line",                 "`", "`  ` \\`", {"`", true}},
    { "single backquote in quotes does not close single backquote", "`", "`` ` ``", {"``", true}},
    { "triple backqoute is closed but double is opened", "```", "``` ``", {"``", true}},
    { "triple backqoute is closed but single is opened", "```", "``` `` ``` ``` `", {"``", true}},
    { "backquotes before closing do not matter",         "``", "` ``", {nil, false}},
    { "backquotes before closing do not matter (reopening case)", "``", "` `` ```", {"```", true}},
    { "backquotes before closing and after opening do not matter", "``", "` `` ``` ````", {"```", true}},
  ] |> Enum.each( fn { description, opener, line, result } ->
         test(description) do
           assert still_inline_code(unquote(line), unquote(opener)) == unquote(result)
         end
       end)
end
