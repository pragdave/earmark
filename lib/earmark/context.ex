defmodule Earmark.Options do

  
             # what we use to render
  defstruct  renderer: Earmark.HtmlRenderer,

             # inline style options  
             gfm: true, breaks: false, pedantic: false,
             smartypants: true, sanitize: false,
             footnotes: false,

             # Internal—only override if you're brave
             do_smartypants: nil, do_sanitize: nil
end

defmodule Earmark.Context do
  defstruct options:  %Earmark.Options{},
            links:    HashDict.new,
            rules:    nil,
            footnotes: HashDict.new

end
