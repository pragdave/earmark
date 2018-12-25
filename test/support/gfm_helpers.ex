defmodule Support.GfmHelpers do
  @moduledoc false

  @doc false
  def gfm markdown do
    Earmark.as_html(markdown)
  end

  @doc false
  def no_gfm markdown do
    Earmark.as_html(markdown, %Earmark.Options{gfm: false})
  end
end
