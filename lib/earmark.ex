defmodule Earmark do


  @type ast_meta :: map()
  @type ast_tag :: binary()
  @type ast_attribute_name :: binary()
  @type ast_attribute_value :: binary()
  @type ast_attribute  :: {ast_attribute_name(), ast_attribute_value()}
  @type ast_attributes :: list(ast_attribute())
  @type ast_tuple :: {ast_tag(), ast_attributes(), ast(), ast_meta()}
  @type ast_node :: binary() | ast_tuple()
  @type ast :: list(ast_node())

  @moduledoc """

  ### API

  Earmark now exposes a well-defined and stable Abstract Syntax Tree

  #### Earmark.as_ast

  The function is described below and the other two API functions `as_html` and `as_html!` are now based upon
  the structure of the result of `as_ast`.

      {:ok, ast, []}                   = Earmark.as_ast(markdown)
      {:ok, ast, deprecation_messages} = Earmark.as_ast(markdown)
      {:error, ast, error_messages}    = Earmark.as_ast(markdown)

  #### Earmark.as_html

      {:ok, html_doc, []}                   = Earmark.as_html(markdown)
      {:ok, html_doc, deprecation_messages} = Earmark.as_html(markdown)
      {:error, html_doc, error_messages}    = Earmark.as_html(markdown)

  #### Earmark.as_html!

      html_doc = Earmark.as_html!(markdown, options)

  Formats the error_messages returned by `as_html` and adds the filename to each.
  Then prints them to stderr and just returns the html_doc

  #### Options

  Options can be passed into `as_ast/2`as well as `as_html/2` or `as_html!/2` according to the documentation.

      {status, html_doc, errors} = Earmark.as_html(markdown, options)
      html_doc = Earmark.as_html!(markdown, options)
      {status, ast, errors} = Earmark.as_ast(markdown, options)

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

  ### Github Flavored Markdown

  GFM is supported by default, however as GFM is a moving target and all GFM extension do not make sense in a general context, Earmark does not support all of it, here is a list of what is supported:

  #### Strike Through

      iex(1)> Earmark.as_html! ["~~hello~~"]
      "<p>\\n  <del>\\n    hello\\n  </del>\\n</p>\\n"

  #### Syntax Highlighting

  All backquoted or fenced code blocks with a language string are rendered with the given
  language as a _class_ attribute of the _code_ tag.

  For example:

      iex(2)> [
      ...(2)>    "```elixir",
      ...(2)>    " @tag :hello",
      ...(2)>    "```"
      ...(2)> ] |> Earmark.as_html!()
      "<pre><code class=\\"elixir\\"> @tag :hello</code></pre>\\n"

  will be rendered as shown in the doctest above.

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

  #### Tables

  Are supported as long as they are preceded by an empty line.

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

  Currently we assume there are always spaces around interior vertical unless
  there are exterior bars.

  However in order to be more GFM compatible the `gfm_tables: true` option
  can be used to interpret only interior vertical bars as a table if a seperation
  line is given, therefor

       Language|Rating
       --------|------
       Elixir  | awesome

  is a table (iff `gfm_tables: true`) while

       Language|Rating
       Elixir  | awesome

  never is.

  #### HTML Blocks

  HTML is not parsed recursively or detected in all conditons right now, though GFM compliance
  is a goal.

  But for now the following holds:

  A HTML Block defined by a tag starting a line and the same tag starting a different line is parsed
  as one HTML AST node, marked with %{verbatim: true}

  E.g.

        iex(3)> lines = [ "<div><span>", "some</span><text>", "</div>more text" ]
        ...(3)> Earmark.as_ast(lines)
        {:ok, [{"div", [], ["<span>", "some</span><text>"], %{verbatim: true}}, "more text"], []}

  And a line starting with an opening tag and ending with the corresponding closing tag is parsed in similar
  fashion

        iex(4)> Earmark.as_ast(["<span class=\\"superspan\\">spaniel</span>"])
        {:ok, [{"span", [{"class", "superspan"}], ["spaniel"], %{verbatim: true}}], []}

  What is HTML?

  We differ from strict GFM by allowing **all** tags not only HTML5 tagsn this holds for oneliners....

        iex(5)> {:ok, ast, []} = Earmark.as_ast(["<stupid />", "<not>better</not>"])
        ...(5)> ast
        [
          {"stupid", [], [], %{verbatim: true}},
          {"not", [], ["better"], %{verbatim: true}}]

  and for multiline blocks

        iex(6)> {:ok, ast, []} = Earmark.as_ast([ "<hello>", "world", "</hello>"])
        ...(6)> ast
        [{"hello", [], ["world"], %{verbatim: true}}]

  #### HTML Comments

  Are recoginized if they start a line (after ws and are parsed until the next `-->` is found
  all text after the next '-->' is ignored

  E.g.

      iex(7)> Earmark.as_ast(" <!-- Comment\\ncomment line\\ncomment --> text -->\\nafter")
      {:ok, [{:comment, [], [" Comment", "comment line", "comment "], %{comment: true}}, {"p", [], ["after"], %{}}], []}



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

  It is possible to add IAL attributes to generated links or images in the following
  format.

      iex(8)> markdown = "[link](url) {: .classy}"
      ...(8)> Earmark.as_html(markdown)
      { :ok, "<p>\\n<a class=\\"classy\\" href=\\"url\\">link</a></p>\\n", []}

  For both cases, malformed attributes are ignored and warnings are issued.

      iex(9)> [ "Some text", "{:hello}" ] |> Enum.join("\\n") |> Earmark.as_html()
      {:error, "<p>\\n  Some text\\n</p>\\n", [{:warning, 2,"Illegal attributes [\\"hello\\"] ignored in IAL"}]}

  It is possible to escape the IAL in both forms if necessary

      iex(10)> markdown = "[link](url)\\\\{: .classy}"
      ...(10)> Earmark.as_html(markdown)
      {:ok, "<p>\\n<a href=\\"url\\">link</a>  {: .classy}\\n</p>\\n", []}

  This of course is not necessary in code blocks or text lines
  containing an IAL-like string, as in the following example

      iex(11)> markdown = "hello {:world}"
      ...(11)> Earmark.as_html!(markdown)
      "<p>\\n  hello {:world}\\n</p>\\n"

  ## Limitations

    * Block-level HTML is correctly handled only if each HTML
      tag appears on its own line. So

          <div>
          <div>
          hello
          </div>
          </div>

    will work. However. the following won't

          <div>
          hello</div>

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
          <hr />

    Becomes

          <p>mypara</p>
          <hr />

    While

          mypara
           <hr />

    will be transformed into

          <p>mypara
           <hr /></p>

  ## Timeouts

  By default, that is if the `timeout` option is not set Earmark uses parallel mapping as implemented in `Earmark.pmap/2`,
  which uses `Task.await` with its default timeout of 5000ms.

  In rare cases that might not be enough.

  By indicating a longer `timeout` option in milliseconds Earmark will use parallel mapping as implemented in `Earmark.pmap/3`,
  which will pass `timeout` to `Task.await`.

  In both cases one can override the mapper function with either the `mapper` option (used if and only if `timeout` is nil) or the
  `mapper_with_timeout` function (used otherwise).

  For the escript only the `timeout` command line argument can be used.

  ## Security

  Please be aware that Markdown is not a secure format. It produces
  HTML from Markdown and HTML. It is your job to sanitize and or
  filter the output of `Earmark.as_html` if you cannot trust the input
  and are to serve the produced HTML on the Web.
  """

  alias Earmark.Error
  alias Earmark.Options
  import Earmark.Message, only: [emit_messages: 2, sort_messages: 1]

  @doc """
  Given a markdown document (as either a list of lines or
  a string containing newlines), returns a tuple containing either
  `{:ok, html_doc, error_messages}`, or `{:error, html_doc, error_messages}`
  Where `html_doc` is an HTML representation of the markdown document and
  `error_messages` is a list of tuples with the following elements

  - `severity` e.g. `:error`, `:warning` or `:deprecation`
  - line number in input where the error occurred
  - description of the error


  `options` can be an `%Earmark.Options{}` structure, or can be passed in as a `Keyword` argument (with legal keys for `%Earmark.Options`

  * `renderer`: ModuleName

    The module used to render the final document. Defaults to
    `Earmark.HtmlRenderer`

  * `gfm`: boolean

    True by default. Turns on the supported Github Flavored Markdown extensions

  * `breaks`: boolean

    Only applicable if `gfm` is enabled. Makes all line breaks
    significant (so every line in the input is a new line in the
    output.

  * `code_class_prefix`: binary

    Code blocks will be rendered with prefixed class names, which might be necessary for
    usage with 3rd party libraries.


          Earmark.as_html("\`\`\`elixir\\nCode\\n\`\`\`", code_class_prefix: "my_prefix_")

          {:ok, "<pre><code class=\\"elixir my_prefix_elixir\\">Code\\\```</code></pre>\\n", []}


  * `smartypants`: boolean

    Turns on smartypants processing, so quotes become curly, two
    or three hyphens become en and em dashes, and so on. True by
    default.

    So, to format the document in `original` and disable smartypants,
    you'd call


          alias Earmark.Options
          Earmark.as_html(original, %Options{smartypants: false})


  * `pure_links`: boolean

    Pure links of the form `~r{\\bhttps?://\\S+\\b}` are rendered as links from now on.
    However, by setting the `pure_links` option to `false` this can be disabled and pre 1.4
    behavior can be used.
  """
  def as_html(lines, options \\ %Options{})

  def as_html(lines, options) when is_list(options) do
    as_html(lines, struct(Options, options))
  end

  def as_html(lines, options) do
    {status, ast, messages} = as_ast(lines, options)
    {status, Earmark.Transform.transform(ast, options), messages}
  end

  @doc """
        iex(12)> markdown = "My `code` is **best**"
        ...(12)> {:ok, ast, []} = Earmark.as_ast(markdown)
        ...(12)> ast
        [{"p", [], ["My ", {"code", [{"class", "inline"}], ["code"], %{}}, " is ", {"strong", [], ["best"], %{}}], %{}}]

  Options are passes like to `as_html`, some do not have an effect though (e.g. `smartypants`) as formatting and escaping is not done
  for the AST.

        iex(13)> markdown = "```elixir\\nIO.puts 42\\n```"
        ...(13)> {:ok, ast, []} = Earmark.as_ast(markdown, code_class_prefix: "lang-")
        ...(13)> ast
        [{"pre", [], [{"code", [{"class", "elixir lang-elixir"}], ["IO.puts 42"], %{}}], %{}}]

  **Rationale**:

  The AST is exposed in the spirit of [Floki's](https://hex.pm/packages/floki).
  """
  def as_ast(lines, options \\ %Options{})
  def as_ast(lines, options) when is_list(options) do
    as_ast(lines, struct(Options, options))
  end
  def as_ast(lines, options) do
    context = _as_ast(lines, options)
    messages = sort_messages(context)

    status =
      case Enum.any?(messages, fn {severity, _, _} ->
             severity == :error || severity == :warning
           end) do
        true -> :error
        _ -> :ok
      end

    {status, context.value, messages}
  end

  @doc """
  A convenience method that *always* returns an HTML representation of the markdown document passed in.
  In case of the presence of any error messages they are prinetd to stderr.

  Otherwise it behaves exactly as `as_html`.
  """
  def as_html!(lines, options \\ %Options{})
  def as_html!(lines, options) when is_list(options) do
    as_html!(lines, struct(Options, options))
  end
  def as_html!(lines, options = %Options{}) do
    {_status, html, messages} = as_html(lines, options)
    emit_messages(messages, options)
    html
  end

  defp _as_ast(lines, options) do
    {blocks, context} = Earmark.Parser.parse_markdown(lines, options)
    Earmark.AstRenderer.render(blocks, context)
  end

  @doc """
    Accesses current hex version of the `Earmark` application. Convenience for
    `iex` usage.
  """
  def version() do
    with {:ok, version} = :application.get_key(:earmark, :vsn),
      do: to_string(version)
  end

  @default_timeout_in_ms 5000
  @doc false
  def pmap(collection, func, timeout \\ @default_timeout_in_ms) do
    collection
    |> Enum.map(fn item -> Task.async(fn -> func.(item) end) end)
    |> Task.yield_many(timeout)
    |> Enum.map(&_join_pmap_results_or_raise(&1, timeout))
  end

  defp _join_pmap_results_or_raise(yield_tuples, timeout)
  defp _join_pmap_results_or_raise({_task, {:ok, result}}, _timeout), do: result

  defp _join_pmap_results_or_raise({task, {:error, reason}}, _timeout),
    do: raise(Error, "#{inspect(task)} has died with reason #{inspect(reason)}")

  defp _join_pmap_results_or_raise({task, nil}, timeout),
    do:
      raise(
        Error,
        "#{inspect(task)} has not responded within the set timeout of #{timeout}ms, consider increasing it"
      )
end

# SPDX-License-Identifier: Apache-2.0
