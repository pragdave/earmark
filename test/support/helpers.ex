defmodule Support.Helpers do

  alias Earmark.Block.IdDef
  alias Earmark.Context
  alias Earmark.Inline

  ###############
  # Helpers.... #
  ###############

  def context do
    %Earmark.Context{}
  end

  def as_html(markdown, options \\ []) do
    Earmark.as_html(markdown, struct(Earmark.Options, options))
  end

  def as_html!(markdown, options \\ []) do
    Earmark.as_html!(markdown, struct(Earmark.Options, options))
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

  def convert_pedantic(string, lnb \\ 0) do
    Inline.convert(string, lnb, pedantic_context()).value
  end

  def convert_gfm(string, lnb \\ 0) do
    Inline.convert(string, lnb, gfm_context())
  end

end
