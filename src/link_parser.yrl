Nonterminals link link_text link_url link_title
             inside_brackets inside_brackets_part 
             inside_parens inside_parens_part
             inside_quotes inside_quotes_part.

Terminals any_quote open_bracket close_bracket open_paren close_paren verbatim.

Rootsymbol link.

%
% RULES
% =====
%
link       -> link_text link_url                 : extend_text_part('$1', '$2'). 

%
% TEXT part
%
link_text -> open_bracket close_bracket          : {"[]", []}. 
link_text -> open_bracket inside_brackets close_bracket : title_tuple('$2').

inside_brackets -> inside_brackets_part                       : '$1'.
inside_brackets -> inside_brackets_part inside_brackets       : string:concat('$1', '$2').

inside_brackets_part -> verbatim                                   : extract_token('$1').
inside_brackets_part -> any_quote                                  : extract_token('$1').
inside_brackets_part -> open_paren                                 : "(".
inside_brackets_part -> close_paren                                : ")".
inside_brackets_part -> open_bracket inside_brackets close_bracket : join_strings(["[", '$2', "]"]).

%
% URL part
%
link_url -> open_paren close_paren                : {[], [], nil}.
link_url -> open_paren inside_parens close_paren  : {join_strings(["(", '$2',")"]), '$2', nil}.
link_url -> open_paren inside_parens link_title close_paren : {join_strings(["(", '$2', '$3',"]"]), '$2', remove_quotes('$3')}.

inside_parens -> inside_parens_part               : '$1'.
inside_parens -> inside_parens_part inside_parens : string:concat('$1', '$2').

inside_parens_part -> verbatim                             : extract_token('$1').
inside_parens_part -> open_bracket                         : "[".
inside_parens_part -> close_bracket                        : "]".
inside_parens_part -> open_paren inside_parens close_paren : join_strings(["(", '$2', ")"]).

%
% TITLE part
%
link_title -> any_quote inside_quotes any_quote             : join_tokens(['$1', '$2', '$3']).

inside_quotes -> inside_quotes_part              : '$1'. 
inside_quotes -> inside_quotes_part inside_quotes : string:concat('$1', '$2').

inside_quotes_part -> verbatim : extract_token('$1').
inside_quotes_part -> open_bracket : extract_token('$1').
inside_quotes_part -> close_bracket : extract_token('$1').
inside_quotes_part -> open_paren : extract_token('$1').
inside_quotes_part -> close_paren : extract_token('$1').
% I feel we have a REDUCE conflict here ???!!!
inside_quotes_part -> any_quote : extract_token('$1').

Erlang code.

extend_text_part({FullText, Text}, {UrlText, Url, Title}) -> {join_strings([FullText, "(", UrlText, ")"]), Text, Url, Title}.

extract_token({_Token, _Line, Value}) -> Value.
extract_token(String)                 -> String.

join_strings(Strings) -> string:join(Strings, "").

join_tokens(Symbols) -> join_strings([ extract_token(S) || S <- Symbols ]).

remove_quotes(String) -> string:sub_string(String, 2, string:len(String)-1).

title_tuple(Title) -> {string:join(["[", "]"], Title), Title}.
