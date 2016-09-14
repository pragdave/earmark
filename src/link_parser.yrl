Nonterminals link_title inside_brackets inside_part.
Terminals open_bracket close_bracket open_paren close_paren verbatim.
Rootsymbol link_title.

link_title -> open_bracket close_bracket          : []. 
link_title -> open_bracket inside_brackets close_bracket : '$2'.

inside_brackets -> inside_part                       : '$1'.
inside_brackets -> inside_part inside_brackets       : string:concat('$1', '$2').

inside_part     -> verbatim                          : extract_token('$1').
inside_part     -> open_paren                        : "(".
inside_part     -> close_paren                       : ")".
inside_part     -> open_bracket inside_brackets close_bracket : string:join(["[", '$2', "]"], "").

Erlang code.

extract_token({_Token, _Line, Value}) -> Value.
