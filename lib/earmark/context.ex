defmodule Earmark.Context do

  use Earmark.Types
  import Earmark.Helpers

  defstruct options:  %Earmark.Options{},
            links:    Map.new,
            rules:    nil,
            footnotes: Map.new

  @doc """
  Access `context.options.messages`
  """
  def messages(context), do: context.options.messages

  ##############################################################################
  # Handle adding option specific rules and processors                         #
  ##############################################################################

  defp noop(text), do: text

  @doc false
  # this is called by the command line processor to update
  # the inline-specific rules in light of any options
  def update_context(context =  %Earmark.Context{options: options}) do
    context = %{ context | rules: rules_for(options) }
    context = if options.smartypants do
      put_in(context.options.do_smartypants, &smartypants/1)
    else
      put_in(context.options.do_smartypants, &noop/1)
    end

    if options.sanitize do
      put_in(context.options.do_sanitize, &escape/1)
    else
      put_in(context.options.do_sanitize, &noop/1)
    end
  end


  @link_text  ~S{(?:\[[^]]*\]|[^][]|\])*}
  @href       ~S{\s*<?(.*?)>?(?:\s+['"](.*?)['"])?\s*}  #"

  @code ~r{^
   (`+)		# $1 = Opening run of `
   (.+?)		# $2 = The code block
   (?<!`)
   \1			# Matching closer
   (?!`)
    }xs


  defp basic_rules do
    [
      escape:   ~r{^\\([\\`*\{\}\[\]()\#+\-.!_>])},
      autolink: ~r{^<([^ >]+(@|:\/)[^ >]+)>},
      url:      ~r{\z\A},  # noop

      tag:      ~r{
        ^<!--[\s\S]*?--> |
        ^<\/?\w+(?: "[^"<]*" | # < inside an attribute is illegal, luckily
        '[^'<]*' |
        [^'"<>])*?>}x,

     inline_ial: ~r<^\s*\{:\s*(.*?)\s*}>,
     link:       ~r{^!?\[(#{@link_text})\]\(#{@href}\)},
     reflink:    ~r{^!?\[(#{@link_text})\]\s*\[([^]]*)\]},
     nolink:     ~r{^!?\[((?:\[[^]]*\]|[^][])*)\]},
     strong:     ~r{^__([\s\S]+?)__(?!_)|^\*\*([\s\S]+?)\*\*(?!\*)},
     em:         ~r{^\b_((?:__|[\s\S])+?)_\b|^\*((?:\*\*|[\s\S])+?)\*(?!\*)},
     code:       @code,
     br:         ~r<^ {2,}\n(?!\s*$)>,
     text:       ~r<^[\s\S]+?(?=[\\<!\[_*`]| {2,}\n|$)>,

     strikethrough: ~r{\z\A}   # noop
    ]
  end

  defp rules_for(options) do
    rule_updates = if options.gfm do
      rules = [
        escape:        ~r{^\\([\\`*\{\}\[\]()\#+\-.!_>~|])},
        url:           ~r{^(https?:\/\/[^\s<]+[^<.,:;\"\')\]\s])},
        strikethrough: ~r{^~~(?=\S)([\s\S]*?\S)~~},
        text:          ~r{^[\s\S]+?(?=[\\<!\[_*`~]|https?://| \{2,\}\n|$)}
      ]
      if options.breaks do
        break_updates = [
          br:    ~r{^ *\n(?!\s*$)},
          text:  ~r{^[\s\S]+?(?=[\\<!\[_*`~]|https?://| *\n|$)}
         ]
         Keyword.merge(rules, break_updates)
      else
        rules
      end
    else
      if options.pedantic do
        [
          strong: ~r{^__(?=\S)([\s\S]*?\S)__(?!_)|^\*\*(?=\S)([\s\S]*?\S)\*\*(?!\*)},
          em:     ~r{^_(?=\S)([\s\S]*?\S)_(?!_)|^\*(?=\S)([\s\S]*?\S)\*(?!\*)}
        ]
      else
        []
      end
    end
    footnote = if options.footnotes, do: ~r{^\[\^(#{@link_text})\]}, else: ~r{\z\A}
    rule_updates = Keyword.merge(rule_updates, [footnote: footnote])
    Keyword.merge(basic_rules(), rule_updates)
    |> Enum.into(%{})
  end

  # Smartypants transformations convert quotes to the appropriate curly
  # variants, and -- and ... to – and …
  defp smartypants(text) do
    text
    |> replace(~r{--}, "—")
    |> replace(~r{(^|[-—/\(\[\{"”“\s])'}, "\\1‘")
    |> replace(~r{\'}, "’")
    |> replace(~r{(^|[-—/\(\[\{‘\s])\"}, "\\1“")
    |> replace(~r{"}, "”")
    |> replace(~r{\.\.\.}, "…")
  end

end
