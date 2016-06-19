defmodule Helpers.InlineCodeTest.InlineCodeContinuesTest do
  use ExUnit.Case
  import Earmark.Helpers.LookaheadHelpers, only: [inline_code_continues?: 2]
  [
    { "empty line -> not closing for single backquote" , "`"  , ""    , "`" },
    { "empty line -> not closing for double backquote" , "``" , ""    , "``" },
    { "single backquote closes single backquote"       , "`"  , "`"   , nil },
    { "double backquote closes double backquote"       , "``" , " ``" , nil },
    { "pair of single backquotes does not close single backquote", "`", "alpha ` beta`", "`"},
    { "odd number of single backquotes closes single backquote", "`", "` ` `", nil},
    { "escapes do not close",                            "`", "\\`", "`"},
    { "escapes do not close, same line",                 "`", "`  ` \\`", "`"},
    { "single backquote in doublequotes reopens double", "`", "`` ` ``", "``"},
    { "triple backqoute is closed but double is opened", "```", "``` ``", "``"},
    { "triple backqoute is closed but single is opened", "```", "``` `` ``` ``` `", "``"},
    { "backquotes before closing do not matter",         "``", "` ``", nil},
    { "backquotes before closing do not matter (reopening case)", "``", "` `` ```", "```"},
    { "backquotes before closing and after opening do not matter", "``", "` `` ``` ````", "```"},
  ] |> Enum.each( fn { description, opener, line, result } ->
         test("inline_code_continues?: #{description}") do
           assert inline_code_continues?( unquote(line), unquote(opener)) == unquote(result)
         end
       end)
end
