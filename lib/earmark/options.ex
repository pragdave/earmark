defmodule Earmark.Options do

  @type t :: %__MODULE__{}

  # What we use to render
  defstruct  renderer: Earmark.HtmlRenderer,
             # Inline style options
             gfm: true, breaks: false, pedantic: false,
             smartypants: true, sanitize: false,
             footnotes: false, footnote_offset: 1,

             # additional prefies for class of code blocks
             code_class_prefix: nil,

             # Internal—only override if you're brave
             do_smartypants: nil, do_sanitize: nil,

             # Very internal—the callback used to perform
             # parallel rendering. Set to &Enum.map/2
             # to keep processing in process and
             # serial
             mapper: &Earmark.pmap/2,

             render_code: &Earmark.HtmlRenderer.render_code/1,

             # Filename and initial line number of the markdown block passed in
             # for meaningfull error messages
             file: "<no file>",
             line: 1,
             messages: [], # [{:error|:warning, lnb, text},...]
             plugins: %{}


  def plugin_for_prefix(options, plugin_name) do
    Map.get(options.plugins, plugin_name, false)
  end

end

# SPDX-License-Identifier: Apache-2.0
