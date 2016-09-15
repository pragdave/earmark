Nonterminals link link_title link_url inside_brackets inside_brackets_part inside_parens inside_parens_part.
Terminals open_bracket close_bracket open_paren close_paren verbatim.
Rootsymbol link.

link       -> link_title link_url                 : extend_text_part('$1', '$2'). 

%
% TEXT part
%
link_title -> open_bracket close_bracket          : {"[]", []}. 
link_title -> open_bracket inside_brackets close_bracket : title_tuple('$2').

inside_brackets -> inside_brackets_part                       : '$1'.
inside_brackets -> inside_brackets_part inside_brackets       : string:concat('$1', '$2').

inside_brackets_part -> verbatim                                   : extract_token('$1').
inside_brackets_part -> open_paren                                 : "(".
inside_brackets_part -> close_paren                                : ")".
inside_brackets_part -> open_bracket inside_brackets close_bracket : string:join(["[", "]"], '$2').

%
% URL part
%
link_url -> open_paren close_paren                : [].
link_url -> open_paren inside_parens close_paren  : '$2'. 

inside_parens -> inside_parens_part               : '$1'.
inside_parens -> inside_parens_part inside_parens : string:concat('$1', '$2').

inside_parens_part -> verbatim                             : extract_token('$1').
inside_parens_part -> open_bracket                         : "[".
inside_parens_part -> close_bracket                        : "]".
inside_parens_part -> open_paren inside_parens close_paren : string:join(["(", ")"], '$2').

Erlang code.

extend_text_part({FullText, Text}, Url) -> {string:join([FullText, "(", Url, ")"], ""), Text, Url}.

extract_token({_Token, _Line, Value}) -> Value.

title_tuple(Title) -> {string:join(["[", "]"], Title), Title}.
