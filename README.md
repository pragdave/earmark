<!-- moduledoc: Earmark -->

# Earmark—A Pure Elixir Markdown Processor

## Usage

    html_doc = Earmark.to_html(markdown)

    html_doc = Earmark.to_html(markdown, options)

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

  And expects this to be a nested list. But, in reality, the second could just
  be the continuation of a paragraph.

  I've chosen always to use the second interpretation—a line that looks like
  a list item will always be a list item.

## Author

Copyright © 2014 Dave Thomas, The Pragmatic Programmers
@/+pragdave,  dave@pragprog.com

Licensed under the same terms as Elixir.

<!-- endmoduledoc: Earmark -->

# Details

<!-- doc: Earmark.to_html -->
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


<!-- enddoc: Earmark.to_html -->
