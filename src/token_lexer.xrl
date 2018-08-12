Definitions.

BACKSLASH   = \\
BACKTICKS   = ``*
CARET       = \^
COLON       = :
DASHES      = -+
DQUOTE      = "
EQUALS      = =+
GT          = >+
HASHES      = #+
LACCOLADE   = \{
LBRACKET    = \[
LPAREN      = \(
LT          = <+
RACCOLADE   = \}
RBRACKET    = \]
RPAREN      = \)
SLASHES     = /+
SQUOTE      = '
SYMBOLS     = [&|@$?;,%!§]+
STARS       = \*+
TILDES      = ~+
UNDERSCORES = _+
WHITESPACE  = \s+

REST        = [[^\][\(\)-><*_+\s"'\\\{\}&|@$?;,%!§]
TRAILING    = [^\][\(\)><*+\s"'\\\{\}&|@^$?;,%!§]
ALPHANUM    = {REST}{TRAILING}*

Rules.

{BACKSLASH} : {token, {backslash, TokenLine, TokenChars}}.
{BACKSLASH}. : {token, {verbatim, TokenLine, dismiss_backslash(TokenChars)}}.
{BACKTICKS} : {token, {backticks, TokenLine, TokenChars}}.
{CARET} : {token, {caret, TokenLine, TokenChars}}.
{COLON} : {token, {colon, TokenLine, TokenChars}}.
{DASHES} : {token, {dashes, TokenLine, TokenChars}}.
{DQUOTE} : {token, {dquote, TokenLine, TokenChars}}.
{EQUALS} : {token, {equals, TokenLine, TokenChars}}.
{GT} : {token, {gt, TokenLine, TokenChars}}.
{HASHES} : {token, {hashes, TokenLine, TokenChars}}.
{LACCOLADE} : {token, {laccolade, TokenLine, TokenChars}}.
{LBRACKET} : {token, {lbracket, TokenLine, TokenChars}}.
{LPAREN} : {token, {lparen, TokenLine, TokenChars}}.
{LT} : {token, {lt, TokenLine, TokenChars}}.
{RACCOLADE} : {token, {raccolade, TokenLine, TokenChars}}.
{RBRACKET} : {token, {rbracket, TokenLine, TokenChars}}.
{RPAREN} : {token, {rparen, TokenLine, TokenChars}}.
{SLASHES} : {token, {slashes, TokenLine, TokenChars}}.
{SQUOTE} : {token, {squote, TokenLine, TokenChars}}.
{STARS} : {token, {stars, TokenLine, TokenChars}}.
{SYMBOLS} : {token, {symbols, TokenLine, TokenChars}}.
{TILDES} : {token, {tildes, TokenLine, TokenChars}}.
{UNDERSCORES} : {token, {underscores, TokenLine, TokenChars}}.
{WHITESPACE} : {token, {whitespace, TokenLine, TokenChars}}.

{ALPHANUM} : {token, {verbatim, TokenLine, TokenChars}}.



Erlang code.

dismiss_backslash([$\\|Chars]) -> Chars.
