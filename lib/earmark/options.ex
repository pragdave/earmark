defmodule Earmark.Options do
  alias Earmark.Message
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

             # Filename and initial line number of the markdown block passed in
             # for meaningfull error messages
             file: "<no file>",
             line: 1,
             messages: [] # [%Earmark.Message{}]

  defimpl Collectable, for: __MODULE__ do
    def into(options) do
      { options, fn
          acc, {:cont, {k, v}} -> Map.put(acc, k, v)
          acc, :done           -> acc
          _,   :halt           -> :ok
        end
      }
    end
  end

  @doc """
    Add a message at the head of the messages list of the options struct
  """
  def add_warning options, line, text do 
    %{options|messages: [Message.new_warning(line, text) | options.messages]}
  end

end

