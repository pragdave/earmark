defmodule Helpers.InlineCodeTest.StillInlineCodeTest do
  use ExUnit.Case
  import Earmark.Helpers.InlineCodeHelpers, only: [still_inline_code: 2]
  [
    { "empty line -> not closing for single backquote" , "`"  , ""    , {"`", 42} },
    { "empty line -> not closing for double backquote" , "``" , ""    , {"``", 42} },
    { "single backquote closes single backquote"       , "`"  , "`"   , {nil, 0} },
    { "double backquote closes double backquote"       , "``" , " ``" , {nil, 0} },
    { "pair of single backquotes does not close single backquote", "`", "alpha ` beta`", {"`", 42}},
    { "odd number of single backquotes closes single backquote", "`", "` ` `", {nil, 0}},
    { "escapes do not close",                            "`", "\\`", {"`", 42}},
    { "escapes do not close, same line",                 "`", "`  ` \\`", {"`", 42}},
    { "single backquote in quotes does not close single backquote", "`", "`` ` ``", {"``", 42}},
    { "triple backqoute is closed but double is opened", "```", "``` ``", {"``", 42}},
    { "triple backqoute is closed but single is opened", "```", "``` `` ``` ``` `", {"``", 42}},
    { "backquotes before closing do not matter",         "``", "` ``", {nil, 0}},
    { "backquotes before closing do not matter (reopening case)", "``", "` `` ```", {"```", 42}},
    { "backquotes before closing and after opening do not matter", "``", "` `` ``` ````", {"```", 42}},
  ] |> Enum.each( fn { description, opener, line, result } ->
         test(description) do
           assert still_inline_code(%{line: unquote(line), lnb: 42}, unquote(opener)) == unquote(result)
         end
       end)
end
