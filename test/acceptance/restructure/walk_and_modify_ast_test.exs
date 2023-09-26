defmodule Test.Restructure.WalkeAndModifyAstTest do
  use ExUnit.Case

  alias Earmark.Restructure

  doctest Restructure, import: true


  @doc """
  handle_italics is an example of a structure-changing function, that
  takes a non-standard markdown where / is used as an italics marker,
  parses for that within text items, and transforms a node containing
  such markdown into a new structure with an "em" node.
  """
  def handle_italics(ast) do
    ast
    |> Restructure.walk_and_modify_ast("", &handle_italics_impl/2)
    |> elem(0)
  end
  def handle_italics_impl(item, "a"), do: {item, ""}
  def handle_italics_impl(item, acc) when is_binary(item) do
    new_item = Restructure.split_by_regex(
      item,
      ~r/\/([[:graph:]].*?[[:graph:]]|[[:graph:]])\//,
      fn [_, content] ->
        {"em", [], [content], %{}}
      end
    )
    {new_item, acc}
  end
  def handle_italics_impl({name, _, _, _} = item, _acc) do
    # Store the last seen element name so we can skip handling
    # italics within <a> elements.
    {item, name}
  end

  @doc """
  handle_bold is an example of a mostly-structure-preserving function
  that simply changes the element type, again to deal with a non-standard
  markdown where a single * is used to indicate "strong" text.
  """
  def handle_bold(ast) do
    ast
    |> Restructure.walk_and_modify_ast(nil, &handle_bold_impl/2)
    |> elem(0)
  end
  def handle_bold_impl({"em", attribs, items, annotations}, acc) do
    {{"strong", attribs, items, annotations}, acc}
  end
  def handle_bold_impl(item, acc), do: {item, acc}

  @doc """
  An example of a structure-modifying function that operates on the
  list of items in an AST node, removing any italic ("em") items.
  """
  def delete_italicized_text(items, acc) do
    {
      Enum.flat_map(items, fn item ->
        case item do
          {"em", _, _, _} -> []
          _ -> [item]
        end
      end),
        acc
    }
  end

  test "handle_bold_and_italic_from_nonstandard_markdown" do
    markdown = "Hello *boldness* my /italic/ friend!"
    {:ok, ast, []} = markdown |> Earmark.Parser.as_ast()
    processed_ast = ast
                    |> handle_bold()
                    |> handle_italics()

    assert processed_ast == [
      {
        "p", [],
        [
          "Hello ",
          {"strong", [], ["boldness"], %{}},
          " my ",
          {"em", [], ["italic"], %{}},
          " friend!"
        ], %{}
      }
    ]
  end

  test "delete_italicized_text" do
    markdown = "Hello *there* my *good* friend!"
    {:ok, ast, []} = markdown |> Earmark.Parser.as_ast()
    {processed_ast, :acc_unused} = Restructure.walk_and_modify_ast(
      ast, :acc_unused, &({&1, &2}), &delete_italicized_text/2)
    assert processed_ast == [{"p", [], ["Hello ", " my ", " friend!"], %{}}]
  end

  test "prepared doctest" do
    is_comment? = fn item -> is_binary(item) && Regex.match?(~r/\A\s*--/, item) end
    comment_remover =
      fn items, acc -> {Enum.reject(items, is_comment?), acc} end
    italics_maker = fn
      item, acc when is_binary(item) ->
        new_item = Restructure.split_by_regex(
          item,
          ~r/\/([[:graph:]].*?[[:graph:]]|[[:graph:]])\//,
          fn [_, content] ->
            {"em", [], [content], %{}}
          end
        )
        {new_item, acc}
      item, "a" -> {item, nil}
      {name, _, _, _}=item, _ -> {item, name}
    end

    markdown = """
    [no italics in links](http://example.io/some/path)
    but /here/

    -- ignore me

    text
    """
    {:ok, ast, []} = Earmark.Parser.as_ast(markdown)
    Restructure.walk_and_modify_ast(ast, nil, italics_maker, comment_remover)
  end

  test "comments are ok" do
    markdown = """
    <!--Comment-->

    Hello world
    """

    {:ok, ast, []} = Earmark.Parser.as_ast(markdown)
    Restructure.walk_and_modify_ast(ast, nil, fn node, acc -> {node, acc} end)
  end
end
#  SPDX-License-Identifier: Apache-2.0
