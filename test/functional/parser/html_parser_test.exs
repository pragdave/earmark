defmodule Functional.Parser.HtmlParserTest do
  use ExUnit.Case, async: true
  import Earmark.Helpers.HtmlParser

  describe "not a tag" do
    test "empty" do
      input = [""]
      assert parse_html(input) == input
    end

    test "not a tag" do
      input = ["<hello"]
      assert parse_html(input) == input
    end

    test "still not a tag" do
      input = ["<hello class='world'"]
      assert parse_html(input) == input
    end
    
    test "this is now a tag" do
      input = ["<a><br>"]
      assert parse_html(input) == [{"a", [], ["<br>"]}] 
    end
  end

  describe "empty tags" do
    test "no attributes recommended format" do
      input = ["<br />"]
      assert parse_html(input) == [{"br", [], []}]
    end
    test "no attributes" do
      input = ["<br/>"]
      assert parse_html(input) == [{"br", [], []}]
    end
    test "no attributes, baaad" do
      input = ["<br>"]
      assert parse_html(input) == [{"br", [], []}]
    end

    test "attributes recommended" do
      input = ["<hr class='thin' />"]
      assert parse_html(input) == [{"hr", [{"class", "thin"}], []}]
    end

    test "a bad case of appendicitis" do
      input = ["<hr class='thin' /> appendix"]
      assert parse_html(input) == [{"hr", [{"class", "thin"}], []}, ["appendix"]]
    end

    test "order of atts and quoting" do
      input = [~s{  <img  src="alpha" alt="look'ma" data-helper='***---"---___' />}]
      expected_atts = [
        {"src", "alpha"},
        {"alt", "look'ma"},
        {"data-helper", ~s{***---"---___}}
      ]

      assert parse_html(input) == [{"img", expected_atts, []}]
    end
  end

  describe "normal tags, (N.B.: no difference in the given context)" do
    test "simple atts" do
      input = ["<hr class='thin' />"]
      assert parse_html(input) == [{"hr", [{"class", "thin"}], []}]
    end
    test "just another example" do
      input = [~s{<div  id="alpha" class="look-ma" data-helper='***---"---___'> }]
      expected_atts = [
        {"id", "alpha"},
        {"class", "look-ma"},
        {"data-helper", ~s{***---"---___}}
      ]

      assert parse_html(input) == [{"div", expected_atts, []}]
    end
  end

end
