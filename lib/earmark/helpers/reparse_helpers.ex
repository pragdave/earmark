defmodule Earmark.Helpers.ReparseHelpers do

  alias Earmark.Line
  
  @doc """
    Extract the verbatim text of `%Earmark.Line.t` elements with less alignment so that
    it can be reparsed (as elements of list items).
  """
  # In case we are inside a code block we return the verbatim text
  def indent_list_item_body(%{inside_code: true, line: line}, _level) do
    line
  end
  # Sublistitems are **always** 2 spaces relative to the main list
  def indent_list_item_body(%Line.ListItem{line: line}, _target_level) do
    String.slice(line, 2..-1)
  end
  # Add additional spaces for any indentation past level 1
  def indent_list_item_body(%Line.Indent{level: level, content: content}, target_level)
  when level * 4 == target_level do
    content
  end

  def indent_list_item_body(%Line.Indent{level: level, content: content}, target_level)
  when level * 4  > target_level do
    String.duplicate(" ", level *4 - target_level) <> content
  end

  def indent_list_item_body(line, _) do
    line.content
  end


  @doc """
    Extract the verbatim text of `%Earmark.Line.t` elements with less alignment so that
    it can be reparsed (as elements of footnotes or indented code)
  """
  # In case we are inside a code block we return the verbatim text
  def properly_indent(%{inside_code: true, line: line}, _level) do
    line
  end
  # Add additional spaces for any indentation past level 1
  def properly_indent(%Line.Indent{level: level, content: content}, target_level)
  when level == target_level do
    content
  end
  def properly_indent(%Line.Indent{level: level, content: content}, target_level)
  when level > target_level do
    String.duplicate("    ", level-target_level) <> content
  end
  def properly_indent(line, _) do
    line.content
  end
end

# SPDX-License-Identifier: Apache-2.0
