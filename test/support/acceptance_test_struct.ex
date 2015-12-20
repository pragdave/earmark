defmodule Support.AcceptanceTestStruct do
  @moduledoc """
  A struct representing an acceptance test that will be created from the json file `../assets/tests.json`
  in `../acceptance/acceptance_test_creator.exs`
  """
  defstruct section: nil, example: nil, html: nil, markdown: nil
end
