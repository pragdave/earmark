Definitions.

NOESCAPES      = [^]"'\\()[]+
ESCAPED        = \\.
OPEN_PAREN     = \(
CLOSE_PAREN    = \)
OPEN_BRACKET   = \[
CLOSE_BRACKET  = \]
ANY_QUOTE      = ["']
ANY            = [^]\\"'()[]+

Rules.

{NOESCAPES}     : {token, {verbatim, TokenLine, TokenChars}}.
{ESCAPED}       : {token, {verbatim, TokenLine, dismiss_backslash(TokenChars)}}.
{OPEN_PAREN}    : {token, {open_paren, TokenLine, TokenChars}}.
{CLOSE_PAREN}   : {token, {close_paren, TokenLine, TokenChars}}.
{OPEN_BRACKET}  : {token, {open_bracket, TokenLine, TokenChars}}.
{CLOSE_BRACKET} : {token, {close_bracket, TokenLine, TokenChars}}.
{ANY_QUOTE}     : {token, {any_quote, TokenLine, TokenChars}}.
{ANY}           : {token, {verbatim, TokenLine, TokenChars}}.

Erlang code.

dismiss_backslash([$\\|Chars]) -> Chars.
