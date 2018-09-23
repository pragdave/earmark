defmodule Functional.Parser.Earmark2.SimpleTest do

  use ExUnit.Case
  import Earmark2.Parser, only: [parse_document: 1]

  describe "empty returns an empty ast with no errors" do

    test "empty" do
      ast = []
      errors = []
      assert parse_document("") == {ast, errors}
    end

    test "blank" do
      ast = []
      errors = []
      assert parse_document("\n") == {ast, errors}
    end

  end


  describe "pure text" do 
    
    test "hello world" do 
      ast = [{:para, [], ["hello world"]}]
      errors = []
      assert parse_document("hello world") == {ast, errors}
    end

    test "multiline" do
      ast = [{:para, [], ["hello", "world"]}]
      errors = []
      assert parse_document("hello\nworld") == {ast, errors}
    end
  end
  
end
