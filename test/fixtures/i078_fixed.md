  Returns a new string created by replacing occurrences of `pattern` in
  `subject` with `replacement`.

  By default, it replaces all occurrences, unless the `global` option is
  set to `false`, where it will only replace the first one

  The `pattern` may be a string or a regular expression.

  ## Examples

      iex> String.replace("a,b,c", ",", "-")
      "a-b-c"

      iex> String.replace("a,b,c", ",", "-", global: false)
      "a-b,c"

  When the pattern is a regular expression, one can give `\N` or
  `\g{N}` in the `replacement` string to access a specific capture in the
  regular expression:

      iex> String.replace("a,b,c", ~r/,(.)/, ",\\1\\g{1}")
      "a,bb,cc"

  Notice we had to escape the escape character `\\`. By giving `\0`,
  one can inject the whole matched pattern in the replacement string.

  When the pattern is a string, a developer can use the replaced part inside
  the `replacement` by using the `:insert_replace` option and specifying the
  position(s) inside the `replacement` where the string pattern will be
  inserted:

      iex> String.replace("a,b,c", "b", "[]", insert_replaced: 1)
      "a,[b],c"

      iex> String.replace("a,b,c", ",", "[]", insert_replaced: 2)
      "a[],b[],c"

      iex> String.replace("a,b,c", ",", "[]", insert_replaced: [1, 1])
      "a[,,]b[,,]c"

  If any position given in the `:insert_replace` option is larger than the
  replacement string, or is negative, an `ArgumentError` is raised.
