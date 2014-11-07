defmodule HtmlRendererTest do
  use ExUnit.Case

  import Earmark.HtmlRenderer, only: [ expand: 2, add_attrs: 2, add_attrs: 3 ]

  # This is just for the internals...

  def h(enum), do: Enum.into(enum, HashDict.new)

  def newh, do: h([])

  test "expand single class attr" do
    assert expand(newh(), ".one ") == h([{"class", ["one"]}])
  end

  test "expand two class attrs" do
    assert expand(newh(), ".one .two") == h([{"class", ["two", "one"]}])
  end

  test "expand single id attr" do
    assert expand(newh(), "#one ") == h([{"id", ["one"]}])
  end

  test "expand named attribute" do
    assert expand(newh(), "name=value") == h([{"name", ["value"]}])
  end

  test "expand single-quoted named attribute" do
    assert expand(newh(), "name='value'") == h([{"name", ["value"]}])
  end

  test "expand double-quoted named attribute" do
    assert expand(newh(), "name=\"attr value\"") == h([{"name", ["attr value"]}])
  end

  test "expand multiple types of attribute" do
    assert expand(newh(), ".class #id name=\"attr value\" .class2") ==
        h([{"name", ["attr value"]}, {"id", ["id"]}, {"class", ["class2", "class"]}])
  end

  test "text unchanged if no attributes" do
    assert add_attrs("<p>xxx</p>", nil) == "<p>xxx</p>"
  end

  test "class attribute added" do
    assert add_attrs("<p>xxx</p>", ".one") == "<p class=\"one\">xxx</p>"
  end

  test "id attribute added" do
    assert add_attrs("<p>xxx</p>", "#one") == "<p id=\"one\">xxx</p>"
  end

  test "multiple attributes added" do
    assert add_attrs("<p>xxx</p>", "#one .two name=value") == 
      "<p name=\"value\" id=\"one\" class=\"two\">xxx</p>"
  end

  test "merges additional attributes" do
    assert add_attrs("<p>xxx</p>", ".one", [{"class", ["two"]}]) ==
      "<p class=\"one two\">xxx</p>"
  end

  test "merges additional different attributes" do
    assert add_attrs("<p>xxx</p>", ".one", [{"id", ["two"]}]) ==
      "<p id=\"two\" class=\"one\">xxx</p>"
  end

end
