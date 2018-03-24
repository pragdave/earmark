
# Earmark—A Pure Elixir Markdown Processor

[![Build Status](https://travis-ci.org/pragdave/earmark.svg?branch=master)](https://travis-ci.org/pragdave/earmark)
[![Hex.pm](https://img.shields.io/hexpm/v/earmark.svg)](https://hex.pm/packages/earmark)
[![Hex.pm](https://img.shields.io/hexpm/dw/earmark.svg)](https://hex.pm/packages/earmark)
[![Hex.pm](https://img.shields.io/hexpm/dt/earmark.svg)](https://hex.pm/packages/earmark)
<!-- moduledoc: Earmark -->

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

### Github Flavored Markdown


GFM is supported by default, however as GFM is a moving target and all GFM extension do not make sense in a general context, Earmark does not support all of it, here is a list of what is supported:

* StrikeThrough

      iex(13)> Earmark.as_html! ["~~hello~~"]
      "<p><del>hello</del></p>\n"

* Syntax Highlighting

The generated code blocks have a corresponding `class` attribute:



      iex(11)> Earmark.as_html! ["```elixir", "   [] |> Enum.into(%{})", "```"]
      "<pre><code class=\"elixir\">   [] |&gt; Enum.into(%{})</code></pre>\n"


which can be customized with the `code_class_prefix` option


      iex(12)> Earmark.as_html! ["```elixir", "   [] |> Enum.into(%{})", "```"] , %Earmark.Options{code_class_prefix: "lang-"}
      "<pre><code class=\"elixir lang-elixir\">   [] |&gt; Enum.into(%{})</code></pre>\n"



* Tables

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

It is possible to add IAL attributes to generated links or images in the following
format.

      iex> markdown = "[link](url) {: .classy}"
      ...> Earmark.as_html(markdown)
      { :ok, "<p><a href=\"url\" class=\"classy\">link</a></p>\n", []}


For both cases, malformed attributes are ignored and warnings are issued.

      iex> [ "Some text", "{:hello}" ] |> Enum.join("\n") |> Earmark.as_html()
      {:error, "<p>Some text</p>\n", [{:warning, 2,"Illegal attributes [\"hello\"] ignored in IAL"}]}

It is possible to escape the IAL in both forms if necessary

      iex> markdown = "[link](url)\\{: .classy}"
      ...> Earmark.as_html(markdown)
      {:ok, "<p><a href=\"url\">link</a>{: .classy}</p>\n", []}


This of course is not necessary in code blocks or text lines
containing an IAL-like string, as in the following example

      iex> markdown = "hello {:world}"
      ...> Earmark.as_html!(markdown)
      "<p>hello {:world}</p>\n"

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

### Syntax Highlighting

All backquoted or fenced code blocks with a language string are rendered with the given
language as a _class_ attribute of the _code_ tag.

For example:

      iex> [
      ...>    "```elixir",
      ...>    " @tag :hello",
      ...>    "```"
      ...> ] |> Earmark.as_html!()
      "<pre><code class=\"elixir\"> @tag :hello</code></pre>\n"

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

## Security

  Please be aware that Markdown is not a secure format. It produces
  HTML from Markdown and HTML. It is your job to sanitize and or
  filter the output of `Earmark.as_html` if you cannot trust the input
  and are to serve the produced HTML on the Web.

## Author

Copyright © 2014 Dave Thomas, The Pragmatic Programmers
@/+pragdave,  dave@pragprog.com

Licensed under the same terms as Elixir, which is Apache 2.0.
<!-- endmoduledoc: Earmark -->

# Details
<!-- doc: Earmark.as_html -->
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

  True by default. Turns on the supported Github Flavored Markdown extensions

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

<!-- enddoc: Earmark.as_html -->


## Plugins
<!-- moduledoc: Earmark.Plugin -->
Plugins are modules that implement a render function. Right now that is `as_html`.

### API

#### Plugin Registration

When invoking `Earmark.as_html(some_md, options)` we can register plugins inside the `plugins` map, where
each plugin is a value pointed to by the prefix triggering it.

Prefixes are appended to `"$$"` and lines starting by that string will be rendered by the registered plugin.

`%Earmark.Options{plugins: %{"" => CommentPlugin}}` would trigger the `CommentPlugin` for each block of
lines prefixed by `$$`, while `%Earmark.Options{plugins: %{"cp" => CommentPlugin}}` would do the same for
blocks of lines prefixed by `$$cp`.

Please see the documentation of `Plugin.define` for a convenience function that helps creating the necessary
`Earmark.Options` structs for the usage of plugins.

#### Plugin Invocation

`as_html` (or other render functions in the future) is invoked with a list of pairs containing the text
and line number of the lines in the block. As an example, if our plugin was registered with the default prefix
of `""` and the markdown to be converted was:

      # Plugin output ahead
      $$ line one
      $$
      $$ line two

`as_html` would be invoked as follows:

      as_html([{"line one", 2}, {"", 3}, {"line two", 4})

#### Plugin Output

Earmark's render function will invoke the plugin's render function as explained above. It can then integrate the
return value of the function into the generated rendering output if it complies to the following criteria.

1. It returns a string
1. It returns a list of strings
1. It returns a pair of lists containing a list of strings and a list of error/warning tuples.
Where the tuples are of the form `{:error | :warning, line_number, descriptive_text}`

#### A complete example

      iex> defmodule MyPlug do
      ...>   def as_html(lines) do
      ...>     # to demonstrate the three possible return values
      ...>     case render(lines) do
      ...>       {[line], []} -> line
      ...>       {lines, []} -> lines
      ...>       tuple       -> tuple
      ...>     end
      ...>   end
      ...>
      ...>   defp render(lines) do
      ...>     Enum.map(lines, &render_line/1) |> Enum.split_with(&ok?/1)
      ...>   end
      ...>
      ...>   defp render_line({"", _}), do: "<hr/>"
      ...>   defp render_line({"line one", _}), do: "<p>first line</p>\n"
      ...>   defp render_line({line, lnb}), do: {:error, lnb, line}
      ...>
      ...>   defp ok?({_, _, _}), do: false
      ...>   defp ok?(_), do: true
      ...> end
      ...>
      ...> lines = [
      ...>   "# Plugin Ahead",
      ...>   "$$ line one",
      ...>   "$$",
      ...>   "$$ line two",
      ...> ]
      ...> Earmark.as_html(lines, Earmark.Plugin.define(MyPlug))
      {:error, "<h1>Plugin Ahead</h1>\n<p>first line</p>\n<hr/>", [{ :error, 4, "line two"}]}

#### Plugins, reusing Earmark

As long as you avoid endless recursion there is absolutely no problem to call `Earmark.as_html` in your plugin, consider the following
example in which the plugin will parse markdown and render html verbatim (which is stupid, that is what Earmark already does for you,
but just to demonstrate the possibilities):

      iex> defmodule Again do
      ...>   def as_html(lines) do
      ...>     text_lines = Enum.map(lines, fn {str, _} -> str end)
      ...>     {_, html, errors} = Earmark.as_html(text_lines)
      ...>     { Enum.join([html | text_lines]), errors }
      ...>   end
      ...> end
      ...>  lines = [
      ...>    "$$a * one",
      ...>    "$$a * two",
      ...>  ]
      ...>  Earmark.as_html(lines, Earmark.Plugin.define({Again, "a"}))
      {:ok, "<ul>\n<li>one\n</li>\n<li>two\n</li>\n</ul>\n* one* two", []}
<!-- endmoduledoc: Earmark.Plugin -->

## Contributing

Pull Requests are happily accepted.

Please be aware of one _caveat_ when correcting/improving README.md.
Parts of the README.md are automatically generated by the mix task `readme`.
The generated parts are delimited by comment pairs like
    <!-- moduledoc: Earmark -->

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

### Github Flavored Markdown


GFM is supported by default, however as GFM is a moving target and all GFM extension do not make sense in a general context, Earmark does not support all of it, here is a list of what is supported:

* StrikeThrough

      iex(13)> Earmark.as_html! ["~~hello~~"]
      "<p><del>hello</del></p>\n"

* Syntax Highlighting

The generated code blocks have a corresponding `class` attribute:



      iex(11)> Earmark.as_html! ["```elixir", "   [] |> Enum.into(%{})", "```"]
      "<pre><code class=\"elixir\">   [] |&gt; Enum.into(%{})</code></pre>\n"


which can be customized with the `code_class_prefix` option


      iex(12)> Earmark.as_html! ["```elixir", "   [] |> Enum.into(%{})", "```"] , %Earmark.Options{code_class_prefix: "lang-"}
      "<pre><code class=\"elixir lang-elixir\">   [] |&gt; Enum.into(%{})</code></pre>\n"



* Tables

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

It is possible to add IAL attributes to generated links or images in the following
format.

      iex> markdown = "[link](url) {: .classy}"
      ...> Earmark.as_html(markdown)
      { :ok, "<p><a href=\"url\" class=\"classy\">link</a></p>\n", []}


For both cases, malformed attributes are ignored and warnings are issued.

      iex> [ "Some text", "{:hello}" ] |> Enum.join("\n") |> Earmark.as_html()
      {:error, "<p>Some text</p>\n", [{:warning, 2,"Illegal attributes [\"hello\"] ignored in IAL"}]}

It is possible to escape the IAL in both forms if necessary

      iex> markdown = "[link](url)\\{: .classy}"
      ...> Earmark.as_html(markdown)
      {:ok, "<p><a href=\"url\">link</a>{: .classy}</p>\n", []}


This of course is not necessary in code blocks or text lines
containing an IAL-like string, as in the following example

      iex> markdown = "hello {:world}"
      ...> Earmark.as_html!(markdown)
      "<p>hello {:world}</p>\n"

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

### Syntax Highlighting

All backquoted or fenced code blocks with a language string are rendered with the given
language as a _class_ attribute of the _code_ tag.

For example:

      iex> [
      ...>    "```elixir",
      ...>    " @tag :hello",
      ...>    "```"
      ...> ] |> Earmark.as_html!()
      "<pre><code class=\"elixir\"> @tag :hello</code></pre>\n"

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

## Security

  Please be aware that Markdown is not a secure format. It produces
  HTML from Markdown and HTML. It is your job to sanitize and or
  filter the output of `Earmark.as_html` if you cannot trust the input
  and are to serve the produced HTML on the Web.

## Author

Copyright © 2014 Dave Thomas, The Pragmatic Programmers
@/+pragdave,  dave@pragprog.com

Licensed under the same terms as Elixir, which is Apache 2.0.
    <!-- endmoduledoc: Earmark -->
    <!-- endmoduledoc: Earmark -->

or
    <!-- doc: Earmark.as_html -->
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

  True by default. Turns on the supported Github Flavored Markdown extensions

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

    <!-- enddoc: Earmark.as_html -->
    <!-- enddoc: Earmark.as_html -->

Please modify the associated docstrings instead.

## Author

Copyright © 2014 Dave Thomas, The Pragmatic Programmers
@/+pragdave,  dave@pragprog.com

# LICENSE

Same as Elixir, which is Apache License v2.0. Please refer to [LICENSE](LICENSE) for details.

SPDX-License-Identifier: Apache-2.0
