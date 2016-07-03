Definitions.

NOESCAPES   = [^`\\]+
ESCAPED     = \\.
BACKTIX     = `+

Rules.

{NOESCAPES}   : {token, {verbatim, TokenLine, TokenChars}}.
{ESCAPED}     : {token, {verbatim, TokenLine, tl(TokenChars)}}.
{BACKTIX}     : {token, {backtix, TokenLine, TokenChars}}.

Erlang code.
