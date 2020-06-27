defmodule Support.Helpers do

  alias Earmark.Block.IdDef
  alias Earmark.Context

  ###############
  # Helpers.... #
  ###############

  def context do
    %Earmark.Context{}
  end

  def as_ast(markdown, options \\ []) do
    Earmark.as_ast(markdown, struct(Earmark.Options, options))
  end

  def as_html(markdown, options \\ []) do
    Earmark.as_html(markdown, struct(Earmark.Options, options))
  end

  def as_html!(markdown, options \\ []) do
    Earmark.as_html!(markdown, struct(Earmark.Options, options))
  end

  def parse_html(html) do
    if System.get_env("DEBUG") do
      Floki.parse(html) |> _add_4th() |> IO.inspect
    else
      Floki.parse(html) |> _add_4th()
    end
  end

  def test_links do
    [
     {"id1", %IdDef{url: "url 1", title: "title 1"}},
     {"id2", %IdDef{url: "url 2"}},

     {"img1", %IdDef{url: "img 1", title: "image 1"}},
     {"img2", %IdDef{url: "img 2"}},
    ]
    |> Enum.into(Map.new)
  end

  def pedantic_context do
    ctx = put_in(context().options.gfm, false)
    ctx = put_in(ctx.options.pedantic, true)
    ctx = put_in(ctx.links, test_links())
    Context.update_context(ctx)
  end

  def gfm_context do
    Context.update_context(context())
  end

  defp _add_4th(node)
  defp _add_4th(nodes) when is_list(nodes) do
    nodes
    |> Enum.map(&_add_4th/1)
  end
  defp _add_4th({t, a, c}) do
    {t, a, _add_4th(c), %{}}
  end
  defp _add_4th({:comment, content}) do
    {:comment, [], content, %{comment: true}}
  end
  defp _add_4th(other), do: other

end

# SPDX-License-Identifier: Apache-2.0
