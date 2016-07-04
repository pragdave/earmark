defmodule Helpers.InlineCodeTest.StillInlineCodeTest do
  use ExUnit.Case
  import Earmark.Helpers.LookaheadHelpers, only: [still_inline_code: 2]
  [
    { "empty line -> not closing for single backquote" , "`"  , ""    , {"`", 24} },
    { "empty line -> not closing for double backquote" , "``" , ""    , {"``", 24} },
    { "single backquote closes single backquote"       , "`"  , "`"   , {nil, 0} },
    { "double backquote closes double backquote"       , "``" , " ``" , {nil, 0} },
    { "pair of single backquotes does not close single backquote", "`", "alpha ` beta`", {"`", 42}},
    { "odd number of single backquotes closes single backquote", "`", "` ` `", {nil, 0}},
    { "escapes do not close",                            "`", "\\`", {"`", 24}},
    { "escaped escapes close",                           "`", "\\\\`", {nil, 0}},
    { "escapes do not close, same line",                 "`", "`  ` \\`", {"`", 42}},
    { "escaped escapes close, same line",                 "`", "`  ` \\\\`", {nil, 0}},
    { "single backquote in doublequotes reopens double", "`", "`` ` ``", {"``", 42}},
    { "triple backqoute is closed but double is opened", "```", "``` ``", {"``", 42}},
    { "triple backqoute is closed but single is opened", "```", "``` `` ``` ``` `", {"``", 42}},
    { "backquotes before closing do not matter",         "``", "` ``", {nil, 0}},
    { "backquotes before closing do not matter (reopening case)", "``", "` `` ```", {"```", 42}},
    { "backquotes before closing and after opening do not matter", "``", "` `` ``` ````", {"```", 42}},
  ] |> Enum.each( fn { description, opener, line, result } ->
         test(description) do
           assert still_inline_code(%{line: unquote(line), lnb: 42}, {unquote(opener), 24}) == unquote(result)
         end
       end)
end
