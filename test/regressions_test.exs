defmodule RegressionsTest do
  use ExUnit.Case

  @cowboy_readme """
  Cowboy
  ======

  Cowboy is a small, fast and modular HTTP server written in Erlang.

  Goals
  -----

  Cowboy aims to provide a **complete** HTTP stack in a **small** code base.
  It is optimized for **low latency** and **low memory usage**, in part
  because it uses **binary strings**.

  Cowboy provides **routing** capabilities, selectively dispatching requests
  to handlers written in Erlang.

  Because it uses Ranch for managing connections, Cowboy can easily be
  **embedded** in any other application.

  No parameterized module. No process dictionary. **Clean** Erlang code.

  Sponsors
  --------

  The SPDY implementation was sponsored by
  [LeoFS Cloud Storage](http://www.leofs.org).

  The project is currently sponsored by
  [Kato.im](https://kato.im).

  Online documentation
  --------------------

   *  [User guide](http://ninenines.eu/docs/en/cowboy/HEAD/guide)
   *  [Function reference](http://ninenines.eu/docs/en/cowboy/HEAD/manual)

  Offline documentation
  ---------------------

   *  While still online, run `make docs`
   *  Function reference man pages available in `doc/man3/` and `doc/man7/`
   *  Run `make install-docs` to install man pages on your system
   *  Full documentation in Markdown available in `doc/markdown/`
   *  Examples available in `examples/`

  Getting help
  ------------

   *  Official IRC Channel: #ninenines on irc.freenode.net
   *  [Mailing Lists](http://lists.ninenines.eu)
   *  [Commercial Support](http://ninenines.eu/support)
  """

  test "rendering the Cowboy webserver README" do
    Earmark.to_html @cowboy_readme
  end

  @issue_12 """
    iex> {:ambiguous, am} = Kalends
    {:error, :no_matches}
  """  

  test "Issue https://github.com/pragdave/earmark/issues/12" do
    alias Earmark.Options
    result = catch_error(Earmark.to_html @issue_12, %Options{mapper: &Enum.map/2})
    assert result.message == "Invalid Markdown attributes: {error, :no_matches}"
  end

  test "Issue https://github.com/pragdave/earmark/issues/17" do
    Earmark.to_html "A\nB\n="
  end

  @indented_list  """
    Para

    1. l1

    2. l2
  """

  test "https://github.com/pragdave/earmark/issues/13" do
    result = Earmark.to_html @indented_list
    assert result == """
                     <p>  Para</p>
                     <ol>
                     <li><p>l1</p>
                     </li>
                     <li>l2
                     </li>
                     </ol>
                     """
  end

end
