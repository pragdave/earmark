defmodule Earmark.Line do

  @moduledoc false

  defmodule Blank  do
    @moduledoc false
    defstruct(lnb: 0, line: "", content: "", inside_code: false)
  end
  defmodule Ruler  do
    @moduledoc false
    defstruct(lnb: 0, line: "", type: "- or * or _", inside_code: false)
  end

  defmodule Heading  do
    @moduledoc false
    defstruct(lnb: 0, line: "", level: 1, content: "inline text", inside_code: false)
  end

  defmodule BlockQuote  do
    @moduledoc false
    defstruct(lnb: 0, line: "", content: "text", inside_code: false)
  end

  defmodule Indent  do
    @moduledoc false
    defstruct(lnb: 0, line: "", level: 0, content: "text", inside_code: false)
  end

  defmodule Fence  do
    @moduledoc false
    defstruct(lnb: 0, line: "", delimiter: "~ or `", language: nil, inside_code: false)
  end

  defmodule HtmlOpenTag  do
    @moduledoc false
    defstruct(lnb: 0, line: "", tag: "", content: "", inside_code: false)
  end

  defmodule HtmlCloseTag  do
    @moduledoc false
    defstruct(lnb: 0, line: "", tag: "<... to eol", inside_code: false)
  end
  defmodule HtmlComment  do
    @moduledoc false
    defstruct(lnb: 0, line: "", complete: true, inside_code: false)
  end

  defmodule HtmlOneLine  do
    @moduledoc false
    defstruct(lnb: 0, line: "", tag: "", content: "", inside_code: false)
  end

  defmodule IdDef  do
    @moduledoc false
    defstruct(lnb: 0, line: "", id: nil, url: nil, title: nil, inside_code: false)
  end

  defmodule FnDef  do
    @moduledoc false
    defstruct(lnb: 0, line: "", id: nil, content: "text", inside_code: false)
  end

  defmodule ListItem do
    @moduledoc false
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
  end

  defmodule SetextUnderlineHeading  do
    @moduledoc false
    defstruct(lnb: 0, line: "", level: 1, inside_code: false)
  end

  defmodule TableLine  do
    @moduledoc false
    defstruct(lnb: 0, line: "", content: "", columns: 0, inside_code: false, is_header: false, needs_header: false)
  end

  defmodule Ial  do
    @moduledoc false
    defstruct(lnb: 0, line: "", attrs: "", inside_code: false, verbatim: "")
  end
  defmodule Text  do
    @moduledoc false
    defstruct(lnb: 0, line: "", content: "", inside_code: false)
  end


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

  @type ts :: list(t)
end

# SPDX-License-Identifier: Apache-2.0
