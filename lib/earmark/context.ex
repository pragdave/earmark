defmodule Earmark.Context do
  defstruct options:  %Earmark.Options{},
            links:    Map.new,
            rules:    nil,
            footnotes: Map.new,
            messages: %Earmark.Messages{}
end
