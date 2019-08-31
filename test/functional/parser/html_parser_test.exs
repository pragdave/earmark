defmodule Functional.Parser.HtmlParserTest do
  use ExUnit.Case, async: true
  import Earmark.Helpers.HtmlParser

  describe "not a tag" do
    test "empty" do
      input = ""
      assert parse_html(input) == input
    end

    test "not a tag" do
      input = "<hello"
      assert parse_html(input) == input
    end

    test "still not a tag" do
      input = "<hello class='world'"
      assert parse_html(input) == input
    end
    
    test "definitely not a tag" do
      input = "<a><br>"
      assert parse_html(input) == input
    end
  end

  describe "empty tags" do
    test "no attributes recommended format" do
      input = "<br />"
      assert {"br", []} == parse_html(input)
    end
    test "no attributes" do
      input = "<br/>"
      assert {"br", []} == parse_html(input)
    end
    test "no attributes, baaad" do
      input = "<br>"
      assert {"br", []} == parse_html(input)
    end

    test "attributes recommended" do
      input = "<hr class='thin' />"
      assert {"hr", [{"class", "thin"}]} == parse_html(input)
    end

    test "order of atts and quoting" do
      input = ~s{  <img  src="alpha" alt="look'ma" data-helper='***---"---___' />}
      expected_atts = [
        {"src", "alpha"},
        {"alt", "look'ma"},
        {"data-helper", ~s{***---"---___}}
      ]

      assert {"img", expected_atts} == parse_html(input)
    end
  end

  describe "normal tags, (N.B.: no difference in the given context)" do
    test "just another example" do
      input = ~s{<div  id="alpha" class="look-ma" data-helper='***---"---___'> }
      expected_atts = [
        {"id", "alpha"},
        {"class", "look-ma"},
        {"data-helper", ~s{***---"---___}}
      ]

      assert {"div", expected_atts} == parse_html(input)
    end
  end

  describe "closing tags" do
    test "no fuss case" do
      input = "</div>"

      assert parse_html(input) == {"div"}
    end

    test "some noise" do
      input = "  </span>rubbish"

      assert parse_html(input) == {"span"}
    end
  end
end
