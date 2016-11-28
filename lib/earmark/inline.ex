defmodule Earmark.Inline do

  @moduledoc """
  Match and render inline sequences, passing each to the
  renderer.
  """

  import Earmark.Helpers
  import Earmark.Helpers.StringHelpers, only: [behead: 2]
  alias Earmark.Context
  alias Earmark.Helpers.LinkParser

  @doc false
  def convert(src, context) when is_list(src) do
    convert(Enum.join(src, "\n"), context)
  end

  def convert(src, context) do
    convert_each({src, context, []}, all_converters())
  end

  @linky_converter_names [:converter_for_link, :converter_for_reflink, :converter_for_footnote, :converter_for_nolink]

  defp all_converters do
    [
      converter_for_escape:             &converter_for_escape/2,
      converter_for_autolink:           &converter_for_autolink/2,
      converter_for_tag:                &converter_for_tag/2,
      converter_for_link:               &converter_for_link/2,
      converter_for_img:                &converter_for_img/2,
      converter_for_reflink:            &converter_for_reflink/2,
      converter_for_footnote:           &converter_for_footnote/2,
      converter_for_nolink:             &converter_for_nolink/2,
      converter_for_strikethrough_gfm:  &converter_for_strikethrough_gfm/2,
      converter_for_strong:             &converter_for_strong/2,
      converter_for_em:                 &converter_for_em/2,
      converter_for_code:               &converter_for_code/2,
      converter_for_br:                 &converter_for_br/2,
      converter_for_text:               &converter_for_text/2
    ]
  end


  defp convert_each({"", _context, result}, _converters) do
    result
    |> IO.iodata_to_binary
    |> replace(~r{(</[^>]*>)‘}, "\\1’")
    |> replace(~r{(</[^>]*>)“}, "\\1”")
  end

  defp convert_each(data = {_src, context, _result}, converters) do
    with new_data <- converters
      |> Enum.find_value( fn {_converter_name, converter_fun} -> converter_fun.(data, context.options.renderer) end ),
      do: convert_each(new_data, all_converters())
  end

  defp converter_for_escape({src, context, result}, _renderer) do
    if match = Regex.run(context.rules.escape, src) do
      [ match, escaped ] = match
      {behead(src, match), context, [result | escaped]}
    end
  end

  defp converter_for_autolink({src, context, result}, renderer) do
    if match = Regex.run(context.rules.autolink, src) do
      [ match, link, protocol ] = match
      { href, text } = convert_autolink(link, protocol)
      out = renderer.link(href, text)
      { behead(src, match), context, [ result | out ] }
    end
  end

  defp converter_for_tag({src, context, result}, _renderer) do
    if match = Regex.run(context.rules.tag, src) do
      [ match ] = match
      out = context.options.do_sanitize.(match)
      { behead(src, match), context, [ result | out ] }
    end
  end

  # TODO: v1.2 Fix this `mess` where mess in
  #       as we need to parse the url part for nested (), and [] expressions (from issues #88 and #70, as well as #89 and #90, but
  #       the later two are _home made_)
  #       a regex will not do. As however we have to accept the following title strings (for backwards compatibility before v1.2)
  #                 [...](url "title")and still title")  --> title = ~s<title")and still title>
  #       yecc will not do (we are  not LALR-1 not even LALR-k or LR-k :@ !!!!
  #       therefor this complicated recursive descent bailing out parser I did not want to write in the first place...
  #       Oh yes and of course I cannot even preparse the url part because of this e.g.
  #                 [...](url "((((((")
  defp converter_for_link({src, context, result}, _renderer) do
    if match = LinkParser.parse_link(src) do
      # TODO: Write a parser for links and a parser for images
      unless is_image?(match) do
        {match, text, href, title} = match
        out = output_link(context, text, href, title)
        { behead(src, match), context, [ result | out ] }
      end
    end
  end

  defp is_image?( {match_text, _, _, _} ), do: String.starts_with?(match_text, "!")

  defp converter_for_img({src, context, result}, _renderer) do
    if match = LinkParser.parse_link(src) do
      # TODO: Write a parser for links and a parser for images
      if is_image?(match) do
        {match, text, href, title} = match
        out = output_image(context.options.renderer, text, href, title)
        { behead(src, match), context, [ result | out ] }
      end
    end
  end

  defp converter_for_reflink({src, context, result}, _renderer) do
    if match = Regex.run(context.rules.reflink, src) do
      { match, alt_text, id } = case match do
        [ match, id, "" ]       -> { match, id, id  }
        [ match, alt_text, id ] -> { match, alt_text, id }
      end
      case reference_link(context, match, alt_text, id) do
        {:ok, out}    -> { behead(src, match), context, [ result | out ] }
        {:error, out} -> { behead(src, out), context, [ result | out ] }
        end
      end
    end

  defp converter_for_footnote({src, context, result}, _renderer) do
    if match = Regex.run(context.rules.footnote, src) do
      [match, id] = match
      out = footnote_link(context, match, id)
      { behead(src, match), context, [ result | out ] }
    end
  end

  defp converter_for_nolink({src, context, result}, _renderer) do
    if match = Regex.run(context.rules.nolink, src) do
      [ match, id ] = match
      case reference_link(context, match, id, id) do
          {:ok, out}    -> { behead(src, match), context, [ result | out ] }
          {:error, out} -> { behead(src, out), context, [ result | out ] }
      end
    end
  end

  defp converter_for_strikethrough_gfm({src, context, result}, renderer) do
    if match = Regex.run(context.rules.strikethrough, src) do
      [ match, content ] = match
      out = renderer.strikethrough(convert(content, context))
      { behead(src, match), context, [ result | out ] }
    end
  end

  defp converter_for_strong({src, context, result}, renderer) do
    if match = Regex.run(context.rules.strong, src) do
      { match, content } = case match do
        [ m, _, c ] -> {m, c}
        [ m, c ]    -> {m, c}
      end
      out = renderer.strong(convert(content, context))
      { behead(src, match), context, [ result | out ] }
    end
  end

  defp converter_for_em({src, context, result}, renderer) do
    if match = Regex.run(context.rules.em, src) do
      { match, content } = case match do
        [ m, _, c ] -> {m, c}
        [ m, c ]    -> {m, c}
      end
      out = renderer.em(convert(content, context))
      { behead(src, match), context, [ result | out ] }
    end
  end

  defp converter_for_code({src, context, result}, renderer) do
    if match = Regex.run(context.rules.code, src) do
      [match, _, content] = match
      content = String.strip(content)  # this from Gruber
      out = renderer.codespan(escape(content, true))
      { behead(src, match), context, [ result | out ] }
    end
  end

  defp converter_for_br({src, context, result}, renderer) do
    if match = Regex.run(context.rules.br, src, return: :index) do
      out = renderer.br()
      [ {0, match_len} ] = match
      { behead(src, match_len), context, [ result | out ] }
    end
  end

  defp converter_for_text({src, context, result}, _renderer) do
    if match = Regex.run(context.rules.text, src) do
      [ match ] = match
      out = escape(context.options.do_smartypants.(match))
      { behead(src, match), context, [ result | out ] }
    end
  end

  defp convert_autolink(link, _separator = "@") do
    link = (if String.at(link, 6) == ":", do: behead(link, 7), else: link)
    text = mangle_link(link)
    href = mangle_link("mailto:") <> text
    { encode(href), escape(text) }
  end

  defp convert_autolink(link, _separator) do
    link = encode(link)
    { link, link }
  end

  @doc """
  Smartypants transformations convert quotes to the appropriate curly
  variants, and -- and ... to – and …
  """

  def smartypants(text) do
    text
    |> replace(~r{--}, "—")
    |> replace(~r{(^|[-—/\(\[\{"”“\s])'}, "\\1‘")
    |> replace(~r{\'}, "’")
    |> replace(~r{(^|[-—/\(\[\{‘\s])\"}, "\\1“")
    |> replace(~r{"}, "”")
    |> replace(~r{\.\.\.}, "…")
  end


  @doc false
  def mangle_link(link) do
    link
  end


  defp output_image_or_link(context, "!" <> _, text, href, title) do
    output_image(context.options.renderer, text, href, title)
  end

  defp output_image_or_link(context, _, text, href, title) do
    output_link(context, text, href, title)
  end

  defp output_link(context, text, href, title) do
    href = encode(href)
    title = if title, do: escape(title), else: nil
    link = convert_each({text, context, []},
                        Keyword.drop(all_converters(), @linky_converter_names))
    context.options.renderer.link(href, link, title)
  end

  defp output_footnote_link(context, ref, back_ref, number) do
    ref = encode(ref)
    back_ref = encode(back_ref)
    context.options.renderer.footnote_link(ref, back_ref, number)
  end

  defp output_image(renderer, text, href, title) do
    href = encode(href)
    title = if title, do: escape(title), else: nil
    renderer.image(href, escape(text), title)
  end

  defp reference_link(context, match, alt_text, id) do
    id = id |> replace(~r{\s+}, " ") |> String.downcase

    case Map.fetch(context.links, id) do
      {:ok, link } -> {:ok, output_image_or_link(context, match, alt_text, link.url, link.title)}
      # And here we need to reinject part of match into convert_each as we need to parse it after pulling off just one [ or ![
      _            -> {:error, Regex.replace( ~r{^(!?\[).*}, match, "\\1" )}
      end
  end

  defp footnote_link(context, _match, id) do
    with {:ok, %{number: number}} <- Map.fetch(context.footnotes, id),
    do:
    output_footnote_link(context, "fn:#{number}", "fnref:#{number}", number)
  end


  ##############################################################################
  # Handle adding option specific rules and processors                         #
  ##############################################################################

  defp noop(text), do: text

  @doc false
  # this is called by the command line processor to update
  # the inline-specific rules in light of any options
  def update_context(context =  %Context{options: options}) do
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

     link:     ~r{^!?\[(#{@link_text})\]\(#{@href}\)},
     reflink:  ~r{^!?\[(#{@link_text})\]\s*\[([^]]*)\]},
     nolink:   ~r{^!?\[((?:\[[^]]*\]|[^][])*)\]},
     strong:   ~r{^__([\s\S]+?)__(?!_)|^\*\*([\s\S]+?)\*\*(?!\*)},
     em:       ~r{^\b_((?:__|[\s\S])+?)_\b|^\*((?:\*\*|[\s\S])+?)\*(?!\*)},
     code:     @code,
     br:       ~r<^ {2,}\n(?!\s*$)>,
     text:     ~r<^[\s\S]+?(?=[\\<!\[_*`]| {2,}\n|$)>,

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
end
