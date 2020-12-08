defmodule Acceptance.PostprocessorTest do
  use ExUnit.Case


  describe "nop" do
    test "empty edge case" do
      assert post("", id())  == {:ok, [], []}
    end
    test "nop on ast" do
      assert post("hello", id())  == {:ok, [{"p", [], ["hello"], %{}}], []}
    end
  end

  describe "adding an attribute to all 'p' tags" do
    test "one level only" do
      assert post("hello", add_attr("p", :class, "classy")) ==
        {:ok, [{"p", [class: "classy"], ["hello"], %{}}], []}
    end
  end

  describe "ignoring strings (meaning leaves of the ast) allows for simpler traversal functions" do
    test "one level only" do
      assert post("hello", &transform/1, true) ==
        {:ok, [{"_p", [annotated: true], ["hello"], %{}}], []}
    end
    test "a complex example" do
      expected = {:ok, [
        {"_ul", [annotated: true],
          [
            {"_li", [annotated: true], ["hello"], %{}},
            {"_li", [annotated: true], [{"_strong", [annotated: true], ["world"], %{}}], %{}}], %{}}],
        []}
      assert post("* hello\n* **world**", &transform/1, true) == expected
    end
  end


  defp post(markdown, fun, ignore_strings \\ false) do
    Earmark.postprocessed_ast(markdown, %{postprocessor: fun, ignore_strings: ignore_strings})
  end
  defp id() do
    fn x -> x end 
  end
  defp add_attr(target, name, value) do
    fn {^target, atts, _, meta} -> {target, Keyword.put(atts, name, value), nil, meta}
      x -> x end
  end
  defp transform({tag, atts, _, meta}) do
    {"_#{tag}", Keyword.put(atts, :annotated, true), nil, meta}
  end
end
