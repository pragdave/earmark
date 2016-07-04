Definitions.

NOESCAPES   = [^`\\]+
ESCAPED     = \\.
ESCAPE      = \\
BACKTIX     = `+

Rules.

{NOESCAPES}   : {token, {verbatim, TokenLine, TokenChars}}.
{ESCAPED}     : {token, {verbatim, TokenLine, tl(TokenChars)}}.
{BACKTIX}     : {token, {backtix, TokenLine, TokenChars}}.
{ESCAPE}      : {token, {verbatim, TokenLine, ''}}.

Erlang code.
