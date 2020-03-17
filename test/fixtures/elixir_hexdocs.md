
# moddoc for Application

A module for working with applications and defining application callbacks.

Applications are the idiomatic way to package software in Erlang/OTP. To get
the idea, they are similar to the "library" concept common in other
programming languages, but with some additional characteristics.

An application is a component implementing some specific functionality, with a
standardized directory structure, configuration, and lifecycle. Applications
are *loaded*, *started*, and *stopped*. Each application also has its own
environment, which provides a unified API for configuring each application.

Developers typically interact with the application environment and its
callback module. Therefore those will be the topics we will cover first
before jumping into details about the application resource file and life-cycle.

## The application environment

Each application has its own environment. The environment is a keyword list
that maps atoms to terms. Note that this environment is unrelated to the
operating system environment.

By default, the environment of an application is an empty list. In a Mix
project's `mix.exs` file, you can set the `:env` key in `application/0`:

    def application do
      [env: [db_host: "localhost"]]
    end

Now, in your application, you can read this environment by using functions
such as `fetch_env!/2` and friends:

    defmodule MyApp.DBClient do
      def start_link() do
        SomeLib.DBClient.start_link(host: db_host())
      end

      defp db_host do
        Application.fetch_env!(:my_app, :db_host)
      end
    end

In Mix projects, the environment of the application and its dependencies can
be overridden via the `config/config.exs` file. For example, someone using
your application can override its `:db_host` environment variable as follows:

    import Config
    config :my_app, :db_host, "db.local"

You can also change the application environment dynamically by using functions
such as `put_env/3` and `delete_env/2`. However, as a rule of thumb, each application
is responsible for its own environment. Please do not use the functions in this
module for directly accessing or modifying the environment of other applications.

### Compile-time environment

In the previous example, we read the application environment at runtime:

    defmodule MyApp.DBClient do
      def start_link() do
        SomeLib.DBClient.start_link(host: db_host())
      end

      defp db_host do
        Application.fetch_env!(:my_app, :db_host)
      end
    end

In other words, the environment key `:db_host` for application `:my_app`
will only be read when `MyApp.DBClient` effectively starts. While reading
the application environment at runtime is the preferred approach, in some
rare occasions you may want to use the application environment to configure
the compilation of a certain project. This is often done by calling `get_env/3`
outside of a function:

    defmodule MyApp.DBClient do
      @db_host Application.get_env(:my_app, :db_host, "db.local")

      def start_link() do
        SomeLib.DBClient.start_link(host: @db_host)
      end
    end

This approach has one big limitation: if you change the value of the
application environment after the code is compiled, the value used at
runtime is not going to change! For example, if you are using `mix release`
and your `config/releases.exs` has:

    config :my_app, :db_host, "db.production"

This value will have no effect as the code was compiled to connect to "db.local",
which is mostly likely unavailable in the production environment.

For those reasons, reading the application environment at runtime should be the
first choice. However, if you really have to read the application environment
during compilation, we recommend you to use `compile_env/3` instead:

    @db_host Application.compile_env(:my_app, :db_host, "db.local")

By using `compile_env/3`, tools like Mix will store the values used during
compilation and compare the compilation values with the runtime values whenever
your system starts, raising an error in case they differ.

## The application callback module

Applications can be loaded, started, and stopped. Generally, build tools
like Mix take care of starting an application and all of its dependencies
for you, but you can also do it manually by calling:

    {:ok, _} = Application.ensure_all_started(:some_app)

When an application starts, developers may configure a callback module
that executes custom code. Developers use this callback to start the
application supervision tree.

The first step to do so is to add a `:mod` key to the `application/0`
definition in your `mix.exs` file. It expects a tuple, with the application
callback module and start argument (commonly an empty list):

    def application do
      [mod: {MyApp, []}]
    end

The `MyApp` module given to `:mod` needs to implement the `Application` behaviour.
This can be done by putting `use Application` in that module and implementing the
`c:start/2` callback, for example:

    defmodule MyApp do
      use Application

      def start(_type, _args) do
        children = []
        Supervisor.start_link(children, strategy: :one_for_one)
      end
    end

The `c:start/2` callback has to spawn and link a supervisor and return `{:ok,
pid}` or `{:ok, pid, state}`, where `pid` is the PID of the supervisor, and
`state` is an optional application state. `args` is the second element of the
tuple given to the `:mod` option.

The `type` argument passed to `c:start/2` is usually `:normal` unless in a
distributed setup where application takeovers and failovers are configured.
Distributed applications are beyond the scope of this documentation.

When an application is shutting down, its `c:stop/1` callback is called after
the supervision tree has been stopped by the runtime. This callback allows the
application to do any final cleanup. The argument is the state returned by
`c:start/2`, if it did, or `[]` otherwise. The return value of `c:stop/1` is
ignored.

By using `Application`, modules get a default implementation of `c:stop/1`
that ignores its argument and returns `:ok`, but it can be overridden.

Application callback modules may also implement the optional callback
`c:prep_stop/1`. If present, `c:prep_stop/1` is invoked before the supervision
tree is terminated. Its argument is the state returned by `c:start/2`, if it did,
or `[]` otherwise, and its return value is passed to `c:stop/1`.

## The application resource file

In the sections above, we have configured an application in the
`application/0` section of the `mix.exs` file. Ultimately, Mix will use
this configuration to create an [*application resource
file*](http://erlang.org/doc/man/app.html), which is a file called
`APP_NAME.app`. For example, the application resource file of the OTP
application `ex_unit` is called `ex_unit.app`.

You can learn more about the generation of application resource files in
the documentation of `Mix.Tasks.Compile.App`, available as well by running
`mix help compile.app`.

## The application lifecycle

### Loading applications

Applications are *loaded*, which means that the runtime finds and processes
their resource files:

    Application.load(:ex_unit)
    #=> :ok

When an application is loaded, the environment specified in its resource file
is merged with any overrides from config files.

Loading an application *does not* load its modules.

In practice, you rarely load applications by hand because that is part of the
start process, explained next.

### Starting applications

Applications are also *started*:

    Application.start(:ex_unit)
    #=> :ok

Once your application is compiled, running your system is a matter of starting
your current application and its dependencies. Differently from other languages,
Elixir does not have a `main` procedure that is responsible for starting your
system. Instead, you start one or more applications, each with their own
initialization and termination logic.

When an application is started, the `Application.load/1` is automatically
invoked if it hasn't been done yet. Then, it checks if the dependencies listed
in the `applications` key of the resource file are already started. Having at
least one dependency not started is an error condition. Functions like
`ensure_all_started/1` takes care of starting an application and all of its
dependencies for you.

If the application does not have a callback module configured, starting is
done at this point. Otherwise, its `c:start/2` callback if invoked. The PID of
the top-level supervisor returned by this function is stored by the runtime
for later use, and the returned application state is saved too, if any.

### Stopping applications

Started applications are, finally, *stopped*:

    Application.stop(:ex_unit)
    #=> :ok

Stopping an application without a callback module is defined, but except for
some system tracing, it is in practice a no-op.

Stopping an application with a callback module has three steps:

  1. If present, invoke the optional callback `c:prep_stop/1`.
  2. Terminate the top-level supervisor.
  3. Invoke the required callback `c:stop/1`.

The arguments passed to the callbacks are related to the state optionally
returned by `c:start/2`, and are documented in the section about the callback
module above.

It is important to highlight that step 2 is a blocking one. Termination of a
supervisor triggers a recursive chain of children terminations, therefore
orderly shutting down all descendant processes. The `c:stop/1` callback is
invoked only after termination of the whole supervision tree.

Shutting down a live system cleanly can be done by calling `System.stop/1`. It
will shut down every application in the opposite order they had been started.

By default, a SIGTERM from the operating system will automatically translate to
`System.stop/0`. You can also have more explicit control over operating system
signals via the `:os.set_signal/2` function.

## Tooling

The Mix build tool automates most of the application management tasks. For example,
`mix test` automatically starts your application dependencies and your application
itself before your test runs. `mix run --no-halt` boots your current project and
can be used to start a long running system. See `mix help run`.

Developers can also use `mix release` to build **releases**. Releases are able to
package all of your source code as well as the Erlang VM into a single directory.
Releases also give you explicit control over how each application is started and in
which order. They also provide a more streamlined mechanism for starting and
stopping systems, debugging, logging, as well as system monitoring.

Finally, Elixir provides tools such as escripts and archives, which are
different mechanisms for packaging your application. Those are typically used
when tools must be shared between developers and not as deployment options.
See `mix help archive.build` and `mix help escript.build` for more detail.

## Further information

For further details on applications please check the documentation of the
[`application`](http://www.erlang.org/doc/man/application.html) Erlang module,
and the
[Applications](http://www.erlang.org/doc/design_principles/applications.html)
section of the [OTP Design Principles User's
Guide](http://erlang.org/doc/design_principles/users_guide.html).


# fndoc for Application.get_env/3

Returns the value for `key` in `app`'s environment.

If the configuration parameter does not exist, the function returns the
`default` value.

**Important:** if you are reading the application environment at compilation
time, for example, inside the module definition instead of inside of a
function, see `compile_env/3` instead.

**Important:** if you are writing a library to be used by other developers,
it is generally recommended to avoid the application environment, as the
application environment is effectively a global storage. For more information,
read our [library guidelines](library-guidelines.html).

## Examples

`get_env/3` is commonly used to read the configuration of your OTP applications.
Since Mix configurations are commonly used to configure applications, we will use
this as a point of illustration.

Consider a new application `:my_app`. `:my_app` contains a database engine which
supports a pool of databases. The database engine needs to know the configuration for
each of those databases, and that configuration is supplied by key-value pairs in
environment of `:my_app`.

    config :my_app, Databases.RepoOne,
      # A database configuration
      ip: "localhost",
      port: 5433

    config :my_app, Databases.RepoTwo,
      # Another database configuration (for the same OTP app)
      ip: "localhost",
      port: 20717

    config :my_app, my_app_databases: [Databases.RepoOne, Databases.RepoTwo]

Our database engine used by `:my_app` needs to know what databases exist, and
what the database configurations are. The database engine can make a call to
`get_env(:my_app, :my_app_databases)` to retrieve the list of databases (specified
by module names). Our database engine can then traverse each repository in the
list and then call `get_env(:my_app, Databases.RepoOne)` and so forth to retrieve
the configuration of each one.


# moddoc for Enum

Provides a set of algorithms to work with enumerables.

In Elixir, an enumerable is any data type that implements the
`Enumerable` protocol. `List`s (`[1, 2, 3]`), `Map`s (`%{foo: 1, bar: 2}`)
and `Range`s (`1..3`) are common data types used as enumerables:

    iex> Enum.map([1, 2, 3], fn x -> x * 2 end)
    [2, 4, 6]

    iex> Enum.sum([1, 2, 3])
    6

    iex> Enum.map(1..3, fn x -> x * 2 end)
    [2, 4, 6]

    iex> Enum.sum(1..3)
    6

    iex> map = %{"a" => 1, "b" => 2}
    iex> Enum.map(map, fn {k, v} -> {k, v * 2} end)
    [{"a", 2}, {"b", 4}]

However, many other enumerables exist in the language, such as `MapSet`s
and the data type returned by `File.stream!/3` which allows a file to be
traversed as if it was an enumerable.

The functions in this module work in linear time. This means that, the
time it takes to perform an operation grows at the same rate as the length
of the enumerable. This is expected on operations such as `Enum.map/2`.
After all, if we want to traverse every element on a list, the longer the
list, the more elements we need to traverse, and the longer it will take.

This linear behaviour should also be expected on operations like `count/1`,
`member?/2`, `at/2` and similar. While Elixir does allow data types to
provide performant variants for such operations, you should not expect it
to always be available, since the `Enum` module is meant to work with a
large variety of data types and not all data types can provide optimized
behaviour.

Finally, note the functions in the `Enum` module are eager: they will
traverse the enumerable as soon as they are invoked. This is particularly
dangerous when working with infinite enumerables. In such cases, you should
use the `Stream` module, which allows you to lazily express computations,
without traversing collections, and work with possibly infinite collections.
See the `Stream` module for examples and documentation.


# moddoc for Kernel

`Kernel` is Elixir's default environment.

It mainly consists of:

  * basic language primitives, such as arithmetic operators, spawning of processes,
    data type handling, and others
  * macros for control-flow and defining new functionality (modules, functions, and the like)
  * guard checks for augmenting pattern matching

You can invoke `Kernel` functions and macros anywhere in Elixir code
without the use of the `Kernel.` prefix since they have all been
automatically imported. For example, in IEx, you can call:

    iex> is_number(13)
    true

If you don't want to import a function or macro from `Kernel`, use the `:except`
option and then list the function/macro by arity:

    import Kernel, except: [if: 2, unless: 2]

See `Kernel.SpecialForms.import/2` for more information on importing.

Elixir also has special forms that are always imported and
cannot be skipped. These are described in `Kernel.SpecialForms`.

## The standard library

`Kernel` provides the basic capabilities the Elixir standard library
is built on top of. It is recommended to explore the standard library
for advanced functionality. Here are the main groups of modules in the
standard library (this list is not a complete reference, see the
documentation sidebar for all entries).

### Built-in types

The following modules handle Elixir built-in data types:

  * `Atom` - literal constants with a name (`true`, `false`, and `nil` are atoms)
  * `Float` - numbers with floating point precision
  * `Function` - a reference to code chunk, created with the `fn/1` special form
  * `Integer` - whole numbers (not fractions)
  * `List` - collections of a variable number of elements (linked lists)
  * `Map` - collections of key-value pairs
  * `Process` - light-weight threads of execution
  * `Port` - mechanisms to interact with the external world
  * `Tuple` - collections of a fixed number of elements

There are two data types without an accompanying module:

  * Bitstring - a sequence of bits, created with `Kernel.SpecialForms.<<>>/1`.
    When the number of bits is divisible by 8, they are called binaries and can
    be manipulated with Erlang's `:binary` module
  * Reference - a unique value in the runtime system, created with `make_ref/0`

### Data types

Elixir also provides other data types that are built on top of the types
listed above. Some of them are:

  * `Date` - `year-month-day` structs in a given calendar
  * `DateTime` - date and time with time zone in a given calendar
  * `Exception` - data raised from errors and unexpected scenarios
  * `MapSet` - unordered collections of unique elements
  * `NaiveDateTime` - date and time without time zone in a given calendar
  * `Keyword` - lists of two-element tuples, often representing optional values
  * `Range` - inclusive ranges between two integers
  * `Regex` - regular expressions
  * `String` - UTF-8 encoded binaries representing characters
  * `Time` - `hour:minute:second` structs in a given calendar
  * `URI` - representation of URIs that identify resources
  * `Version` - representation of versions and requirements

### System modules

Modules that interface with the underlying system, such as:

  * `IO` - handles input and output
  * `File` - interacts with the underlying file system
  * `Path` - manipulates file system paths
  * `System` - reads and writes system information

### Protocols

Protocols add polymorphic dispatch to Elixir. They are contracts
implementable by data types. See `defprotocol/2` for more information on
protocols. Elixir provides the following protocols in the standard library:

  * `Collectable` - collects data into a data type
  * `Enumerable` - handles collections in Elixir. The `Enum` module
    provides eager functions for working with collections, the `Stream`
    module provides lazy functions
  * `Inspect` - converts data types into their programming language
    representation
  * `List.Chars` - converts data types to their outside world
    representation as charlists (non-programming based)
  * `String.Chars` - converts data types to their outside world
    representation as strings (non-programming based)

### Process-based and application-centric functionality

The following modules build on top of processes to provide concurrency,
fault-tolerance, and more.

  * `Agent` - a process that encapsulates mutable state
  * `Application` - functions for starting, stopping and configuring
    applications
  * `GenServer` - a generic client-server API
  * `Registry` - a key-value process-based storage
  * `Supervisor` - a process that is responsible for starting,
    supervising and shutting down other processes
  * `Task` - a process that performs computations
  * `Task.Supervisor` - a supervisor for managing tasks exclusively

### Supporting documents

Elixir documentation also includes supporting documents under the
"Pages" section. Those are:

  * [Compatibility and Deprecations](compatibility-and-deprecations.html) - lists
    compatibility between every Elixir version and Erlang/OTP, release schema;
    lists all deprecated functions, when they were deprecated and alternatives
  * [Library Guidelines](library-guidelines.html) - general guidelines, anti-patterns,
    and rules for those writing libraries
  * [Naming Conventions](naming-conventions.html) - naming conventions for Elixir code
  * [Operators](operators.html) - lists all Elixir operators and their precedence
  * [Patterns and Guards](patterns-and-guards.html) - an introduction to patterns,
    guards, and extensions
  * [Syntax Reference](syntax-reference.html) - the language syntax reference
  * [Typespecs](typespecs.html)- types and function specifications, including list of types
  * [Unicode Syntax](unicode-syntax.html) - outlines Elixir support for Unicode
  * [Writing Documentation](writing-documentation.html) - guidelines for writing
    documentation in Elixir

## Guards

This module includes the built-in guards used by Elixir developers.
They are a predefined set of functions and macros that augment pattern
matching, typically invoked after the `when` operator. For example:

    def drive(%User{age: age}) when age >= 16 do
      ...
    end

The clause above will only be invoked if the user's age is more than
or equal to 16. Guards also support joining multiple conditions with
`and` and `or`. The whole guard is true if all guard expressions will
evaluate to `true`. A more complete introduction to guards is available
[in the "Patterns and Guards" page](patterns-and-guards.html).

## Inlining

Some of the functions described in this module are inlined by
the Elixir compiler into their Erlang counterparts in the
[`:erlang` module](http://www.erlang.org/doc/man/erlang.html).
Those functions are called BIFs (built-in internal functions)
in Erlang-land and they exhibit interesting properties, as some
of them are allowed in guards and others are used for compiler
optimizations.

Most of the inlined functions can be seen in effect when
capturing the function:

    iex> &Kernel.is_atom/1
    &:erlang.is_atom/1

Those functions will be explicitly marked in their docs as
"inlined by the compiler".

## Truthy and falsy values

Besides the booleans `true` and `false`, Elixir has the
concept of a "truthy" or "falsy" value.

  *  a value is truthy when it is neither `false` nor `nil`
  *  a value is falsy when it is either `false` or `nil`

Elixir has functions, like `and/2`, that *only* work with
booleans, but also functions that work with these
truthy/falsy values, like `&&/2` and `!/1`.

### Examples

We can check the truthiness of a value by using the `!/1`
function twice.

Truthy values:

    iex> !!true
    true
    iex> !!5
    true
    iex> !![1,2]
    true
    iex> !!"foo"
    true

Falsy values (of which there are exactly two):

    iex> !!false
    false
    iex> !!nil
    false



# moddoc for Module

Provides functions to deal with modules during compilation time.

It allows a developer to dynamically add, delete and register
attributes, attach documentation and so forth.

After a module is compiled, using many of the functions in
this module will raise errors, since it is out of their scope
to inspect runtime data. Most of the runtime data can be inspected
via the [`__info__/1`](`c:Module.__info__/1`) function attached to
each compiled module.

## Module attributes

Each module can be decorated with one or more attributes. The following ones
are currently defined by Elixir:

### `@after_compile`

A hook that will be invoked right after the current module is compiled.
Accepts a module or a `{module, function_name}`. See the "Compile callbacks"
section below.

### `@before_compile`

A hook that will be invoked before the module is compiled.
Accepts a module or a `{module, function_or_macro_name}` tuple.
See the "Compile callbacks" section below.

### `@behaviour`

Note the British spelling!

Behaviours can be referenced by modules to ensure they implement
required specific function signatures defined by `@callback`.

For example, you could specify a `URI.Parser` behaviour as follows:

    defmodule URI.Parser do
      @doc "Defines a default port"
      @callback default_port() :: integer

      @doc "Parses the given URL"
      @callback parse(uri_info :: URI.t()) :: URI.t()
    end

And then a module may use it as:

    defmodule URI.HTTP do
      @behaviour URI.Parser
      def default_port(), do: 80
      def parse(info), do: info
    end

If the behaviour changes or `URI.HTTP` does not implement
one of the callbacks, a warning will be raised.

For detailed documentation, see the
[behaviour typespec documentation](typespecs.html#behaviours).

### `@impl`

To aid in the correct implementation of behaviours, you may optionally declare
`@impl` for implemented callbacks of a behaviour. This makes callbacks
explicit and can help you to catch errors in your code. The compiler will warn
in these cases:

  * if you mark a function with `@impl` when that function is not a callback.

  * if you don't mark a function with `@impl` when other functions are marked
    with `@impl`. If you mark one function with `@impl`, you must mark all
    other callbacks for that behaviour as `@impl`.

`@impl` works on a per-context basis. If you generate a function through a macro
and mark it with `@impl`, that won't affect the module where that function is
generated in.

`@impl` also helps with maintainability by making it clear to other developers
that the function is implementing a callback.

Using `@impl`, the example above can be rewritten as:

    defmodule URI.HTTP do
      @behaviour URI.Parser

      @impl true
      def default_port(), do: 80

      @impl true
      def parse(info), do: info
    end

You may pass either `false`, `true`, or a specific behaviour to `@impl`.

    defmodule Foo do
      @behaviour Bar
      @behaviour Baz

      # Will warn if neither Bar nor Baz specify a callback named bar/0.
      @impl true
      def bar(), do: :ok

      # Will warn if Baz does not specify a callback named baz/0.
      @impl Baz
      def baz(), do: :ok
    end

The code is now more readable, as it is now clear which functions are
part of your API and which ones are callback implementations. To reinforce this
idea, `@impl true` automatically marks the function as `@doc false`, disabling
documentation unless `@doc` is explicitly set.

### `@compile`

Defines options for module compilation. This is used to configure
both Elixir and Erlang compilers, as any other compilation pass
added by external tools. For example:

    defmodule MyModule do
      @compile {:inline, my_fun: 1}

      def my_fun(arg) do
        to_string(arg)
      end
    end

Multiple uses of `@compile` will accumulate instead of overriding
previous ones. See the "Compile options" section below.

### `@deprecated`

Provides the deprecation reason for a function. For example:

    defmodule Keyword do
      @deprecated "Use Kernel.length/1 instead"
      def size(keyword) do
        length(keyword)
      end
    end

The Mix compiler automatically looks for calls to deprecated modules
and emit warnings during compilation.

Using the `@deprecated` attribute will also be reflected in the
documentation of the given function and macro. You can choose between
the `@deprecated` attribute and the documentation metadata to provide
hard-deprecations (with warnings) and soft-deprecations (without warnings):

This is a soft-deprecation as it simply annotates the documentation
as deprecated:

    @doc deprecated: "Use Kernel.length/1 instead"
    def size(keyword)

This is a hard-deprecation as it emits warnings and annotates the
documentation as deprecated:

    @deprecated "Use Kernel.length/1 instead"
    def size(keyword)

Currently `@deprecated` only supports functions and macros. However
you can use the `:deprecated` key in the annotation metadata to
annotate the docs of modules, types and callbacks too.

We recommend using this feature with care, especially library authors.
Deprecating code always pushes the burden towards library users. We
also recommend for deprecated functionality to be maintained for long
periods of time, even after deprecation, giving developers plenty of
time to update (except for cases where keeping the deprecated API is
undesired, such as in the presence of security issues).

### `@doc` and `@typedoc`

Provides documentation for the entity that follows the attribute.
`@doc` is to be used with a function, macro, callback, or
macrocallback, while `@typedoc` with a type (public or opaque).

Accepts a string (often a heredoc) or `false` where `@doc false` will
make the entity invisible to documentation extraction tools like
[`ExDoc`](https://hexdocs.pm/ex_doc/). For example:

    defmodule MyModule do
      @typedoc "This type"
      @typedoc since: "1.1.0"
      @type t :: term

      @doc "Hello world"
      @doc since: "1.1.0"
      def hello do
        "world"
      end

      @doc """
      Sums `a` to `b`.
      """
      def sum(a, b) do
        a + b
      end
    end

As can be seen in the example above, `@doc` and `@typedoc` also accept
a keyword list that serves as a way to provide arbitrary metadata
about the entity. Tools like [`ExDoc`](https://hexdocs.pm/ex_doc/) and
`IEx` may use this information to display annotations. A common use
case is `since` that may be used to annotate in which version the
function was introduced.

As illustrated in the example, it is possible to use these attributes
more than once before an entity. However, the compiler will warn if
used twice with binaries as that replaces the documentation text from
the preceding use. Multiple uses with keyword lists will merge the
lists into one.

Note that since the compiler also defines some additional metadata,
there are a few reserved keys that will be ignored and warned if used.
Currently these are: `:opaque` and `:defaults`.

Once this module is compiled, this information becomes available via
the `Code.fetch_docs/1` function.

### `@dialyzer`

Defines warnings to request or suppress when using a version of
`:dialyzer` that supports module attributes.

Accepts an atom, a tuple, or a list of atoms and tuples. For example:

    defmodule MyModule do
      @dialyzer {:nowarn_function, my_fun: 1}

      def my_fun(arg) do
        M.not_a_function(arg)
      end
    end

For the list of supported warnings, see
[`:dialyzer` module](http://www.erlang.org/doc/man/dialyzer.html).

Multiple uses of `@dialyzer` will accumulate instead of overriding
previous ones.

### `@external_resource`

Specifies an external resource for the current module.

Sometimes a module embeds information from an external file. This
attribute allows the module to annotate which external resources
have been used.

Tools like Mix may use this information to ensure the module is
recompiled in case any of the external resources change.

### `@file`

Changes the filename used in stacktraces for the function or macro that
follows the attribute, such as:

    defmodule MyModule do
      @doc "Hello world"
      @file "hello.ex"
      def hello do
        "world"
      end
    end

### `@moduledoc`

Provides documentation for the current module.

    defmodule MyModule do
      @moduledoc """
      A very useful module.
      """
      @moduledoc authors: ["Alice", "Bob"]
    end

Accepts a string (often a heredoc) or `false` where `@moduledoc false`
will make the module invisible to documentation extraction tools like
[`ExDoc`](https://hexdocs.pm/ex_doc/).

Similarly to `@doc` also accepts a keyword list to provide metadata
about the module. For more details, see the documentation of `@doc`
above.

Once this module is compiled, this information becomes available via
the `Code.fetch_docs/1` function.

### `@on_definition`

A hook that will be invoked when each function or macro in the current
module is defined. Useful when annotating functions.

Accepts a module or a `{module, function_name}` tuple. See the
"Compile callbacks" section below.

### `@on_load`

A hook that will be invoked whenever the module is loaded.

Accepts the function name (as an atom) of a function in the current module or
`{function_name, 0}` tuple where `function_name` is the name of a function in
the current module. The function must be public and have an arity of 0 (no
arguments). If the function does not return `:ok`, the loading of the module
will be aborted. For example:

    defmodule MyModule do
      @on_load :load_check

      def load_check do
        if some_condition() do
          :ok
        else
          :abort
        end
      end

      def some_condition do
        false
      end
    end

Modules compiled with HiPE would not call this hook.

### `@vsn`

Specify the module version. Accepts any valid Elixir value, for example:

    defmodule MyModule do
      @vsn "1.0"
    end

### Typespec attributes

The following attributes are part of typespecs and are also built-in in
Elixir:

  * `@type` - defines a type to be used in `@spec`
  * `@typep` - defines a private type to be used in `@spec`
  * `@opaque` - defines an opaque type to be used in `@spec`
  * `@spec` - provides a specification for a function
  * `@callback` - provides a specification for a behaviour callback
  * `@macrocallback` - provides a specification for a macro behaviour callback
  * `@optional_callbacks` - specifies which behaviour callbacks and macro
    behaviour callbacks are optional
  * `@impl` - declares an implementation of a callback function or macro

### Custom attributes

In addition to the built-in attributes outlined above, custom attributes may
also be added. Custom attributes are expressed using the `@/1` operator followed
by a valid variable name. The value given to the custom attribute must be a valid
Elixir value:

    defmodule MyModule do
      @custom_attr [some: "stuff"]
    end

For more advanced options available when defining custom attributes, see
`register_attribute/3`.

## Compile callbacks

There are three callbacks that are invoked when functions are defined,
as well as before and immediately after the module bytecode is generated.

### `@after_compile`

A hook that will be invoked right after the current module is compiled.

Accepts a module or a `{module, function_name}` tuple. The function
must take two arguments: the module environment and its bytecode.
When just a module is provided, the function is assumed to be
`__after_compile__/2`.

Callbacks will run in the order they are registered.

#### Example

    defmodule MyModule do
      @after_compile __MODULE__

      def __after_compile__(env, _bytecode) do
        IO.inspect(env)
      end
    end

### `@before_compile`

A hook that will be invoked before the module is compiled.

Accepts a module or a `{module, function_or_macro_name}` tuple. The
function/macro must take one argument: the module environment. If
it's a macro, its returned value will be injected at the end of the
module definition before the compilation starts.

When just a module is provided, the function/macro is assumed to be
`__before_compile__/1`.

Callbacks will run in the order they are registered. Any overridable
definition will be made concrete before the first callback runs.
A definition may be made overridable again in another before compile
callback and it will be made concrete one last time after all callbacks
run.

*Note*: unlike `@after_compile`, the callback function/macro must
be placed in a separate module (because when the callback is invoked,
the current module does not yet exist).

#### Example

    defmodule A do
      defmacro __before_compile__(_env) do
        quote do
          def hello, do: "world"
        end
      end
    end

    defmodule B do
      @before_compile A
    end

    B.hello()
    #=> "world"

### `@on_definition`

A hook that will be invoked when each function or macro in the current
module is defined. Useful when annotating functions.

Accepts a module or a `{module, function_name}` tuple. The function
must take 6 arguments:

  * the module environment
  * the kind of the function/macro: `:def`, `:defp`, `:defmacro`, or `:defmacrop`
  * the function/macro name
  * the list of quoted arguments
  * the list of quoted guards
  * the quoted function body

If the function/macro being defined has multiple clauses, the hook will
be called for each clause.

Unlike other hooks, `@on_definition` will only invoke functions and
never macros. This is to avoid `@on_definition` callbacks from
redefining functions that have just been defined in favor of more
explicit approaches.

When just a module is provided, the function is assumed to be
`__on_definition__/6`.

#### Example

    defmodule Hooks do
      def on_def(_env, kind, name, args, guards, body) do
        IO.puts("Defining #{kind} named #{name} with args:")
        IO.inspect(args)
        IO.puts("and guards")
        IO.inspect(guards)
        IO.puts("and body")
        IO.puts(Macro.to_string(body))
      end
    end

    defmodule MyModule do
      @on_definition {Hooks, :on_def}

      def hello(arg) when is_binary(arg) or is_list(arg) do
        "Hello" <> to_string(arg)
      end

      def hello(_) do
        :ok
      end
    end

## Compile options

The `@compile` attribute accepts different options that are used by both
Elixir and Erlang compilers. Some of the common use cases are documented
below:

  * `@compile :debug_info` - includes `:debug_info` regardless of the
    corresponding setting in `Code.get_compiler_option/1`

  * `@compile {:debug_info, false}` - disables `:debug_info` regardless
    of the corresponding setting in `Code.get_compiler_option/1`

  * `@compile {:inline, some_fun: 2, other_fun: 3}` - inlines the given
    name/arity pairs. Inlining is applied locally, calls from another
    module are not affected by this option

  * `@compile {:autoload, false}` - disables automatic loading of
    modules after compilation. Instead, the module will be loaded after
    it is dispatched to

  * `@compile {:no_warn_undefined, Mod}` or
    `@compile {:no_warn_undefined, {Mod, fun, arity}}` - does not warn if
    the given module or the given `Mod.fun/arity` are not defined

You can see a handful more options used by the Erlang compiler in
the documentation for the [`:compile` module](http://www.erlang.org/doc/man/compile.html).


# moddoc for Stream

Functions for creating and composing streams.

Streams are composable, lazy enumerables (for an introduction on
enumerables, see the `Enum` module). Any enumerable that generates
elements one by one during enumeration is called a stream. For example,
Elixir's `Range` is a stream:

    iex> range = 1..5
    1..5
    iex> Enum.map(range, &(&1 * 2))
    [2, 4, 6, 8, 10]

In the example above, as we mapped over the range, the elements being
enumerated were created one by one, during enumeration. The `Stream`
module allows us to map the range, without triggering its enumeration:

    iex> range = 1..3
    iex> stream = Stream.map(range, &(&1 * 2))
    iex> Enum.map(stream, &(&1 + 1))
    [3, 5, 7]

Notice we started with a range and then we created a stream that is
meant to multiply each element in the range by 2. At this point, no
computation was done. Only when `Enum.map/2` is called we actually
enumerate over each element in the range, multiplying it by 2 and adding 1.
We say the functions in `Stream` are *lazy* and the functions in `Enum`
are *eager*.

Due to their laziness, streams are useful when working with large
(or even infinite) collections. When chaining many operations with `Enum`,
intermediate lists are created, while `Stream` creates a recipe of
computations that are executed at a later moment. Let's see another
example:

    1..3
    |> Enum.map(&IO.inspect(&1))
    |> Enum.map(&(&1 * 2))
    |> Enum.map(&IO.inspect(&1))
    1
    2
    3
    2
    4
    6
    #=> [2, 4, 6]

Notice that we first printed each element in the list, then multiplied each
element by 2 and finally printed each new value. In this example, the list
was enumerated three times. Let's see an example with streams:

    stream = 1..3
    |> Stream.map(&IO.inspect(&1))
    |> Stream.map(&(&1 * 2))
    |> Stream.map(&IO.inspect(&1))
    Enum.to_list(stream)
    1
    2
    2
    4
    3
    6
    #=> [2, 4, 6]

Although the end result is the same, the order in which the elements were
printed changed! With streams, we print the first element and then print
its double. In this example, the list was enumerated just once!

That's what we meant when we said earlier that streams are composable,
lazy enumerables. Notice we could call `Stream.map/2` multiple times,
effectively composing the streams and keeping them lazy. The computations
are only performed when you call a function from the `Enum` module.

Like with `Enum`, the functions in this module work in linear time. This
means that, the time it takes to perform an operation grows at the same
rate as the length of the list. This is expected on operations such as
`Stream.map/2`. After all, if we want to traverse every element on a
stream, the longer the stream, the more elements we need to traverse,
and the longer it will take.

## Creating Streams

There are many functions in Elixir's standard library that return
streams, some examples are:

  * `IO.stream/2`         - streams input lines, one by one
  * `URI.query_decoder/1` - decodes a query string, pair by pair

This module also provides many convenience functions for creating streams,
like `Stream.cycle/1`, `Stream.unfold/2`, `Stream.resource/3` and more.

Note the functions in this module are guaranteed to return enumerables.
Since enumerables can have different shapes (structs, anonymous functions,
and so on), the functions in this module may return any of those shapes
and this may change at any time. For example, a function that today
returns an anonymous function may return a struct in future releases.


# moddoc for String

Strings in Elixir are UTF-8 encoded binaries.

Strings in Elixir are a sequence of Unicode characters,
typically written between double quoted strings, such
as `"hello"` and `"héllò"`.

In case a string must have a double-quote in itself,
the double quotes must be escaped with a backslash,
for example: `"this is a string with \"double quotes\""`.

You can concatenate two strings with the `<>/2` operator:

    iex> "hello" <> " " <> "world"
    "hello world"

## Interpolation

Strings in Elixir also support interpolation. This allows
you to place some value in the middle of a string by using
the `#{}` syntax:

    iex> name = "joe"
    iex> "hello #{name}"
    "hello joe"

Any Elixir expression is valid inside the interpolation.
If a string is given, the string is interpolated as is.
If any other value is given, Elixir will attempt to convert
it to a string using the `String.Chars` protocol. This
allows, for example, to output an integer from the interpolation:

    iex> "2 + 2 = #{2 + 2}"
    "2 + 2 = 4"

In case the value you want to interpolate cannot be
converted to a string, because it doesn't have an human
textual representation, a protocol error will be raised.

## Escape characters

Besides allowing double-quotes to be escaped with a backslash,
strings also support the following escape characters:

  * `\a` - Bell
  * `\b` - Backspace
  * `\t` - Horizontal tab
  * `\n` - Line feed (New lines)
  * `\v` - Vertical tab
  * `\f` - Form feed
  * `\r` - Carriage return
  * `\e` - Command Escape
  * `\#` - Returns the `#` character itself, skipping interpolation
  * `\xNN` - A byte represented by the hexadecimal `NN`
  * `\uNNNN` - A Unicode code point represented by `NNNN`

Note it is generally not advised to use `\xNN` in Elixir
strings, as introducing an invalid byte sequence would
make the string invalid. If you have to introduce a
character by its hexdecimal representation, it is best
to work with Unicode code points, such as `\uNNNN`. In fact,
understanding Unicode code points can be essential when doing
low-level manipulations of string, so let's explore them in
detail next.

## Code points and grapheme cluster

The functions in this module act according to the Unicode
Standard, version 12.1.0.

As per the standard, a code point is a single Unicode Character,
which may be represented by one or more bytes.

For example, although the code point "é" is a single character,
its underlying representation uses two bytes:

    iex> String.length("é")
    1
    iex> byte_size("é")
    2

Furthermore, this module also presents the concept of grapheme cluster
(from now on referenced as graphemes). Graphemes can consist of multiple
code points that may be perceived as a single character by readers. For
example, "é" can be represented either as a single "e with acute" code point
or as the letter "e" followed by a "combining acute accent" (two code points):

    iex> string = "\u0065\u0301"
    iex> byte_size(string)
    3
    iex> String.length(string)
    1
    iex> String.codepoints(string)
    ["e", "́"]
    iex> String.graphemes(string)
    ["é"]

Although the example above is made of two characters, it is
perceived by users as one.

Graphemes can also be two characters that are interpreted
as one by some languages. For example, some languages may
consider "ch" as a single character. However, since this
information depends on the locale, it is not taken into account
by this module.

In general, the functions in this module rely on the Unicode
Standard, but do not contain any of the locale specific behaviour.
More information about graphemes can be found in the [Unicode
Standard Annex #29](https://www.unicode.org/reports/tr29/).

For converting a binary to a different encoding and for Unicode
normalization mechanisms, see Erlang's `:unicode` module.

## String and binary operations

To act according to the Unicode Standard, many functions
in this module run in linear time, as they need to traverse
the whole string considering the proper Unicode code points.

For example, `String.length/1` will take longer as
the input grows. On the other hand, `Kernel.byte_size/1` always runs
in constant time (i.e. regardless of the input size).

This means often there are performance costs in using the
functions in this module, compared to the more low-level
operations that work directly with binaries:

  * `Kernel.binary_part/3` - retrieves part of the binary
  * `Kernel.bit_size/1` and `Kernel.byte_size/1` - size related functions
  * `Kernel.is_bitstring/1` and `Kernel.is_binary/1` - type-check function
  * Plus a number of functions for working with binaries (bytes)
    in the [`:binary` module](http://www.erlang.org/doc/man/binary.html)

There are many situations where using the `String` module can
be avoided in favor of binary functions or pattern matching.
For example, imagine you have a string `prefix` and you want to
remove this prefix from another string named `full`.

One may be tempted to write:

    iex> take_prefix = fn full, prefix ->
    ...>   base = String.length(prefix)
    ...>   String.slice(full, base, String.length(full) - base)
    ...> end
    iex> take_prefix.("Mr. John", "Mr. ")
    "John"

Although the function above works, it performs poorly. To
calculate the length of the string, we need to traverse it
fully, so we traverse both `prefix` and `full` strings, then
slice the `full` one, traversing it again.

A first attempt at improving it could be with ranges:

    iex> take_prefix = fn full, prefix ->
    ...>   base = String.length(prefix)
    ...>   String.slice(full, base..-1)
    ...> end
    iex> take_prefix.("Mr. John", "Mr. ")
    "John"

While this is much better (we don't traverse `full` twice),
it could still be improved. In this case, since we want to
extract a substring from a string, we can use `Kernel.byte_size/1`
and `Kernel.binary_part/3` as there is no chance we will slice in
the middle of a code point made of more than one byte:

    iex> take_prefix = fn full, prefix ->
    ...>   base = byte_size(prefix)
    ...>   binary_part(full, base, byte_size(full) - base)
    ...> end
    iex> take_prefix.("Mr. John", "Mr. ")
    "John"

Or simply use pattern matching:

    iex> take_prefix = fn full, prefix ->
    ...>   base = byte_size(prefix)
    ...>   <<_::binary-size(base), rest::binary>> = full
    ...>   rest
    ...> end
    iex> take_prefix.("Mr. John", "Mr. ")
    "John"

On the other hand, if you want to dynamically slice a string
based on an integer value, then using `String.slice/3` is the
best option as it guarantees we won't incorrectly split a valid
code point into multiple bytes.

## Integer code points

Although code points could be represented as integers, this
module represents all code points as strings. For example:

    iex> String.codepoints("olá")
    ["o", "l", "á"]

There are a couple of ways to retrieve a character integer
code point. One may use the `?` construct:

    iex> ?o
    111

    iex> ?á
    225

Or also via pattern matching:

    iex> <<aacute::utf8>> = "á"
    iex> aacute
    225

As we have seen above, code points can be inserted into
a string by their hexadecimal code:

    iex> "ol\u00E1"
    "olá"

Finally, to convert a String into a list of integers
code points, usually known as "char lists", you can call
`Strig.to_charlist`:

    iex> String.to_charlist("olá")
    [111, 108, 225]

## Self-synchronization

The UTF-8 encoding is self-synchronizing. This means that
if malformed data (i.e., data that is not possible according
to the definition of the encoding) is encountered, only one
code point needs to be rejected.

This module relies on this behaviour to ignore such invalid
characters. For example, `length/1` will return
a correct result even if an invalid code point is fed into it.

In other words, this module expects invalid data to be detected
elsewhere, usually when retrieving data from the external source.
For example, a driver that reads strings from a database will be
responsible to check the validity of the encoding. `String.chunk/2`
can be used for breaking a string into valid and invalid parts.

## Compile binary patterns

Many functions in this module work with patterns. For example,
`String.split/2` can split a string into multiple strings given
a pattern. This pattern can be a string, a list of strings or
a compiled pattern:

    iex> String.split("foo bar", " ")
    ["foo", "bar"]

    iex> String.split("foo bar!", [" ", "!"])
    ["foo", "bar", ""]

    iex> pattern = :binary.compile_pattern([" ", "!"])
    iex> String.split("foo bar!", pattern)
    ["foo", "bar", ""]

The compiled pattern is useful when the same match will
be done over and over again. Note though that the compiled
pattern cannot be stored in a module attribute as the pattern
is generated at runtime and does not survive compile time.


# moddoc for System

The `System` module provides functions that interact directly
with the VM or the host system.

## Time

The `System` module also provides functions that work with time,
returning different times kept by the system with support for
different time units.

One of the complexities in relying on system times is that they
may be adjusted. For example, when you enter and leave daylight
saving time, the system clock will be adjusted, often adding
or removing one hour. We call such changes "time warps". In
order to understand how such changes may be harmful, imagine
the following code:

    ## DO NOT DO THIS
    prev = System.os_time()
    # ... execute some code ...
    next = System.os_time()
    diff = next - prev

If, while the code is executing, the system clock changes,
some code that executed in 1 second may be reported as taking
over 1 hour! To address such concerns, the VM provides a
monotonic time via `System.monotonic_time/0` which never
decreases and does not leap:

    ## DO THIS
    prev = System.monotonic_time()
    # ... execute some code ...
    next = System.monotonic_time()
    diff = next - prev

Generally speaking, the VM provides three time measurements:

  * `os_time/0` - the time reported by the operating system (OS). This time may be
    adjusted forwards or backwards in time with no limitation;

  * `system_time/0` - the VM view of the `os_time/0`. The system time and operating
    system time may not match in case of time warps although the VM works towards
    aligning them. This time is not monotonic (i.e., it may decrease)
    as its behaviour is configured [by the VM time warp
    mode](http://www.erlang.org/doc/apps/erts/time_correction.html#Time_Warp_Modes);

  * `monotonic_time/0` - a monotonically increasing time provided
    by the Erlang VM.

The time functions in this module work in the `:native` unit
(unless specified otherwise), which is operating system dependent. Most of
the time, all calculations are done in the `:native` unit, to
avoid loss of precision, with `convert_time_unit/3` being
invoked at the end to convert to a specific time unit like
`:millisecond` or `:microsecond`. See the `t:time_unit/0` type for
more information.

For a more complete rundown on the VM support for different
times, see the [chapter on time and time
correction](http://www.erlang.org/doc/apps/erts/time_correction.html)
in the Erlang docs.


# moddoc for Task

Conveniences for spawning and awaiting tasks.

Tasks are processes meant to execute one particular
action throughout their lifetime, often with little or no
communication with other processes. The most common use case
for tasks is to convert sequential code into concurrent code
by computing a value asynchronously:

    task = Task.async(fn -> do_some_work() end)
    res = do_some_other_work()
    res + Task.await(task)

Tasks spawned with `async` can be awaited on by their caller
process (and only their caller) as shown in the example above.
They are implemented by spawning a process that sends a message
to the caller once the given computation is performed.

Besides `async/1` and `await/2`, tasks can also be
started as part of a supervision tree and dynamically spawned
on remote nodes. We will explore all three scenarios next.

## async and await

One of the common uses of tasks is to convert sequential code
into concurrent code with `Task.async/1` while keeping its semantics.
When invoked, a new process will be created, linked and monitored
by the caller. Once the task action finishes, a message will be sent
to the caller with the result.

`Task.await/2` is used to read the message sent by the task.

There are two important things to consider when using `async`:

  1. If you are using async tasks, you **must await** a reply
     as they are *always* sent. If you are not expecting a reply,
     consider using `Task.start_link/1` detailed below.

  2. async tasks link the caller and the spawned process. This
     means that, if the caller crashes, the task will crash
     too and vice-versa. This is on purpose: if the process
     meant to receive the result no longer exists, there is
     no purpose in completing the computation.

     If this is not desired, use `Task.start/1` or consider starting
     the task under a `Task.Supervisor` using `async_nolink` or
     `start_child`.

`Task.yield/2` is an alternative to `await/2` where the caller will
temporarily block, waiting until the task replies or crashes. If the
result does not arrive within the timeout, it can be called again at a
later moment. This allows checking for the result of a task multiple
times. If a reply does not arrive within the desired time,
`Task.shutdown/2` can be used to stop the task.

## Supervised tasks

It is also possible to spawn a task under a supervisor. The `Task`
module implements the `child_spec/1` function, which allows it to
be started directly under a supervisor by passing a tuple with
a function to run:

    Supervisor.start_link([
      {Task, fn -> :some_work end}
    ], strategy: :one_for_one)

However, if you want to invoke a specific module, function and
arguments, or give the task process a name, you need to define
the task in its own module:

    defmodule MyTask do
      use Task

      def start_link(arg) do
        Task.start_link(__MODULE__, :run, [arg])
      end

      def run(arg) do
        # ...
      end
    end

And then passing it to the supervisor:

    Supervisor.start_link([
      {MyTask, arg}
    ], strategy: :one_for_one)

Since these tasks are supervised and not directly linked to
the caller, they cannot be awaited on. `start_link/1`, unlike
`async/1`, returns `{:ok, pid}` (which is the result expected
by supervisors).

`use Task` defines a `child_spec/1` function, allowing the
defined module to be put under a supervision tree. The generated
`child_spec/1` can be customized with the following options:

  * `:id` - the child specification identifier, defaults to the current module
  * `:restart` - when the child should be restarted, defaults to `:temporary`
  * `:shutdown` - how to shut down the child, either immediately or by giving it time to shut down

Opposite to `GenServer`, `Agent` and `Supervisor`, a Task has
a default `:restart` of `:temporary`. This means the task will
not be restarted even if it crashes. If you desire the task to
be restarted for non-successful exits, do:

    use Task, restart: :transient

If you want the task to always be restarted:

    use Task, restart: :permanent

See the "Child specification" section in the `Supervisor` module
for more detailed information. The `@doc` annotation immediately
preceding `use Task` will be attached to the generated `child_spec/1`
function.

## Dynamically supervised tasks

The `Task.Supervisor` module allows developers to dynamically
create multiple supervised tasks.

A short example is:

    {:ok, pid} = Task.Supervisor.start_link()

    task =
      Task.Supervisor.async(pid, fn ->
        # Do something
      end)

    Task.await(task)

However, in the majority of cases, you want to add the task supervisor
to your supervision tree:

    Supervisor.start_link([
      {Task.Supervisor, name: MyApp.TaskSupervisor}
    ], strategy: :one_for_one)

Now you can dynamically start supervised tasks:

    Task.Supervisor.start_child(MyApp.TaskSupervisor, fn ->
      # Do something
    end)

Or even use the async/await pattern:

    Task.Supervisor.async(MyApp.TaskSupervisor, fn ->
      # Do something
    end)
    |> Task.await()

Finally, check `Task.Supervisor` for other supported operations.

## Distributed tasks

Since Elixir provides a `Task.Supervisor`, it is easy to use one
to dynamically start tasks across nodes:

    # On the remote node
    Task.Supervisor.start_link(name: MyApp.DistSupervisor)

    # On the client
    supervisor = {MyApp.DistSupervisor, :remote@local}
    Task.Supervisor.async(supervisor, MyMod, :my_fun, [arg1, arg2, arg3])

Note that, when working with distributed tasks, one should use the `Task.Supervisor.async/4` function
that expects explicit module, function and arguments, instead of `Task.Supervisor.async/2` that
works with anonymous functions. That's because anonymous functions expect
the same module version to exist on all involved nodes. Check the `Agent` module
documentation for more information on distributed processes as the limitations
described there apply to the whole ecosystem.

## Ancestor and Caller Tracking

Whenever you start a new process, Elixir annotates the parent of that process
through the `$ancestors` key in the process dictionary. This is often used to
track the hierarchy inside a supervision tree.

For example, we recommend developers to always start tasks under a supervisor.
This provides more visibility and allows you to control how those tasks are
terminated when a node shuts down. That might look something like
`Task.Supervisor.start_child(MySupervisor, task_specification)`. This means
that, although your code is the one who invokes the task, the actual ancestor of
the task is the supervisor, as the supervisor is the one effectively starting it.

To track the relationship between your code and the task, we use the `$callers`
key in the process dictionary. Therefore, assuming the `Task.Supervisor` call
above, we have:

    [your code] -- calls --> [supervisor] ---- spawns --> [task]

Which means we store the following relationships:

    [your code]              [supervisor] <-- ancestor -- [task]
        ^                                                  |
        |--------------------- caller ---------------------|

The list of callers of the current process can be retrieved from the Process
dictionary with `Process.get(:"$callers")`. This will return either `nil` or
a list `[pid_n, ..., pid2, pid1]` with at least one entry Where `pid_n` is
the PID that called the current process, `pid2` called `pid_n`, and `pid2` was
called by `pid1`.


# fndoc for Module.create/3

Creates a module with the given name and defined by
the given quoted expressions.

The line where the module is defined and its file **must**
be passed as options.

It returns a tuple of shape `{:module, module, binary, term}`
where `module` is the module name, `binary` is the module
byte code and `term` is the result of the last expression in
`quoted`.

Similar to `Kernel.defmodule/2`, the binary will only be
written to disk as a `.beam` file if `Module.create/3` is
invoked in a file that is currently being compiled.

## Examples

    contents =
      quote do
        def world, do: true
      end

    Module.create(Hello, contents, Macro.Env.location(__ENV__))

    Hello.world()
    #=> true

## Differences from `defmodule`

`Module.create/3` works similarly to `Kernel.defmodule/2`
and return the same results. While one could also use
`defmodule` to define modules dynamically, this function
is preferred when the module body is given by a quoted
expression.

Another important distinction is that `Module.create/3`
allows you to control the environment variables used
when defining the module, while `Kernel.defmodule/2`
automatically uses the environment it is invoked at.


# fndoc for Jason.decode/2

Parses a JSON value from `input` iodata.

## Options

  * `:keys` - controls how keys in objects are decoded. Possible values are:

    * `:strings` (default) - decodes keys as binary strings,
    * `:atoms` - keys are converted to atoms using `String.to_atom/1`,
    * `:atoms!` - keys are converted to atoms using `String.to_existing_atom/1`,
    * custom decoder - additionally a function accepting a string and returning a key
      is accepted.

  * `:strings` - controls how strings (including keys) are decoded. Possible values are:

    * `:reference` (default) - when possible tries to create a sub-binary into the original
    * `:copy` - always copies the strings. This option is especially useful when parts of the
      decoded data will be stored for a long time (in ets or some process) to avoid keeping
      the reference to the original data.

## Decoding keys to atoms

The `:atoms` option uses the `String.to_atom/1` call that can create atoms at runtime.
Since the atoms are not garbage collected, this can pose a DoS attack vector when used
on user-controlled data.

## Examples

    iex> Jason.decode("{}")
    {:ok, %{}}

    iex> Jason.decode("invalid")
    {:error, %Jason.DecodeError{data: "invalid", position: 0, token: nil}}


# fndoc for Jason.encode/2

Generates JSON corresponding to `input`.

The generation is controlled by the `Jason.Encoder` protocol,
please refer to the module to read more on how to define the protocol
for custom data types.

## Options

  * `:escape` - controls how strings are encoded. Possible values are:

    * `:json` (default) - the regular JSON escaping as defined by RFC 7159.
    * `:javascript_safe` - additionally escapes the LINE SEPARATOR (U+2028)
      and PARAGRAPH SEPARATOR (U+2029) characters to make the produced JSON
      valid JavaSciprt.
    * `:html_safe` - similar to `:javascript`, but also escapes the `/`
      caracter to prevent XSS.
    * `:unicode_safe` - escapes all non-ascii characters.

  * `:maps` - controls how maps are encoded. Possible values are:

    * `:strict` - checks the encoded map for duplicate keys and raises
      if they appear. For example `%{:foo => 1, "foo" => 2}` would be
      rejected, since both keys would be encoded to the string `"foo"`.
    * `:naive` (default) - does not perform the check.

  * `:pretty` - controls pretty printing of the output. Possible values are:

    * `true` to pretty print with default configuration
    * a keyword of options as specified by `Jason.Formatter.pretty_print/2`.

## Examples

    iex> Jason.encode(%{a: 1})
    {:ok, ~S|{"a":1}|}

    iex> Jason.encode("\xFF")
    {:error, %Jason.EncodeError{message: "invalid byte 0xFF in <<255>>"}}



# fndoc for Jason.decode!/2

Parses a JSON value from `input` iodata.

Similar to `decode/2` except it will unwrap the error tuple and raise
in case of errors.

## Examples

    iex> Jason.decode!("{}")
    %{}

    iex> Jason.decode!("invalid")
    ** (Jason.DecodeError) unexpected byte at position 0: 0x69 ('i')



# fndoc for Jason.encode!/2

Generates JSON corresponding to `input`.

Similar to `encode/1` except it will unwrap the error tuple and raise
in case of errors.

## Examples

    iex> Jason.encode!(%{a: 1})
    ~S|{"a":1}|

    iex> Jason.encode!("\xFF")
    ** (Jason.EncodeError) invalid byte 0xFF in <<255>>



# moddoc for Jason.Encoder

Protocol controlling how a value is encoded to JSON.

## Deriving

The protocol allows leveraging the Elixir's `@derive` feature
to simplify protocol implementation in trivial cases. Accepted
options are:

  * `:only` - encodes only values of specified keys.
  * `:except` - encodes all struct fields except specified keys.

By default all keys except the `:__struct__` key are encoded.

## Example

Let's assume a presence of the following struct:

    defmodule Test do
      defstruct [:foo, :bar, :baz]
    end

If we were to call `@derive Jason.Encoder` just before `defstruct`,
an implementaion similar to the follwing implementation would be generated:

    defimpl Jason.Encoder, for: Test do
      def encode(value, opts) do
        Jason.Encode.map(Map.take(value, [:foo, :bar, :baz]), opts)
      end
    end

If we called `@derive {Jason.Encoder, only: [:foo]}`, an implementation
similar to the following implementation would be genrated:

    defimpl Jason.Encoder, for: Test do
      def encode(value, opts) do
        Jason.Encode.map(Map.take(value, [:foo]), opts)
      end
    end

If we called `@derive {Jason.Encoder, except: [:foo]}`, an implementation
similar to the following implementation would be generated:

    defimpl Jason.Encoder, for: Test do
      def encode(value, opts) do
        Jason.Encode.map(Map.take(value, [:bar, :baz]), opts)
      end
    end

The actually generated implementations are more efficient computing some data
during compilation similar to the macros from the `Jason.Helpers` module.

## Explicit implementation

If you wish to implement the protocol fully yourself, it is advised to
use functions from the `Jason.Encode` module to do the actual iodata
generation - they are highly optimized and verified to always produce
valid JSON.


# fndoc for Jason.Formatter.pretty_print/2

Pretty-prints JSON-encoded `input`.

`input` may contain multiple JSON objects or arrays, optionally separated
by whitespace (e.g., one object per line). Objects in output will be
separated by newlines. No trailing newline is emitted.

## Options

  * `:indent` - used for nested objects and arrays (default: two spaces - `"  "`);
  * `:line_separator` - used in nested objects (default: `"\n"`);
  * `:record_separator` - separates root-level objects and arrays
    (default is the value for `:line_separator` option);
  * `:after_colon` - printed after a colon inside objects (default: one space - `" "`).

## Examples

    iex> Jason.Formatter.pretty_print(~s|{"a":{"b": [1, 2]}}|)
    ~s|{
      "a": {
        "b": [
          1,
          2
        ]
      }
    }|



# moddoc for Ecto

Ecto is split into 4 main components:

  * `Ecto.Repo` - repositories are wrappers around the data store.
    Via the repository, we can create, update, destroy and query existing entries.
    A repository needs an adapter and credentials to communicate to the database

  * `Ecto.Schema` - schemas are used to map any data source into an Elixir
    struct. We will often use them to map tables into Elixir data but that's
    one of their use cases and not a requirement for using Ecto

  * `Ecto.Changeset` - changesets provide a way for developers to filter
    and cast external parameters, as well as a mechanism to track and
    validate changes before they are applied to your data

  * `Ecto.Query` - written in Elixir syntax, queries are used to retrieve
    information from a given repository. Queries in Ecto are secure, avoiding
    common problems like SQL Injection, while still being composable, allowing
    developers to build queries piece by piece instead of all at once

Besides the four components above, most developers use Ecto to interact
with SQL databases, such as Postgres and MySQL via the
[`ecto_sql`](http://hexdocs.pm/ecto_sql) project. `ecto_sql` provides many
conveniences for working with SQL databases as well as the ability to version
how your database changes through time via
[database migrations](https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.html#module-migrations).

If you want to quickly check a sample application using Ecto, please check
the [getting started guide](http://hexdocs.pm/ecto/getting-started.html) and
the accompanying sample application. [Ecto's README](https://github.com/elixir-ecto/ecto)
also links to other resources.

In the following sections, we will provide an overview of those components and
how they interact with each other. Feel free to access their respective module
documentation for more specific examples, options and configuration.

## Repositories

`Ecto.Repo` is a wrapper around the database. We can define a
repository as follows:

    defmodule Repo do
      use Ecto.Repo,
        otp_app: :my_app,
        adapter: Ecto.Adapters.Postgres
    end

Where the configuration for the Repo must be in your application
environment, usually defined in your `config/config.exs`:

    config :my_app, Repo,
      database: "ecto_simple",
      username: "postgres",
      password: "postgres",
      hostname: "localhost",
      # OR use a URL to connect instead
      url: "postgres://postgres:postgres@localhost/ecto_simple"

Each repository in Ecto defines a `start_link/0` function that needs to be invoked
before using the repository. In general, this function is not called directly,
but used as part of your application supervision tree.

If your application was generated with a supervisor (by passing `--sup` to `mix new`)
you will have a `lib/my_app/application.ex` file containing the application start
callback that defines and starts your supervisor.  You just need to edit the `start/2`
function to start the repo as a supervisor on your application's supervisor:

    def start(_type, _args) do
      children = [
        {MyApp.Repo, []}
      ]

      opts = [strategy: :one_for_one, name: MyApp.Supervisor]
      Supervisor.start_link(children, opts)
    end

## Schema

Schemas allow developers to define the shape of their data.
Let's see an example:

    defmodule Weather do
      use Ecto.Schema

      # weather is the DB table
      schema "weather" do
        field :city,    :string
        field :temp_lo, :integer
        field :temp_hi, :integer
        field :prcp,    :float, default: 0.0
      end
    end

By defining a schema, Ecto automatically defines a struct with
the schema fields:

    iex> weather = %Weather{temp_lo: 30}
    iex> weather.temp_lo
    30

The schema also allows us to interact with a repository:

    iex> weather = %Weather{temp_lo: 0, temp_hi: 23}
    iex> Repo.insert!(weather)
    %Weather{...}

After persisting `weather` to the database, it will return a new copy of
`%Weather{}` with the primary key (the `id`) set. We can use this value
to read a struct back from the repository:

    # Get the struct back
    iex> weather = Repo.get Weather, 1
    %Weather{id: 1, ...}

    # Delete it
    iex> Repo.delete!(weather)
    %Weather{...}

> NOTE: by using `Ecto.Schema`, an `:id` field with type `:id` (:id means :integer) is
> generated by default, which is the primary key of the Schema. If you want
> to use a different primary key, you can declare custom `@primary_key`
> before the `schema/2` call. Consult the `Ecto.Schema` documentation
> for more information.

Notice how the storage (repository) and the data are decoupled. This provides
two main benefits:

  * By having structs as data, we guarantee they are light-weight,
    serializable structures. In many languages, the data is often represented
    by large, complex objects, with entwined state transactions, which makes
    serialization, maintenance and understanding hard;

  * You do not need to define schemas in order to interact with repositories,
    operations like `all`, `insert_all` and so on allow developers to directly
    access and modify the data, keeping the database at your fingertips when
    necessary;

## Changesets

Although in the example above we have directly inserted and deleted the
struct in the repository, operations on top of schemas are done through
changesets so Ecto can efficiently track changes.

Changesets allow developers to filter, cast, and validate changes before
we apply them to the data. Imagine the given schema:

    defmodule User do
      use Ecto.Schema

      import Ecto.Changeset

      schema "users" do
        field :name
        field :email
        field :age, :integer
      end

      def changeset(user, params \\ %{}) do
        user
        |> cast(params, [:name, :email, :age])
        |> validate_required([:name, :email])
        |> validate_format(:email, ~r/@/)
        |> validate_inclusion(:age, 18..100)
      end
    end

The `changeset/2` function first invokes `Ecto.Changeset.cast/4` with
the struct, the parameters and a list of allowed fields; this returns a changeset.
The parameters is a map with binary keys and values that will be cast based
on the type defined on the schema.

Any parameter that was not explicitly listed in the fields list will be ignored.

After casting, the changeset is given to many `Ecto.Changeset.validate_*`
functions that validate only the **changed fields**. In other words:
if a field was not given as a parameter, it won't be validated at all.
For example, if the params map contain only the "name" and "email" keys,
the "age" validation won't run.

Once a changeset is built, it can be given to functions like `insert` and
`update` in the repository that will return an `:ok` or `:error` tuple:

    case Repo.update(changeset) do
      {:ok, user} ->
        # user updated
      {:error, changeset} ->
        # an error occurred
    end

The benefit of having explicit changesets is that we can easily provide
different changesets for different use cases. For example, one
could easily provide specific changesets for registering and updating
users:

    def registration_changeset(user, params) do
      # Changeset on create
    end

    def update_changeset(user, params) do
      # Changeset on update
    end

Changesets are also capable of transforming database constraints,
like unique indexes and foreign key checks, into errors. Allowing
developers to keep their database consistent while still providing
proper feedback to end users. Check `Ecto.Changeset.unique_constraint/3`
for some examples as well as the other `_constraint` functions.

## Query

Last but not least, Ecto allows you to write queries in Elixir and send
them to the repository, which translates them to the underlying database.
Let's see an example:

    import Ecto.Query, only: [from: 2]

    query = from u in User,
              where: u.age > 18 or is_nil(u.email),
              select: u

    # Returns %User{} structs matching the query
    Repo.all(query)

In the example above we relied on our schema but queries can also be
made directly against a table by giving the table name as a string. In
such cases, the data to be fetched must be explicitly outlined:

    query = from u in "users",
              where: u.age > 18 or is_nil(u.email),
              select: %{name: u.name, age: u.age}

    # Returns maps as defined in select
    Repo.all(query)

Queries are defined and extended with the `from` macro. The supported
keywords are:

  * `:distinct`
  * `:where`
  * `:order_by`
  * `:offset`
  * `:limit`
  * `:lock`
  * `:group_by`
  * `:having`
  * `:join`
  * `:select`
  * `:preload`

Examples and detailed documentation for each of those are available
in the `Ecto.Query` module. Functions supported in queries are listed
in `Ecto.Query.API`.

When writing a query, you are inside Ecto's query syntax. In order to
access params values or invoke Elixir functions, you need to use the `^`
operator, which is overloaded by Ecto:

    def min_age(min) do
      from u in User, where: u.age > ^min
    end

Besides `Repo.all/1` which returns all entries, repositories also
provide `Repo.one/1` which returns one entry or nil, `Repo.one!/1`
which returns one entry or raises, `Repo.get/2` which fetches
entries for a particular ID and more.

Finally, if you need an escape hatch, Ecto provides fragments
(see `Ecto.Query.API.fragment/1`) to inject SQL (and non-SQL)
fragments into queries. Also, most adapters provide direct
APIs for queries, like `Ecto.Adapters.SQL.query/4`, allowing
developers to completely bypass Ecto queries.

## Other topics

### Associations

Ecto supports defining associations on schemas:

    defmodule Post do
      use Ecto.Schema

      schema "posts" do
        has_many :comments, Comment
      end
    end

    defmodule Comment do
      use Ecto.Schema

      schema "comments" do
        field :title, :string
        belongs_to :post, Post
      end
    end

When an association is defined, Ecto also defines a field in the schema
with the association name. By default, associations are not loaded into
this field:

    iex> post = Repo.get(Post, 42)
    iex> post.comments
    #Ecto.Association.NotLoaded<...>

However, developers can use the preload functionality in queries to
automatically pre-populate the field:

    Repo.all from p in Post, preload: [:comments]

Preloading can also be done with a pre-defined join value:

    Repo.all from p in Post,
              join: c in assoc(p, :comments),
              where: c.votes > p.votes,
              preload: [comments: c]

Finally, for the simple cases, preloading can also be done after
a collection was fetched:

    posts = Repo.all(Post) |> Repo.preload(:comments)

The `Ecto` module also provides conveniences for working
with associations. For example, `Ecto.assoc/2` returns a query
with all associated data to a given struct:

    import Ecto

    # Get all comments for the given post
    Repo.all assoc(post, :comments)

    # Or build a query on top of the associated comments
    query = from c in assoc(post, :comments), where: not is_nil(c.title)
    Repo.all(query)

Another function in `Ecto` is `build_assoc/3`, which allows
someone to build an associated struct with the proper fields:

    Repo.transaction fn ->
      post = Repo.insert!(%Post{title: "Hello", body: "world"})

      # Build a comment from post
      comment = Ecto.build_assoc(post, :comments, body: "Excellent!")

      Repo.insert!(comment)
    end

In the example above, `Ecto.build_assoc/3` is equivalent to:

    %Comment{post_id: post.id, body: "Excellent!"}

You can find more information about defining associations and each
respective association module in `Ecto.Schema` docs.

> NOTE: Ecto does not lazy load associations. While lazily loading
> associations may sound convenient at first, in the long run it
> becomes a source of confusion and performance issues.

### Embeds

Ecto also supports embeds. While associations keep parent and child
entries in different tables, embeds stores the child along side the
parent.

Databases like MongoDB have native support for embeds. Databases
like PostgreSQL uses a mixture of JSONB (`embeds_one/3`) and ARRAY
columns to provide this functionality.

Check `Ecto.Schema.embeds_one/3` and `Ecto.Schema.embeds_many/3`
for more information.

### Mix tasks and generators

Ecto provides many tasks to help your workflow as well as code generators.
You can find all available tasks by typing `mix help` inside a project
with Ecto listed as a dependency.

Ecto generators will automatically open the generated files if you have
`ECTO_EDITOR` set in your environment variable.

#### Repo resolution

Ecto requires developers to specify the key `:ecto_repos` in their
application configuration before using tasks like `ecto.create` and
`ecto.migrate`. For example:

    config :my_app, :ecto_repos, [MyApp.Repo]

    config :my_app, MyApp.Repo,
      database: "ecto_simple",
      username: "postgres",
      password: "postgres",
      hostname: "localhost"



# moddoc for Earmark


### API

#### Earmark.as_html

    {:ok, html_doc, []}                   = Earmark.as_html(markdown)
    {:ok, html_doc, deprecation_messages} = Earmark.as_html(markdown)
    {:error, html_doc, error_messages}    = Earmark.as_html(markdown)

#### Earmark.as_html!

    html_doc = Earmark.as_html!(markdown, options)

All messages are printed to _stderr_.

#### Options

Options can be passed into `as_html/2` or `as_html!/2` according to the documentation.

    html_doc = Earmark.as_html!(markdown)
    html_doc = Earmark.as_html!(markdown, options)

Formats the error_messages returned by `as_html` and adds the filename to each.
Then prints them to stderr and just returns the html_doc

#### NEW and EXPERIMENTAL: `Earmark.as_ast`

Although well tested the way the exposed AST will look in future versions may change, a stable
API is expected for Earmark v1.6, when the rendered HTML shall be derived from the ast too.

More details can be found in the function's description below.

### Command line

    $ mix escript.build
    $ ./earmark file.md

Some options defined in the `Earmark.Options` struct can be specified as command line switches.

Use

    $ ./earmark --help

to find out more, but here is a short example

    $ ./earmark --smartypants false --code-class-prefix "a- b-" file.md

will call

    Earmark.as_html!( ..., %Earmark.Options{smartypants: false, code_class_prefix: "a- b-"})

## Supports

Standard [Gruber markdown][gruber].

[gruber]: <http://daringfireball.net/projects/markdown/syntax>

## Extensions

### Github Flavored Markdown

GFM is supported by default, however as GFM is a moving target and all GFM extension do not make sense in a general context, Earmark does not support all of it, here is a list of what is supported:

#### Strike Through

    iex(1)> Earmark.as_html! ["~~hello~~"]
    "<p><del>hello</del></p>\n"

#### Syntax Highlighting

All backquoted or fenced code blocks with a language string are rendered with the given
language as a _class_ attribute of the _code_ tag.

For example:

    iex(8)> [
    ...(8)>    "```elixir",
    ...(8)>    " @tag :hello",
    ...(8)>    "```"
    ...(8)> ] |> Earmark.as_html!()
    "<pre><code class=\"elixir\"> @tag :hello</code></pre>\n"

will be rendered as shown in the doctest above.

If you want to integrate with a syntax highlighter with different conventions you can add more classes by specifying prefixes that will be
put before the language string.

Prism.js for example needs a class `language-elixir`. In order to achieve that goal you can add `language-`
as a `code_class_prefix` to `Earmark.Options`.

In the following example we want more than one additional class, so we add more prefixes.

    Earmark.as_html!(..., %Earmark.Options{code_class_prefix: "lang- language-"})

which is rendering

    <pre><code class="elixir lang-elixir language-elixir">...

As for all other options `code_class_prefix` can be passed into the `earmark` executable as follows:

    earmark --code-class-prefix "language- lang-" ...

#### Tables

Are supported as long as they are preceded by an empty line.

    State | Abbrev | Capital
    ----: | :----: | -------
    Texas | TX     | Austin
    Maine | ME     | Augusta

Tables may have leading and trailing vertical bars on each line

    | State | Abbrev | Capital |
    | ----: | :----: | ------- |
    | Texas | TX     | Austin  |
    | Maine | ME     | Augusta |

Tables need not have headers, in which case all column alignments
default to left.

    | Texas | TX     | Austin  |
    | Maine | ME     | Augusta |

Currently we assume there are always spaces around interior vertical unless
there are exterior bars.

However in order to be more GFM compatible the `gfm_tables: true` option
can be used to interpret only interior vertical bars as a table if a seperation
line is given, therefor

     Language|Rating
     --------|------
     Elixir  | awesome

is a table (iff `gfm_tables: true`) while

     Language|Rating
     Elixir  | awesome

never is.

### Adding HTML attributes with the IAL extension

#### To block elements

HTML attributes can be added to any block-level element. We use
the Kramdown syntax: add the line `{:` _attrs_ `}` following the block.

_attrs_ can be one or more of:

  * `.className`
  * `#id`
  * name=value, name="value", or name='value'

For example:

    # Warning
    {: .red}

    Do not turn off the engine
    if you are at altitude.
    {: .boxed #warning spellcheck="true"}

#### To links or images

It is possible to add IAL attributes to generated links or images in the following
format.

    iex(4)> markdown = "[link](url) {: .classy}"
    ...(4)> Earmark.as_html(markdown)
    { :ok, "<p><a href=\"url\" class=\"classy\">link</a></p>\n", []}

For both cases, malformed attributes are ignored and warnings are issued.

    iex(5)> [ "Some text", "{:hello}" ] |> Enum.join("\n") |> Earmark.as_html()
    {:error, "<p>Some text</p>\n", [{:warning, 2,"Illegal attributes [\"hello\"] ignored in IAL"}]}

It is possible to escape the IAL in both forms if necessary

    iex(6)> markdown = "[link](url)\\{: .classy}"
    ...(6)> Earmark.as_html(markdown)
    {:ok, "<p><a href=\"url\">link</a>{: .classy}</p>\n", []}

This of course is not necessary in code blocks or text lines
containing an IAL-like string, as in the following example

    iex(7)> markdown = "hello {:world}"
    ...(7)> Earmark.as_html!(markdown)
    "<p>hello {:world}</p>\n"

## Limitations

  * Block-level HTML is correctly handled only if each HTML
    tag appears on its own line. So

        <div>
        <div>
        hello
        </div>
        </div>

  will work. However. the following won't

        <div>
        hello</div>

* John Gruber's tests contain an ambiguity when it comes to
  lines that might be the start of a list inside paragraphs.

  One test says that

        This is the text
        * of a paragraph
        that I wrote

  is a single paragraph. The "*" is not significant. However, another
  test has

        *   A list item
            * an another

  and expects this to be a nested list. But, in reality, the second could just
  be the continuation of a paragraph.

  I've chosen always to use the second interpretation—a line that looks like
  a list item will always be a list item.

* Rendering of block and inline elements.

  Block or void HTML elements that are at the absolute beginning of a line end
  the preceding paragraph.

  Thusly

        mypara
        <hr />

  Becomes

        <p>mypara</p>
        <hr />

  While

        mypara
         <hr />

  will be transformed into

        <p>mypara
         <hr /></p>

## Timeouts

By default, that is if the `timeout` option is not set Earmark uses parallel mapping as implemented in `Earmark.pmap/2`,
which uses `Task.await` with its default timeout of 5000ms.

In rare cases that might not be enough.

By indicating a longer `timeout` option in milliseconds Earmark will use parallel mapping as implemented in `Earmark.pmap/3`,
which will pass `timeout` to `Task.await`.

In both cases one can override the mapper function with either the `mapper` option (used if and only if `timeout` is nil) or the
`mapper_with_timeout` function (used otherwise).

For the escript only the `timeout` command line argument can be used.

## Security

Please be aware that Markdown is not a secure format. It produces
HTML from Markdown and HTML. It is your job to sanitize and or
filter the output of `Earmark.as_html` if you cannot trust the input
and are to serve the produced HTML on the Web.


