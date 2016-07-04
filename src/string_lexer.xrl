Definitions.

NOESCAPES   = [^`\\]+
ESCAPEDBTX  = \\`
ESCAPED     = \\.
ESCAPE      = \\
BACKTIX     = `+

Rules.

{NOESCAPES}   : {token, {verbatim, TokenLine, TokenChars}}.
{ESCAPEDBTX}  : {token, {verbatim, TokenLine, '`'}}.
{ESCAPED}     : {token, {verbatim, TokenLine, TokenChars}}.
{BACKTIX}     : {token, {backtix, TokenLine, TokenChars}}.
{ESCAPE}      : {token, {verbatim, TokenLine, TokenChars}}.

Erlang code.
