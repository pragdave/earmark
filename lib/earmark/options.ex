defmodule Earmark.Options do
             # What we use to render
  defstruct  renderer: Earmark.HtmlRenderer,
             # Inline style options
             gfm: true, breaks: false, pedantic: false,
             smartypants: true, sanitize: false,
             footnotes: false, footnote_offset: 1,

             # Internal—only override if you're brave
             do_smartypants: nil, do_sanitize: nil,

             # Very internal—the callback used to perform
             # parallel rendering. Set to &Enum.map/2
             # to keep processing in process and
             # serial
             mapper: &Earmark.pmap/2,

             # Filename for meaningfull error messages
             filename: nil
end

