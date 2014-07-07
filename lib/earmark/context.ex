defmodule Earmark.Context.Options do

  # inline style options
  defstruct  gfm: true, breaks: true, pedantic: false,
             smartypants: true, sanitize: false,
             do_smartypants: nil, do_sanitize: nil
end

defmodule Earmark.Context do
  defstruct options:  %Earmark.Context.Options{},
            links:    HashDict.new,
            renderer: Earmark.HtmlRenderer,
            rules:    nil

end