defmodule Earmark.Block do

  @moduledoc false

  defmodule Heading do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, content: nil, level: nil 
  end
  defmodule Ruler do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, type: nil 
  end
  defmodule BlockQuote do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, blocks: [] 
  end
  defmodule Para do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, lines:  [] 
  end
  defmodule Code do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, lines:  [], language: nil 
  end
  defmodule Html do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, html:   [], tag: nil 
  end
  defmodule HtmlOneline do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, html:   ""  
  end
  defmodule HtmlComment do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, lines:  [] 
  end
  defmodule IdDef do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, id: nil, url: nil, title: nil 
  end
  defmodule FnDef do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, id: nil, number: nil, blocks: [] 
  end
  defmodule FnList do
    @moduledoc false
    defstruct lnb: 0, attrs: ".footnotes", blocks: [] 
  end
  defmodule Ial do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, content: nil, verbatim: "" 
  end
  # List does not need line number 
  defmodule List do
    @moduledoc false
    defstruct lnb: 1, attrs: nil, type: :ul, blocks:  [], start: "" 
  end
  defmodule ListItem do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, type: :ul, spaced: true, blocks: [], bullet: "" 
  end
  defmodule Table do
    @moduledoc false
    defstruct lnb: 0, attrs: nil, rows: [], header: nil, alignments: []

    def new_for_columns(n) do
      %__MODULE__{alignments: Elixir.List.duplicate(:left, n)}
    end
  end

  @type t :: %Heading{} |
  %Ruler{} |
  %BlockQuote{} |
  %List{} |
  %ListItem{} |
  %Para{} |
  %Code{} |
  %Html{} |
  %HtmlOneline{} |
  %HtmlComment{} |
  %IdDef{} |
  %FnDef{} |
  %FnList{} |
  %Ial{} |
  %Table{}
  @type ts :: list(t)
end

# SPDX-License-Identifier: Apache-2.0
