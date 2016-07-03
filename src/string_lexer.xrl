Definitions.

NOESCAPES   = [^`\\]+
ESCAPE      = \\
BACKTIX     = `+

Rules.

{NOESCAPES}   : {token, {verbatim, TokenLine, TokenChars}}.
{ESCAPE}      : {token, {escape, TokenLine, TokenChars}}.
{BACKTIX}     : {token, {backtix, TokenLine, TokenChars}}.

Erlang code.
