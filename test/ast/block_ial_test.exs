defmodule Acceptance.BlockIalTest do
  use ExUnit.Case

   describe "IAL" do

    test "Not associated" do
      markdown = "{:hello=world}"
      # html     = "<p>{:hello=world}</p>\n"
      ast = {"p", [], ["{:hello=world}"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "Not associated means verbatim" do
      markdown = "{: hello=world  }"
      # html     = "<p>{: hello=world  }</p>\n"
      ast = {"p", [], ["{: hello=world  }"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "Not associated and incorrect" do
      markdown = "{:hello}"
      # html     = "<p>{:hello}</p>\n"
      ast = {"p", [], ["{:hello}"]}
      messages = [{:warning, 1, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert Earmark.Interface.html(markdown) == {:error, ast, messages}
    end

    test "Associated" do
      markdown = "Before\n{:hello=world}"
      # html     = "<p hello=\"world\">Before</p>\n"
      ast = {"p", [{"hello", "world"}], ["Before"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "Associated in between" do
      markdown = "Before\n{:hello=world}\nAfter"
      # html     = "<p hello=\"world\">Before</p>\n<p>After</p>\n"
      ast = [{"p", [{"hello", "world"}], ["Before"]}, {"p", [], ["After"]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "Associated and incorrect" do
      markdown = "Before\n{:hello}"
      # html     = "<p>Before</p>\n"
      ast = {"p", [], ["Before"]}
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert Earmark.Interface.html(markdown) == {:error, ast, messages}
    end

    test "Associated and partly incorrect" do
      markdown = "Before\n{:hello title=world}"
      # html     = "<p title=\"world\">Before</p>\n"
      ast = {"p", [{"title", "world"}], ["Before"]}
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert Earmark.Interface.html(markdown) == {:error, ast, messages}
    end

    test "Associated and partly incorrect and shortcuts" do
      markdown = "Before\n{:#hello .alpha hello title=world .beta class=\"gamma\" title='class'}"
      # html     = "<p class=\"gamma beta alpha\" id=\"hello\" title=\"class world\">Before</p>\n"
      ast = {"p", [{"class", "gamma beta alpha"}, {"id", "hello"}, {"title", "class world"}], ["Before"]}
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert Earmark.Interface.html(markdown) == {:error, ast, messages}
    end

  end
end
