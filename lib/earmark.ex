defmodule Earmark do

  @moduledoc """

  # Earmark—A Pure Elixir Markdown Processor

  ## Dependency

      { :earmark, "> x.y.z" }

  ## Usage

  ### API

      html_doc = Earmark.to_html(markdown)

      html_doc = Earmark.to_html(markdown, options)

  (See the documentation for `to_html` for options)

  ### Command line

      $ mix escript.build
      $ ./earmark file.md

  ## Supports

  Standard [Gruber markdown][gruber].

  [gruber]: <http://daringfireball.net/projects/markdown/syntax>

  ## Extensions

  ### Tables

  Github Flavored Markdown tables are supported

          State | Abbrev | Capital
          ----: | :----: | -------
          Texas | TX     | Austin
          Maine | MN     | Augusta

  Tables may have leading and trailing vertical bars on each line

          | State | Abbrev | Capital |
          | ----: | :----: | ------- |
          | Texas | TX     | Austin  |
          | Maine | MN     | Augusta |

  Tables need not have headers, in which case all column alignments
  default to left.

          | Texas | TX     | Austin  |
          | Maine | MN     | Augusta |

  Currently we assume there are always spaces around interior vertical
  bars. It isn't clear what the expectation is.

  ### Adding HTML attributes

  HTML attributes can be added to any block-level element. We use
  the Kramdown syntax: add the line `{:` _attrs_ `}` following the block.

  _attrs_ can be one or more of:

  * `.className`
  * `#id`
  * name=value, name="value", or name='value'

  For example:

          # Warning
          {: .red}

          Do not turn off the engine
          if you are at altitude.
          {: .boxed #warning spellcheck="true"}

  ## Limitations

  * Nested block-level HTML is correctly handled only if each HTML
    tag appears on its own line. So

          <div>
          <div>
          hello
          </div>
          </div>

    will work. However. the following won't

          <div><div>
          hello
          </div></div>

  * John Gruber's tests contain an ambiguity when it comes to
    lines that might be the start of a list inside paragraphs.

    One test says that

          This is the text
          * of a paragraph
          that I wrote

    is a single paragraph. The "*" is not significant. However, another
    test has

          *   A list item
              * an another

    and expects this to be a nested list. But, in reality, the second could just
    be the continuation of a paragraph.

    I've chosen always to use the second interpretation—a line that looks like
    a list item will always be a list item.

  ## Author

  Copyright © 2014 Dave Thomas, The Pragmatic Programmers
  @/+pragdave,  dave@pragprog.com

  Licensed under the same terms as Elixir, which is Apache 2.0.
  """

  alias Earmark.Options
  alias Earmark.Context

  @doc """
  Given a markdown document (as either a list of lines or
  a string containing newlines), return an HTML representation.

  The options are a `%Earmark.Options{}` structure:

  * `renderer`: ModuleName

    The module used to render the final document. Defaults to
    `Earmark.HtmlRenderer`

  * `gfm`: boolean

    True by default. Turns on Github Flavored Markdown extensions

  * `breaks`: boolean

    Only applicable if `gfm` is enabled. Makes all line breaks
    significant (so every line in the input is a new line in the
    output.

  * `smartypants`: boolean

    Turns on smartypants processing, so quotes become curly, two
    or three hyphens become en and em dashes, and so on. True by
    default.

  So, to format the document in `original` and disable smartypants,
  you'd call

      alias Earmark.Options
      result = Earmark.to_html(original, %Options{smartypants: false})

  """

  def to_html(lines, options \\ %Options{})
  def to_html({blocks, context = %Context{}}, %Options{renderer: renderer, mapper: mapper}=_options) do
    renderer.render(blocks, context, mapper)
  end
  # TODO: parse implements the same guarded discrimination
  #       we shall eliminate the guard of this function body
  #       and eliminate the second one.
  def to_html(lines, options = %Options{}) when is_list(lines) do
    lines |> parse(options) |> to_html(options)
  end
  def to_html(lines, options) when is_binary(lines) do
    lines |> string_to_list |> to_html(options)
  end

  @doc """
  Given a markdown document (as either a list of lines or
  a string containing newlines), return a parse tree and
  the context necessary to render the tree.

  The options are a `%Earmark.Options{}` structure. See `to_html`
  for more details.
  """

  def parse(lines, options \\ %Options{})
  def parse(lines, options = %Options{mapper: mapper}) when is_list(lines) do
    { blocks, links } = Earmark.Parser.parse(lines, options)

    context = %Earmark.Context{options: options, links: links }
              |> Earmark.Inline.update_context

    if options.footnotes do
      { blocks, footnotes } = Earmark.Parser.handle_footnotes(blocks, options, mapper)
      context = put_in(context.footnotes, footnotes)
    end

    { blocks, context }
  end
  def parse(lines, options) when is_binary(lines) do
    lines |> string_to_list |> parse(options)
  end

  @doc false
  defp string_to_list(document) do
    document |> String.split(~r{\r\n?|\n})
  end

  @doc false
  def pmap(collection, func) do
    collection
    |> Enum.map(fn item -> Task.async(fn -> func.(item) end) end)
    |> Enum.map(&Task.await/1)
  end

end
