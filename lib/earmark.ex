defmodule Earmark do

  @moduledoc """

  ## Dependency

      { :earmark, "> x.y.z" }

  ## Usage

  ### API

      * `Earmark.as_html`
        {:ok, html_doc, []}                = Earmark.as_html(markdown)
        {:error, html_doc, error_messages} = Earmark.as_html(markdown)

      * `Earmark.as_html!`
        html_doc = Earmark.as_html!(markdown, options)

        Any error messages are printed to _stderr_.

  #### Options:
  #
  Options can be passed into `as_html` or `as_html!` according to the documentation.

        html_doc = Earmark.as_html!(markdown)

        html_doc = Earmark.as_html!(markdown, options)

  Formats the error_messages returned by `as_html` and adds the filename to each.
  Then prints them to stderr and just returns the html_doc

  ### Command line

      $ mix escript.build
      $ ./earmark file.md

  Some options defined in the `Earmark.Options` struct can be specified as command line switches.

  Use

      $ ./earmark --help

  to find out more, but here is a short example

      $ ./earmark --smartypants false --code-class-prefix "a- b-" file.md

  will call

      Earmark.as_html!( ..., %Earmark.Options{smartypants: false, code_class_prefix: "a- b-"})


  ## Supports

  Standard [Gruber markdown][gruber].

  [gruber]: <http://daringfireball.net/projects/markdown/syntax>

  ## Extensions

  ### Tables

  Github Flavored Markdown tables are supported as long as they are preceeded by an empty line.

          State | Abbrev | Capital
          ----: | :----: | -------
          Texas | TX     | Austin
          Maine | ME     | Augusta

  Tables may have leading and trailing vertical bars on each line

          | State | Abbrev | Capital |
          | ----: | :----: | ------- |
          | Texas | TX     | Austin  |
          | Maine | ME     | Augusta |

  Tables need not have headers, in which case all column alignments
  default to left.

          | Texas | TX     | Austin  |
          | Maine | ME     | Augusta |

  Currently we assume there are always spaces around interior vertical
  bars. It isn't clear what the expectation is.

  ### Adding HTML attributes with the IAL extension

  #### To block elements

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


  #### To links or images

  It is possible to add IAL attributes to genertated links or images in the following
  format.

        iex> markdown = "[link](url) {: .classy}"
        ...> Earmark.as_html(markdown)
        { :ok, "<p><a href=\\"url\\" class=\\"classy\\">link</a></p>\\n", []}


  For both cases, malformed attributes are ignored and warnings are issued.

        iex> [ "Some text", "{:hello}" ] |> Enum.join("\\n") |> Earmark.as_html()
        {:error, "<p>Some text</p>\\n", [{:warning, 2,"Illegal attributes [\\"hello\\"] ignored in IAL"}]}

  It is possible to escape the IAL in both forms if necessary

        iex> markdown = "[link](url)\\\\{: .classy}"
        ...> Earmark.as_html(markdown)
        {:ok, "<p><a href=\\"url\\">link</a>{: .classy}</p>\\n", []}


  This of course is not necessary in code blocks or text lines
  containing an IAL-like string, as in the following example

        iex> markdown = "hello {:world}"
        ...> Earmark.as_html!(markdown)
        "<p>hello {:world}</p>\\n"

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

  * Rendering of block and inline elements.

    Block or void HTML elements that are at the absolute beginning of a line end
    the preceding paragraph.

    Thusly

          mypara
          <hr>

    Becomes

          <p>mypara</p>
          <hr>

    While

          mypara
           <hr>

    will be transformed into

          <p>mypara
           <hr></p>

  ## Integration

  ### Syntax Highlightning

  All backquoted or fenced code blocks with a language string are rendered with the given
  language as a _class_ attribute of the _code_ tag.

  For example:

        ...> "```elixir",
        ...> " @tag :hello",
        ...> "```" ] |> Enum.join("\\n")
        ...> Earmark.as_html!(code)
        "<pre><code class=\\"elixir\\"> @tag :hello</code></pre>\\n"

  will be rendered as


  If you want to integrate with a syntax highlighter with different conventions you can add more classes by specifying prefixes that will be
  put before the language string.

  Prism.js for example needs a class `language-elixir`. In order to achieve that goal you can add `language-`
  as a `code_class_prefix` to `Earmark.Options`.

  In the following example we want more than one additional class, so we add more prefixes.

        Earmark.as_html!(..., %Earmark.Options{code_class_prefix: "lang- language-"})

  which is rendering

         <pre><code class="elixir lang-elixir language-elixir">...

  As for all other options `code_class_prefix` can be passed into the `earmark` executable as follows:

        earmark --code-class-prefix "language- lang-" ...

  ## Security

    Please be aware that Markdown is not a secure format. It produces
    HTML from Markdown and HTML. It is your job to sanitize and or
    filter the output of `Earmark.as_html` if you cannot trust the input
    and are to serve the produced HTML on the Web.

  ## Author

  Copyright © 2014 Dave Thomas, The Pragmatic Programmers
  @/+pragdave,  dave@pragprog.com

  Licensed under the same terms as Elixir, which is Apache 2.0.
  """

  alias Earmark.Options
  alias Earmark.Context
  import Earmark.Message, only: [emit_messages: 2]
  import Earmark.Global.Messages


  @doc """
  Given a markdown document (as either a list of lines or
  a string containing newlines), returns a tuple containing either
  `{:ok, html_doc}`, or `{:error, html_doc, error_messages}`
  Where `html_doc` is an HTML representation of the markdown document and
  `error_messages` is a list of strings representing information concerning
  the errors that occurred during parsing.

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
      Earmark.as_html(original, %Options{smartypants: false})

  """
  @spec as_html(String.t | list(String.t), %Options{}) :: {String.t, list(String.t)}
  def as_html(lines, options \\ %Options{}) do
    html = _as_html(lines, options)
    case get_all_messages() do
      []       -> {:ok, html, []}
      messages -> {:error, html, messages}
    end
  end

  @doc """
  A convenience method that *always* returns an HTML representation of the markdown document passed in.
  In case of the presence of any error messages they are prinetd to stderr.

  Otherwise it behaves exactly as `as_html`.
  """
  @spec as_html!(String.t | list(String.t), %Options{}) :: String.t
  def as_html!(lines, options \\ %Options{})
  def as_html!(lines, options = %Options{}) do
    html = _as_html(lines, options)
    emit_messages(options.file, get_all_messages())
    html
  end

  defp _as_html(lines, options) do
    start_link()
    {blocks, context} = parse(lines, options)
    options.renderer.render(blocks, context)
  end

  @doc """
  Given a markdown document (as either a list of lines or
  a string containing newlines), return a parse tree and
  the context necessary to render the tree.

  The options are a `%Earmark.Options{}` structure. See `as_html!`
  for more details.
  """

  @spec parse(String.t | list(String.t), %Options{}) :: { Earmark.Block.ts, %Context{} }
  def parse(lines, options \\ %Earmark.Options{})
  def parse(lines, options = %Options{mapper: mapper}) when is_list(lines) do
    { blocks, links, _ } = Earmark.Parser.parse(lines, options, false)

    context = %Earmark.Context{options: options, links: links }
              |> Earmark.Context.update_context()

    if options.footnotes do
      { blocks, footnotes} = Earmark.Parser.handle_footnotes(blocks, options, mapper)
      context =
        put_in(context.footnotes, footnotes)
      { blocks, context }
    else
      { blocks, context }
    end
  end
  def parse(lines, options) when is_binary(lines) do
    lines
    |> String.split(~r{\r\n?|\n})
    |> parse(options)
  end

  @doc """
    Accesses current hex version of the `Earmark` application. Convenience for
    `iex` usage.
  """
  def version() do
    with {:ok, version} = :application.get_key(:earmark, :vsn), do: version
  end

  @doc false
  @spec pmap( list(A), (A -> Earmark.Line.t) ) :: Earmark.Line.ts
  def pmap(collection, func) do
   collection
    |> Enum.map(fn item -> Task.async(fn -> func.(item) end) end)
    |> Enum.map(&Task.await/1)
  end
end
