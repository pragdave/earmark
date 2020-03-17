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
      Floki.parse(html) |> IO.inspect
    else
      Floki.parse(html)
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

end

# SPDX-License-Identifier: Apache-2.0
