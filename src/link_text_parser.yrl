Nonterminals link_text rest
             inside_brackets inside_brackets_part anything.

Terminals any_quote open_bracket close_bracket open_paren close_paren verbatim escaped.

Rootsymbol link_text.

link_text -> open_bracket close_bracket                      : {"", "[]"}.
link_text -> open_bracket close_bracket rest                 : {"", "[]"}.
link_text -> open_bracket inside_brackets close_bracket      : title_tuple('$2').
link_text -> open_bracket inside_brackets close_bracket rest : title_tuple('$2').

inside_brackets -> inside_brackets_part                       : '$1'.
inside_brackets -> inside_brackets_part inside_brackets       : concat_tuple('$1', '$2').

inside_brackets_part -> verbatim                                   : extract_token('$1').
inside_brackets_part -> open_paren                                 : {"(", "("}.
inside_brackets_part -> close_paren                                : {")", ")"}.
inside_brackets_part -> any_quote                                  : extract_token('$1').
inside_brackets_part -> escaped                                    : escaped_token('$1').
inside_brackets_part -> open_bracket inside_brackets close_bracket : concat_3t("[", '$2', "]").

rest     -> anything.
rest     -> anything rest.

anything -> verbatim.
anything -> open_paren.
anything -> close_paren.
anything -> any_quote.
anything -> escaped.
anything -> open_bracket inside_brackets close_bracket.

Erlang code.

concat_tuple({LT, LP}, {RT, RP}) -> {string:concat(LT, RT), string:concat(LP, RP)}.
concat_3t(L, {MT, MP}, R) -> {string:join([L, MT, R], ""), string:join([ L, MP, R ], "")}.

escaped_token({_Token, _Line, Value}) -> {Value, string:concat("\\", Value)}.

extract_token({_Token, _Line, Value}) -> {Value, Value}.

title_tuple({Title, Parsed}) -> {Title, string:join(["[", Parsed, "]"], "")}. 
