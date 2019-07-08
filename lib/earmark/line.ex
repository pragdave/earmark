defmodule Earmark.Line do

  @moduledoc """
  Defines all structs representing lines
  """

  defmodule(Blank, do: defstruct(lnb: 0, line: "", content: "", inside_code: false))
  defmodule(Ruler, do: defstruct(lnb: 0, line: "", type: "- or * or _", inside_code: false))

  defmodule(Heading,
    do: defstruct(lnb: 0, line: "", level: 1, content: "inline text", inside_code: false)
  )

  defmodule(BlockQuote, do: defstruct(lnb: 0, line: "", content: "text", inside_code: false))

  defmodule(Indent, do: defstruct(lnb: 0, line: "", level: 0, content: "text", inside_code: false))

  defmodule(Fence,
    do: defstruct(lnb: 0, line: "", delimiter: "~ or `", language: nil, inside_code: false)
  )

  defmodule(HtmlOpenTag, do: defstruct(lnb: 0, line: "", tag: "", content: "", inside_code: false))

  defmodule(HtmlCloseTag, do: defstruct(lnb: 0, line: "", tag: "<... to eol", inside_code: false))
  defmodule(HtmlComment, do: defstruct(lnb: 0, line: "", complete: true, inside_code: false))

  defmodule(HtmlOneLine, do: defstruct(lnb: 0, line: "", tag: "", content: "", inside_code: false))

  defmodule(IdDef,
    do: defstruct(lnb: 0, line: "", id: nil, url: nil, title: nil, inside_code: false)
  )

  defmodule(FnDef, do: defstruct(lnb: 0, line: "", id: nil, content: "text", inside_code: false))

  defmodule(ListItem,
    do:
      defstruct(
        lnb: 0,
        type: :ul,
        line: "",
        bullet: "* or -",
        content: "text",
        initial_indent: 0,
        inside_code: false,
        list_indent: 0
      )
  )

  defmodule(SetextUnderlineHeading,
    do: defstruct(lnb: 0, line: "", level: 1, inside_code: false, inside_code: false)
  )

  defmodule(TableLine,
    do: defstruct(lnb: 0, line: "", content: "", columns: 0, inside_code: false)
  )

  defmodule(Ial, do: defstruct(lnb: 0, line: "", attrs: "", inside_code: false, verbatim: ""))
  defmodule(Text, do: defstruct(lnb: 0, line: "", content: "", inside_code: false))

  defmodule(Plugin, do: defstruct(lnb: 0, line: "", content: "", prefix: "$$"))

  @type t ::
          %Blank{}
          | %Ruler{}
          | %Heading{}
          | %BlockQuote{}
          | %Indent{}
          | %Fence{}
          | %HtmlOpenTag{}
          | %HtmlCloseTag{}
          | %HtmlComment{}
          | %HtmlOneLine{}
          | %IdDef{}
          | %FnDef{}
          | %ListItem{}
          | %SetextUnderlineHeading{}
          | %TableLine{}
          | %Ial{}
          | %Text{}
          | %Plugin{}

  @type ts :: list(t)
end

# SPDX-License-Identifier: Apache-2.0
