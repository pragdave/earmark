defmodule Earmark.Restructure do

  @doc """
  Walks an AST and allows you to process it (storing details in acc) and/or
  modify it as it is walked.

  items is the AST you got from EarmarkParser.as_ast()

  acc is the initial value of an accumulator that is passed to both
  process_item_fn and process_list_fn and accumulated. If your functions
  do not need to use or store any state, you can pass nil.

  The process_item_fn function is required. It takes two parameters, the
  single item to process (which will either be a string or a 4-tuple) and
  the accumulator, and returns a tuple {processed_item, updated_acc}.
  Returning the empty list for processed_item will remove the item processed
  the AST.

  The process_list_fn function is optional and defaults to no modification of
  items or accumulator. It takes two parameters, the list of items that
  are the sub-items of a given element in the AST (or the top-level list of
  items), and the accumulator, and returns a tuple
  {processed_items_list, updated_acc}.

  This function ends up returning {ast, acc}.
  """
  def walk_and_modify_ast(items, acc, process_item_fn, process_list_fn \\ &({&1, &2}))
  when is_list(items) and is_function(process_item_fn) and is_function(process_list_fn)
  do
    {items, acc} = process_list_fn.(items, acc)
    {ast, acc} = Enum.map_reduce(items, acc, fn (item, acc) ->
      walk_and_modify_ast_item(item, acc, process_item_fn, process_list_fn)
    end)
    {List.flatten(ast), acc}
  end

  defp walk_and_modify_ast_item(item, acc, process_item_fn, process_list_fn) do
    case process_item_fn.(item, acc) do
      {{type, attribs, items, annotations}, acc}
      when is_binary(type) and is_list(attribs) and is_list(items) and is_map(annotations) ->
        {items, acc} = walk_and_modify_ast(items, acc, process_item_fn, process_list_fn)
        {{type, attribs, List.flatten(items), annotations}, acc}
      {item_or_items, acc} when is_binary(item_or_items) or is_list(item_or_items) ->
        {item_or_items, acc}
    end
  end

  @doc """
  Utility for creating a restructuring that parses text by splitting it into
  parts "of interest" vs. "other parts" using a regular expression.
  Returns a list of parts where the parts matching regex have been processed
  by invoking map_captures_fn on each part, and a list of remaining parts,
  preserving the order of parts from what it was in the plain text item.
  """
  def text_to_ast_list_splitting_regex(item, regex, map_captures_fn)
  when is_binary(item) and is_function(map_captures_fn) do
    interest_parts = Regex.scan(regex, item)
    |> Enum.map(map_captures_fn)
    other_parts = Regex.split(regex, item)
    # If the match is at the front of 'item', Regex.split will
    # return an empty string "before" the split. Therefore
    # the interest_parts always has either the same number of
    # elements as the other_parts list, or one fewer.
    zigzag_lists(other_parts, interest_parts)
  end

  @doc """
  Given two lists that are either of equal length, or with the first list
  exactly one element longer than the second, returns a list that begins with
  the first element from the first list, then the first element from the first
  list, and so forth until both lists are empty.
  """
  def zigzag_lists(first, second, acc \\ [])
  def zigzag_lists([], [], acc) do
    Enum.reverse(acc)
  end
  def zigzag_lists([first|first_rest], second, acc) do
    # Note that there will be no match for an empty 'first' list if 'second' is not empty,
    # and this for our use case is on purpose - the lists should either be equal in
    # length, or the first list as initially passed into the function should be one longer.
    zigzag_lists(second, first_rest, [first|acc])
  end
end
