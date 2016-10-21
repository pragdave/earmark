defmodule OptionsTest do
  use ExUnit.Case
  alias Earmark.Options, as: O
  
  test "into: empty -> empty" do 
    assert  Enum.into([], %O{}) == %O{}
  end
  test "into: singleton -> empty" do 
    assert  Enum.into([gfm: true], %O{}) == %O{gfm: true}
  end
  test "into: singleton -> singleton" do 
    assert Enum.into([code_class_prefix: "a-"], %O{gfm: true}) == %O{gfm: true, code_class_prefix: "a-"}
  end
  test "into: messy case" do 
    assert Enum.into([code_class_prefix: "a-", pedantic: true, file: "beta"],
      %O{gfm: true, file: "alpha"}) == 
       %O{gfm: true, code_class_prefix: "a-", pedantic: true, file: "beta"}
  end

end
