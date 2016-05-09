defmodule Earmark.Helpers.LineHelpers do

  alias Earmark.Line

  def blank?(%Line.Blank{}),   do: true
  def blank?(_),               do: false
  
end
