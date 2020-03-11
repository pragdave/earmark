defmodule Earmark.Options do

  use Earmark.Types

  # What we use to render
  defstruct renderer: Earmark.HtmlRenderer,
            # Inline style options
            gfm: true,
            gfm_tables: false,
            breaks: false,
            pedantic: false,
            smartypants: true,
            footnotes: false,
            footnote_offset: 1,

            # additional prefies for class of code blocks
            code_class_prefix: nil,

            # Add possibility to specify a timeout for Task.await
            timeout: nil,

            # Internal—only override if you're brave
            do_smartypants: nil,

            # Very internal—the callback used to perform
            # parallel rendering. Set to &Enum.map/2
            # to keep processing in process and
            # serial
            mapper: &Earmark.pmap/2,
            mapper_with_timeout: &Earmark.pmap/3,
            render_code: &Earmark.HtmlRenderer.render_code/1,

            # Filename and initial line number of the markdown block passed in
            # for meaningfull error messages
            file: "<no file>",
            line: 1,
            # [{:error|:warning, lnb, text},...]
            messages: [],
            plugins: %{},
            pure_links: true

  @type t :: %__MODULE__{
        breaks: boolean,
        code_class_prefix: maybe(String.t),
        footnotes: boolean,
        footnote_offset: number,
        gfm: boolean,
        pedantic: boolean,
        pure_links: boolean,
        smartypants: boolean,
        timeout: maybe(number)
  }

  @doc false
  # Only here we are aware of which mapper function to use!
  def get_mapper(options) do
    if options.timeout do
      &options.mapper_with_timeout.(&1, &2, options.timeout)
    else
      options.mapper
    end
  end

  @doc false
  def plugin_for_prefix(options, plugin_name) do
    Map.get(options.plugins, plugin_name, false)
  end
end

# SPDX-License-Identifier: Apache-2.0
