defmodule Acceptance.DependencyTest do
  use ExUnit.Case

  test "correct parser version" do
    assert EarmarkParser.version == "1.4.12"
  end
end
