Nonterminals link_text
             inside_brackets inside_brackets_part.

Terminals  open_bracket close_bracket open_paren close_paren verbatim.

Rootsymbol link_text.

link_text -> open_bracket close_bracket          : {"[]", []}.
link_text -> open_bracket inside_brackets close_bracket : title_tuple('$2').

inside_brackets -> inside_brackets_part                       : '$1'.
inside_brackets -> inside_brackets_part inside_brackets       : string:concat('$1', '$2').

inside_brackets_part -> verbatim                                   : extract_token('$1').
inside_brackets_part -> open_paren                                 : "(".
inside_brackets_part -> close_paren                                : ")".
inside_brackets_part -> open_bracket inside_brackets close_bracket : join_strings(["[", '$2', "]"]).

Erlang code.

extract_token({_Token, _Line, Value}) -> Value.

join_strings(Strings) -> string:join(Strings, "").

title_tuple(Title) -> {string:join(["[", "]"], Title), Title}.
