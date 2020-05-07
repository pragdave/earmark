# Elixir

![Elixir](https://github.com/elixir-lang/elixir-lang.github.com/raw/master/images/logo/logo.png)
=========
[![Build status](https://api.cirrus-ci.com/github/elixir-lang/elixir.svg?branch=master)](https://cirrus-ci.com/github/elixir-lang/elixir)

Elixir is a dynamic, functional language designed for building scalable
and maintainable applications.

For more about Elixir, installation and documentation,
[check Elixir's website](https://elixir-lang.org/).

## Policies

New releases are announced in the [announcement mailing list][8].
You can subscribe by sending an email to elixir-lang-ann+subscribe@googlegroups.com and replying to the confirmation email.

All security releases [will be tagged with `[security]`][10]. For more information, please read our [Security Policy][9].

All interactions in our official communication channels follow our [Code of Conduct][1].

## Bug reports

For reporting bugs, [visit our issue tracker][2] and follow the steps
for reporting a new issue. **Please disclose security vulnerabilities
privately at elixir-security@googlegroups.com**.

## Compiling from source

For the many different ways to install Elixir,
[see our installation instructions on the website](https://elixir-lang.org/install.html).
To compile from source, you can follow the steps below.

First, [install Erlang](https://elixir-lang.org/install.html#installing-erlang). Then clone this repository to your machine, compile and test it:

```sh
git clone https://github.com/elixir-lang/elixir.git
cd elixir
make clean test
```

> Note: if you are running on Windows,
[this article includes important notes for compiling Elixir from source
on Windows](https://github.com/elixir-lang/elixir/wiki/Windows).

If Elixir fails to build (specifically when pulling in a new version via
`git`), be sure to remove any previous build artifacts by running
`make clean`, then `make test`.

If tests pass, you can use Interactive Elixir by running `bin/iex` in your terminal.

However, if tests fail, it is likely that you have an outdated Erlang/OTP version
(Elixir requires Erlang/OTP 21.0 or later). You can check your Erlang/OTP version
by calling `erl` in the command line. You will see some information similar to:

    Erlang/OTP 21 [erts-9.0] [smp:2:2] [async-threads:10] [kernel-poll:false]

If you have properly set up your dependencies and tests still fail,
you may want to open up a bug report, as explained next.

## Proposing new features

For proposing new features, please start a discussion in the
[Elixir Core mailing list][3]. Keep in mind that it is your responsibility
to argue and explain why a feature is useful and how it will impact the
codebase and the community.

Once a proposal is accepted, it will be added to [the issue tracker][2].
The issue tracker focuses on *actionable items* and it holds a list of
upcoming enhancements and pending bugs. All entries in the tracker are
tagged for clarity and to ease collaboration.

Features and bug fixes that have already been merged and will be included
in the next release are marked as "closed" in the issue tracker and are
added to the [changelog][7].

## Contributing

We welcome everyone to contribute to Elixir. To do so, there are a few
things you need to know about the code. First, Elixir code is divided
in applications inside the `lib` folder:

* `elixir` - Elixir's kernel and standard library

* `eex` - EEx is the template engine that allows you to embed Elixir

* `ex_unit` - ExUnit is a simple test framework that ships with Elixir

* `iex` - IEx stands for Interactive Elixir: Elixir's interactive shell

* `logger` - Logger is the built-in logger

* `mix` - Mix is Elixir's build tool

You can run all tests in the root directory with `make test` and you can
also run tests for a specific framework `make test_#{APPLICATION}`, for example,
`make test_ex_unit`. If you just changed something in the Elixir's standard
library, you can run only that portion through `make test_stdlib`.

If you are changing just one file, you can choose to compile and run tests only
for that particular file for fast development cycles. For example, if you
are changing the String module, you can compile it and run its tests as:

```sh
bin/elixirc lib/elixir/lib/string.ex -o lib/elixir/ebin
bin/elixir lib/elixir/test/elixir/string_test.exs
```

To recompile (including Erlang modules):

```sh
make compile
```

After your changes are done, please remember to run `make format` to guarantee
all files are properly formatted and then run the full suite with
`make test`.

If your contribution fails during the bootstrapping of the language,
you can rebuild the language from scratch with:

```sh
make clean_elixir compile
```

Similarly, if you can't get Elixir to compile or the tests to pass after
updating an existing checkout, run `make clean compile`. You can check
[the official build status on Cirrus CI](https://cirrus-ci.com/github/elixir-lang/elixir).
More tasks can be found by reading the [Makefile](Makefile).

With tests running and passing, you are ready to contribute to Elixir and
[send a pull request](https://help.github.com/articles/using-pull-requests/).
We have saved some excellent pull requests we have received in the past in
case you are looking for some examples:

* [Implement Enum.member? - Pull Request](https://github.com/elixir-lang/elixir/pull/992)
* [Add String.valid? - Pull Request](https://github.com/elixir-lang/elixir/pull/1058)
* [Implement capture_io for ExUnit - Pull Request](https://github.com/elixir-lang/elixir/pull/1059)

### Reviewing changes

Once a pull request is sent, the Elixir team will review your changes.
We outline our process below to clarify the roles of everyone involved.

All pull requests must be approved by two committers before being merged into
the repository. If any changes are necessary, the team will leave appropriate
comments requesting changes to the code. Unfortunately we cannot guarantee a
pull request will be merged, even when modifications are requested, as the Elixir
team will re-evaluate the contribution as it changes.

Committers may also push style changes directly to your branch. If you would
rather manage all changes yourself, you can disable "Allow edits from maintainers"
feature when submitting your pull request.

The Elixir team may optionally assign someone to review a pull request.
If someone is assigned, they must explicitly approve the code before
another team member can merge it.

When the review finishes, your pull request will be squashed and merged
into the repository. If you have carefully organized your commits and
believe they should be merged without squashing, please mention it in
a comment.

## Building documentation

Building the documentation requires [ExDoc](https://github.com/elixir-lang/ex_doc)
to be installed and built alongside Elixir:

```sh
# After cloning and compiling Elixir, in its parent directory:
git clone git://github.com/elixir-lang/ex_doc.git
cd ex_doc && ../elixir/bin/mix do deps.get, compile
```

Now go back to Elixir's root directory and run:

```sh
make docs                  # to generate HTML pages
make docs DOCS_FORMAT=epub # to generate EPUB documents
```

This will produce documentation sets for `elixir`, `eex`, `ex_unit`, `iex`, `logger`,
and `mix` under the `doc` directory. If you are planning to contribute documentation,
[please check our best practices for writing documentation](https://hexdocs.pm/elixir/writing-documentation.html).

## Development links

  * [Elixir Documentation][6]
  * [Elixir Core Mailing list (development)][3]
  * [Announcement mailing list][8]
  * [Code of Conduct][1]
  * [Issue tracker][2]
  * [Changelog][7]
  * [Security Policy][9]
  * **[#elixir-lang][4]** on [Freenode][5] IRC

  [1]: CODE_OF_CONDUCT.md
  [2]: https://github.com/elixir-lang/elixir/issues
  [3]: https://groups.google.com/group/elixir-lang-core
  [4]: https://webchat.freenode.net/?channels=#elixir-lang
  [5]: https://www.freenode.net
  [6]: https://elixir-lang.org/docs.html
  [7]: CHANGELOG.md
  [8]: https://groups.google.com/group/elixir-lang-ann
  [9]: SECURITY.md
  [10]: https://groups.google.com/forum/#!searchin/elixir-lang-ann/%5Bsecurity%5D%7Csort:date

## License

"Elixir" and the Elixir logo are copyright (c) 2012 Plataformatec.

Elixir source code is released under Apache License 2.0.

Check [NOTICE](NOTICE) and [LICENSE](LICENSE) files for more information.

# ExDoc

[![Build Status](https://secure.travis-ci.org/elixir-lang/ex_doc.svg?branch=master "Build Status")](http://travis-ci.org/elixir-lang/ex_doc)
[![Coverage Status](https://coveralls.io/repos/github/elixir-lang/ex_doc/badge.svg?branch=master)](https://coveralls.io/github/elixir-lang/ex_doc?branch=master)

ExDoc is a tool to generate documentation for your Elixir projects. To see an example, [you can access Elixir's official docs](https://hexdocs.pm/elixir/).

To learn about how to document your projects, see [Elixir's writing documentation page](https://hexdocs.pm/elixir/writing-documentation.html).

To see all supported options, see the documentation for [mix docs](https://hexdocs.pm/ex_doc/Mix.Tasks.Docs.html)

## Features

ExDoc ships with many features:

  * Automatically generates HTML and EPUB documents from your API documentation
  * Support for custom pages and guides (in addition to the API reference)
  * Support for custom grouping of modules, functions, and pages in the sidebar
  * Generates HTML documentation accessible online and offline
  * Responsive design with built-in layout for phones and tablets
  * Customizable logo on the generated documentation
  * Each documented entry contains a direct link back to the source code
  * Full-text search
  * Keyboard shortcuts (press `?` inside an existing documentation to bring the help dialog)
  * Quick search with autocompletion support (`s` keyboard shortcut)
  * Go-to shortcut to take to any HexDocs package documentation with autocomplete support (`g` keyboard shortcut)
  * Support for night-mode (automatically detected according to the browser preferences)
  * Show tooltips when mousing over a link to a module/function (works for the current project and across projects)
  * A version dropdown to quickly switch to other versions (automatically configured when hosted on HexDocs)

## Using ExDoc with Mix

To use ExDoc in your Mix projects, first add ExDoc as a dependency.

If you are using Elixir v1.7 and later:

```elixir
def deps do
  [
    {:ex_doc, "~> 0.21", only: :dev, runtime: false},
  ]
end
```

If you are using Elixir v1.6 and earlier:

```elixir
def deps do
  [
    {:ex_doc, "~> 0.18.0", only: :dev, runtime: false},
  ]
end
```

After adding ExDoc as a dependency, run `mix deps.get` to install it.

ExDoc will automatically pull in information from your projects, like the application and version. However, you may want to set `:name`, `:source_url` and `:homepage_url` to have a nicer output from ExDoc, such as:

```elixir
def project do
  [
    app: :my_app,
    version: "0.1.0-dev",
    deps: deps(),

    # Docs
    name: "MyApp",
    source_url: "https://github.com/USER/PROJECT",
    homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
    docs: [
      main: "MyApp", # The main page in the docs
      logo: "path/to/logo.png",
      extras: ["README.md"]
    ]
  ]
end
```

Now you are ready to generate your project documentation with `mix docs`. To see all options available when generating docs, run `mix help docs`.

## Using ExDoc via command line

You can ExDoc via the command line as follows:

1. Install ExDoc as an escript:

    ```bash
    $ mix escript.install hex ex_doc
    ```

2. Then you are ready to use it in your projects. First, move into your project directory and make sure it is already compiled:

    ```bash
    $ cd PATH_TO_YOUR_PROJECT
    $ mix compile
    ```

3. Next invoke the ex_doc executable from your project:

    ```bash
    $ ex_doc "PROJECT_NAME" "PROJECT_VERSION" path/to/project/ebin -m "PROJECT_MODULE" -u "https://github.com/GITHUB_USER/GITHUB_REPO" -l path/to/logo.png
    ```

4. By default, ex_doc produces HTML files, but, you can also create a EPUB document passing the option `--formatter epub`:

    ```bash
    $ PATH_TO_YOUR_EXDOC/bin/ex_doc "PROJECT_NAME" "PROJECT_VERSION" path/to/project/ebin -m "PROJECT_MODULE" -u "https://github.com/GITHUB_USER/GITHUB_REPO" -l path/to/logo.png -f epub
    ```

For example, here are some acceptable values:

    PROJECT_NAME    => Ecto
    PROJECT_VERSION => 0.1.0
    PROJECT_MODULE  => Ecto (the main module provided by the library)
    GITHUB_USER     => elixir-lang
    GITHUB_REPO     => ecto

## Auto-linking

ExDoc will automatically generate links across modules and functions if you enclose them in backticks:

  * By referring to a module, function, type or callback from your project, such as `` `MyModule` ``, ExDoc will automatically link to those
  * By referring to a module, function, type or callback from Elixir, such as `` `String` ``, ExDoc will automatically link to Elixir's stable documentation
  * By referring to a module or function from erlang, such as (`` `:erlang` ``), ExDoc will automatically link to the Erlang documentation
  * By referring to a module, function, type or callback from any of your dependencies, such as `` `MyDep` ``, ExDoc will automatically link to that dependency documentation on [hexdocs.pm](http://hexdocs.pm/) (the link can be configured by setting `docs: [deps: [my_dep: "https://path/to/docs/"]]` in your `mix.exs`)

ExDoc supports linking to modules (`` `MyModule` ``), functions (`` `MyModule.function/1` ``), types (`` `t:MyModule.type/2` ``) and callbacks (`` `c:MyModule.callback/3` ``). If you want to link a function, type or callback in the current module, you may skip the module name, such as `` `function/1` ``.

## Contributing

The easiest way to test changes to ExDoc is to locally re-generate its own docs:

  1. Run `mix setup` to install all dependencies
  2. Run `mix build` to generate docs. This is a custom alias that will build assets, recompile ExDoc, and output fresh docs into the `doc/` directory
  3. Commit both `assets/*` and `formatters/*` changes (after running `mix build`)

## License

ExDoc source code is released under Apache 2 License. The generated contents, however, are under different licenses based on projects used to help render HTML, including CSS, JS, and other assets.

Check the [LICENSE](LICENSE) file for more information. Any documentation generated by ExDoc, or any documentation generated by any "Derivative Works" (as specified in the Apache 2 License), must include a direct link to [ExDoc repository](https://github.com/elixir-lang/ex_doc) on every page.

# Phoenix
![phoenix logo](https://raw.githubusercontent.com/phoenixframework/phoenix/master/priv/static/phoenix.png)
> ### Productive. Reliable. Fast.
> A productive web framework that does not compromise speed or maintainability.

[![Build Status](https://api.travis-ci.org/phoenixframework/phoenix.svg?branch=master)](https://travis-ci.org/phoenixframework/phoenix)
[![Inline docs](http://inch-ci.org/github/phoenixframework/phoenix.svg)](http://inch-ci.org/github/phoenixframework/phoenix)

## Getting started

See the official site at https://www.phoenixframework.org/

Install the latest version of Phoenix by following the instructions at https://hexdocs.pm/phoenix/installation.html#phoenix

## Documentation

API documentation is available at [https://hexdocs.pm/phoenix](https://hexdocs.pm/phoenix)

Phoenix.js documentation is available at [https://hexdocs.pm/phoenix/js](https://hexdocs.pm/phoenix/js)

## Contributing

We appreciate any contribution to Phoenix. Check our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) and [CONTRIBUTING.md](CONTRIBUTING.md) guides for more information. We usually keep a list of features and bugs [in the issue tracker][4].

### Generating a Phoenix project from unreleased versions

You can create a new project using the latest Phoenix source installer (the `phx.new` Mix task) with the following steps:

1. Remove any previously installed `phx_new` archives so that Mix will pick up the local source code. This can be done with `mix archive.uninstall phx_new` or by simply deleting the file, which is usually in `~/.mix/archives/`.
2. Copy this repo via `git clone https://github.com/phoenixframework/phoenix` or by downloading it
3. Run the `phx.new` mix task from within the `installer` directory, for example:

```bash
$ cd installer
$ mix phx.new dev_app --dev
```

The `--dev` flag will configure your new project's `:phoenix` dep as a relative path dependency, pointing to your local Phoenix checkout:

```elixir
defp deps do
  [{:phoenix, path: "../..", override: true},
```

To create projects outside of the `installer/` directory, add the latest archive to your machine by following the instructions in [installer/README.md](https://github.com/phoenixframework/phoenix/blob/master/installer/README.md)

To build the documentation from source:

```bash
$ npm install --prefix assets
$ MIX_ENV=docs mix docs
```

To build Phoenix from source:

```bash
$ mix deps.get
$ mix compile
```

To build the Phoenix installer from source:

```bash
$ mix deps.get
$ mix compile
$ mix archive.build
```

### Building phoenix.js

```bash
$ cd assets
$ npm install
$ npm run watch
```

## Important links

* [#elixir-lang][1] on [Freenode][2] IRC
* [elixir-lang slack channel][3]
* [Issue tracker][4]
* [Phoenix Forum (questions)][5]
* [phoenix-core Mailing list (development)][6]
* Visit Phoenix's sponsor, DockYard, for expert [phoenix consulting](https://dockyard.com/phoenix-consulting)
* Privately disclose security vulnerabilities to phoenix-security@googlegroups.com

  [1]: https://webchat.freenode.net/?channels=#elixir-lang
  [2]: http://www.freenode.net/
  [3]: https://elixir-slackin.herokuapp.com/
  [4]: https://github.com/phoenixframework/phoenix/issues
  [5]: https://elixirforum.com/c/phoenix-forum
  [6]: http://groups.google.com/group/phoenix-core

## Copyright and License

Copyright (c) 2014, Chris McCord.

Phoenix source code is licensed under the [MIT License](LICENSE.md).

# Ecto
<img width="250" src="https://github.com/elixir-ecto/ecto/raw/master/guides/images/logo.png" alt="Ecto">

---

[![Build Status](https://github.com/elixir-ecto/ecto/workflows/CI/badge.svg)](https://github.com/elixir-ecto/ecto/actions)

Ecto is a toolkit for data mapping and language integrated query for Elixir. Here is an example:

```elixir
# In your config/config.exs file
config :my_app, ecto_repos: [Sample.Repo]

config :my_app, Sample.Repo,
  database: "ecto_simple",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

# In your application code
defmodule Sample.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres
end

defmodule Sample.Weather do
  use Ecto.Schema

  schema "weather" do
    field :city     # Defaults to type :string
    field :temp_lo, :integer
    field :temp_hi, :integer
    field :prcp,    :float, default: 0.0
  end
end

defmodule Sample.App do
  import Ecto.Query
  alias Sample.{Weather, Repo}

  def keyword_query do
    query =
      from w in Weather,
           where: w.prcp > 0 or is_nil(w.prcp),
           select: w

    Repo.all(query)
  end

  def pipe_query do
    Weather
    |> where(city: "Kraków")
    |> order_by(:temp_lo)
    |> limit(10)
    |> Repo.all
  end
end
```

Ecto is commonly used to interact with databases, such as Postgres and MySQL via [Ecto.Adapters.SQL](http://hexdocs.pm/ecto_sql) ([source code](https://github.com/elixir-ecto/ecto_sql)). Ecto is also commonly used to map data from any source into Elixir structs, regardless if they are backed by a database or not.

See the [getting started guide](http://hexdocs.pm/ecto/getting-started.html) and the [online documentation](http://hexdocs.pm/ecto) for more information. Other resources available are:

  * [Programming Ecto](https://pragprog.com/book/wmecto/programming-ecto), by Darin Wilson and Eric Meadows-Jönsson, which guides you from fundamentals up to advanced concepts

  * [The Little Ecto Cookbook](https://pages.plataformatec.com.br/the-little-ecto-cookbook), a free ebook by Plataformatec, which is a curation of the existing Ecto guides with some extra contents

## Usage

You need to add both Ecto and the database adapter as a dependency to your `mix.exs` file. The supported databases and their adapters are:

Database   | Ecto Adapter           | Dependencies
:----------| :--------------------- | :-----------------------------------------------
PostgreSQL | Ecto.Adapters.Postgres | [ecto_sql][ecto_sql] (requires Ecto v3.0+) + [postgrex][postgrex]
MySQL      | Ecto.Adapters.MyXQL    | [ecto_sql][ecto_sql] (requires Ecto v3.3+) + [myxql][myxql]
MSSQL      | Ecto.Adapters.Tds      | [ecto_sql][ecto_sql] (requires Ecto v3.4+) + [tds][tds]
ETS        | Etso                   | [ecto][ecto] + [etso][etso]

[ecto]: http://github.com/elixir-ecto/ecto
[ecto_sql]: http://github.com/elixir-ecto/ecto_sql
[postgrex]: http://github.com/elixir-ecto/postgrex
[myxql]: http://github.com/elixir-ecto/myxql
[tds]: https://github.com/livehelpnow/tds
[etso]: https://github.com/evadne/etso

For example, if you want to use PostgreSQL, add to your `mix.exs` file:

```elixir
defp deps do
  [
    {:ecto_sql, "~> 3.0"},
    {:postgrex, ">= 0.0.0"}
  ]
end
```

Then run `mix deps.get` in your shell to fetch the dependencies. If you want to use another database, just choose the proper dependency from the table above.

Finally, in the repository definition, you will need to specify the `adapter:` respective to the chosen dependency. For PostgreSQL it is:

```elixir
defmodule MyApp.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres,
  ...
```

## Supported Versions

| Branch | Support                  |
| ------ | ------------------------ |
| v3.3   | Bug fixes                |
| v3.2   | Security patches only    |
| v3.1   | Unsupported from 02/2020 |
| v3.0   | Unsupported from 02/2020 |
| v2.2   | Security patches only    |
| v2.1   | Unsupported from 10/2018 |
| v2.0   | Unsupported from 08/2017 |
| v1.1   | Unsupported from 03/2018 |
| v1.0   | Unsupported from 05/2017 |

With the version 3.0, Ecto has become API stable. This means our main focus is on providing bug fixes and updates.

## Important links

  * [Documentation](http://hexdocs.pm/ecto)
  * [Mailing list](https://groups.google.com/forum/#!forum/elixir-ecto)
  * [Examples](https://github.com/elixir-ecto/ecto/tree/master/examples)

### Running tests

Clone the repo and fetch its dependencies:

    $ git clone https://github.com/elixir-ecto/ecto.git
    $ cd ecto
    $ mix deps.get
    $ mix test

Note that `mix test` does not run the tests in the `integration_test` folder. To run integration tests, you can clone `ecto_sql` in a sibling directory and then run its integration tests with the `ECTO_PATH` environment variable pointing to your Ecto checkout:

    $ cd ..
    $ git clone https://github.com/elixir-ecto/ecto_sql.git
    $ cd ecto_sql
    $ ECTO_PATH=../ecto mix test.all

## Logo

"Ecto" and the Ecto logo are Copyright (c) 2020 Dashbit.

The Ecto logo was designed by [Dane Wesolko](http://www.danewesolko.com).

## License

Copyright (c) 2013 Plataformatec \
Copyright (c) 2020 Dashbit

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# Jason
<img width="250" src="https://github.com/elixir-ecto/ecto/raw/master/guides/images/logo.png" alt="Ecto">

---

[![Build Status](https://github.com/elixir-ecto/ecto/workflows/CI/badge.svg)](https://github.com/elixir-ecto/ecto/actions)

Ecto is a toolkit for data mapping and language integrated query for Elixir. Here is an example:

```elixir
# In your config/config.exs file
config :my_app, ecto_repos: [Sample.Repo]

config :my_app, Sample.Repo,
  database: "ecto_simple",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

# In your application code
defmodule Sample.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres
end

defmodule Sample.Weather do
  use Ecto.Schema

  schema "weather" do
    field :city     # Defaults to type :string
    field :temp_lo, :integer
    field :temp_hi, :integer
    field :prcp,    :float, default: 0.0
  end
end

defmodule Sample.App do
  import Ecto.Query
  alias Sample.{Weather, Repo}

  def keyword_query do
    query =
      from w in Weather,
           where: w.prcp > 0 or is_nil(w.prcp),
           select: w

    Repo.all(query)
  end

  def pipe_query do
    Weather
    |> where(city: "Kraków")
    |> order_by(:temp_lo)
    |> limit(10)
    |> Repo.all
  end
end
```

Ecto is commonly used to interact with databases, such as Postgres and MySQL via [Ecto.Adapters.SQL](http://hexdocs.pm/ecto_sql) ([source code](https://github.com/elixir-ecto/ecto_sql)). Ecto is also commonly used to map data from any source into Elixir structs, regardless if they are backed by a database or not.

See the [getting started guide](http://hexdocs.pm/ecto/getting-started.html) and the [online documentation](http://hexdocs.pm/ecto) for more information. Other resources available are:

  * [Programming Ecto](https://pragprog.com/book/wmecto/programming-ecto), by Darin Wilson and Eric Meadows-Jönsson, which guides you from fundamentals up to advanced concepts

  * [The Little Ecto Cookbook](https://pages.plataformatec.com.br/the-little-ecto-cookbook), a free ebook by Plataformatec, which is a curation of the existing Ecto guides with some extra contents

## Usage

You need to add both Ecto and the database adapter as a dependency to your `mix.exs` file. The supported databases and their adapters are:

Database   | Ecto Adapter           | Dependencies
:----------| :--------------------- | :-----------------------------------------------
PostgreSQL | Ecto.Adapters.Postgres | [ecto_sql][ecto_sql] (requires Ecto v3.0+) + [postgrex][postgrex]
MySQL      | Ecto.Adapters.MyXQL    | [ecto_sql][ecto_sql] (requires Ecto v3.3+) + [myxql][myxql]
MSSQL      | Ecto.Adapters.Tds      | [ecto_sql][ecto_sql] (requires Ecto v3.4+) + [tds][tds]
ETS        | Etso                   | [ecto][ecto] + [etso][etso]

[ecto]: http://github.com/elixir-ecto/ecto
[ecto_sql]: http://github.com/elixir-ecto/ecto_sql
[postgrex]: http://github.com/elixir-ecto/postgrex
[myxql]: http://github.com/elixir-ecto/myxql
[tds]: https://github.com/livehelpnow/tds
[etso]: https://github.com/evadne/etso

For example, if you want to use PostgreSQL, add to your `mix.exs` file:

```elixir
defp deps do
  [
    {:ecto_sql, "~> 3.0"},
    {:postgrex, ">= 0.0.0"}
  ]
end
```

Then run `mix deps.get` in your shell to fetch the dependencies. If you want to use another database, just choose the proper dependency from the table above.

Finally, in the repository definition, you will need to specify the `adapter:` respective to the chosen dependency. For PostgreSQL it is:

```elixir
defmodule MyApp.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres,
  ...
```

## Supported Versions

| Branch | Support                  |
| ------ | ------------------------ |
| v3.3   | Bug fixes                |
| v3.2   | Security patches only    |
| v3.1   | Unsupported from 02/2020 |
| v3.0   | Unsupported from 02/2020 |
| v2.2   | Security patches only    |
| v2.1   | Unsupported from 10/2018 |
| v2.0   | Unsupported from 08/2017 |
| v1.1   | Unsupported from 03/2018 |
| v1.0   | Unsupported from 05/2017 |

With the version 3.0, Ecto has become API stable. This means our main focus is on providing bug fixes and updates.

## Important links

  * [Documentation](http://hexdocs.pm/ecto)
  * [Mailing list](https://groups.google.com/forum/#!forum/elixir-ecto)
  * [Examples](https://github.com/elixir-ecto/ecto/tree/master/examples)

### Running tests

Clone the repo and fetch its dependencies:

    $ git clone https://github.com/elixir-ecto/ecto.git
    $ cd ecto
    $ mix deps.get
    $ mix test

Note that `mix test` does not run the tests in the `integration_test` folder. To run integration tests, you can clone `ecto_sql` in a sibling directory and then run its integration tests with the `ECTO_PATH` environment variable pointing to your Ecto checkout:

    $ cd ..
    $ git clone https://github.com/elixir-ecto/ecto_sql.git
    $ cd ecto_sql
    $ ECTO_PATH=../ecto mix test.all

## Logo

"Ecto" and the Ecto logo are Copyright (c) 2020 Dashbit.

The Ecto logo was designed by [Dane Wesolko](http://www.danewesolko.com).

## License

Copyright (c) 2013 Plataformatec \
Copyright (c) 2020 Dashbit

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# Earmark


# Earmark—A Pure Elixir Markdown Processor

[![Build Status](https://travis-ci.org/pragdave/earmark.svg?branch=master)](https://travis-ci.org/pragdave/earmark)
[![Hex.pm](https://img.shields.io/hexpm/v/earmark.svg)](https://hex.pm/packages/earmark)
[![Hex.pm](https://img.shields.io/hexpm/dw/earmark.svg)](https://hex.pm/packages/earmark)
[![Hex.pm](https://img.shields.io/hexpm/dt/earmark.svg)](https://hex.pm/packages/earmark)


## Table Of Contents

<!-- BEGIN generated TOC -->
* [Dependency](#dependency)
* [Usage](#usage)
* [Details](#details)
* [`Earmark.as_html/2`](#earmarkas_html2)
* [`Earmark.as_ast/2`](#earmarkas_ast2)
* [`Earmark.Transform.transform/2`](#earmarktransformtransform2)
* [Contributing](#contributing)
* [Author](#author)
<!-- END generated TOC -->

## Dependency

    { :earmark, "> x.y.z" }

## Usage

<!-- BEGIN inserted moduledoc Earmark -->

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

<!-- END inserted moduledoc Earmark -->

## Details

## `Earmark.as_html/2`

<!-- BEGIN inserted functiondoc Earmark.as_html/2 -->
Given a markdown document (as either a list of lines or
a string containing newlines), returns a tuple containing either
`{:ok, html_doc, error_messages}`, or `{:error, html_doc, error_messages}`
Where `html_doc` is an HTML representation of the markdown document and
`error_messages` is a list of tuples with the following elements

- `severity` e.g. `:error`, `:warning` or `:deprecation`
- line number in input where the error occurred
- description of the error


`options` can be an `%Earmark.Options{}` structure, or can be passed in as a `Keyword` argument (with legal keys for `%Earmark.Options` 

* `renderer`: ModuleName

  The module used to render the final document. Defaults to
  `Earmark.HtmlRenderer`

* `gfm`: boolean

  True by default. Turns on the supported Github Flavored Markdown extensions

* `breaks`: boolean

  Only applicable if `gfm` is enabled. Makes all line breaks
  significant (so every line in the input is a new line in the
  output.

* `code_class_prefix`: binary

  Code blocks will be rendered with prefixed class names, which might be necessary for
  usage with 3rd party libraries.


        Earmark.as_html("```elixir\nCode\n```", code_class_prefix: "my_prefix_")

        {:ok, "<pre><code class=\"elixir my_prefix_elixir\">Code\```</code></pre>\n", []}


* `smartypants`: boolean

  Turns on smartypants processing, so quotes become curly, two
  or three hyphens become en and em dashes, and so on. True by
  default.

  So, to format the document in `original` and disable smartypants,
  you'd call


        alias Earmark.Options
        Earmark.as_html(original, %Options{smartypants: false})


* `pure_links`: boolean

  Pure links of the form `~r{\bhttps?://\S+\b}` are rendered as links from now on.
  However, by setting the `pure_links` option to `false` this can be disabled and pre 1.4 
  behavior can be used.

<!-- END inserted functiondoc Earmark.as_html/2 -->

## `Earmark.as_ast/2`

<!-- BEGIN inserted functiondoc Earmark.as_ast/2 -->
**EXPERIMENTAL**, but well tested, just expect API changes in the 1.4 branch

      iex(9)> markdown = "My `code` is **best**"
      ...(9)> {:ok, ast, []} = Earmark.as_ast(markdown)
      ...(9)> ast
      [{"p", [], ["My ", {"code", [{"class", "inline"}], ["code"]}, " is ", {"strong", [], ["best"]}]}] 

Options are passes like to `as_html`, some do not have an effect though (e.g. `smartypants`) as formatting and escaping is not done
for the AST.

      iex(10)> markdown = "```elixir\nIO.puts 42\n```"
      ...(10)> {:ok, ast, []} = Earmark.as_ast(markdown, code_class_prefix: "lang-")
      ...(10)> ast
      [{"pre", [], [{"code", [{"class", "elixir lang-elixir"}], ["IO.puts 42"]}]}]

**Rationale**:

The AST is exposed in the spirit of [Floki's](https://hex.pm/packages/floki) there might be some subtle WS
differences and we chose to **always** have tripples, even for comments.
We also do return a list for a single node


      Floki.parse("<!-- comment -->")           
      {:comment, " comment "}

      Earmark.as_ast("<!-- comment -->")
      {:ok, [{:comment, [], [" comment "]}], []}

Therefore `as_ast` is of the following type

      @typep tag  :: String.t | :comment
      @typep att  :: {String.t, String.t}
      @typep atts :: list(att)
      @typep node :: String.t | {tag, atts, ast}

      @type  ast  :: list(node)

<!-- END inserted functiondoc Earmark.as_ast/2 -->

## `Earmark.Transform.transform/2`

<!-- BEGIN inserted functiondoc Earmark.Transform.transform/2 -->
**EXPERIMENTAL**
But well tested, just expect API changes in the 1.4 branch
Takes an ast, and optional options (I love this pun), which can be
a map or keyword list of which the following keys will be used:

- `smartypants:` `boolean`
- `initial_indent:` `number`
- `indent:` `number`

      iex(1)> transform({"p", [], [{"em", [], "help"}, "me"]})
      "<p>\n  <em>\n    help\n  </em>\n  me\n</p>\n"

Right now only transformation to HTML is supported.

The transform is also agnostic to any annotation map that is added to the AST.

Only the `:meta` key is reserved and by passing annotation maps with a `:meta` key
into the AST the result might become altered or an exception might be raised, otherwise...

      iex(2)> transform({"p", [], [{"em", [], ["help"], %{inner: true}}], %{level: 1}})
      "<p>\n  <em>\n    help\n  </em>\n</p>\n"

<!-- END inserted functiondoc Earmark.Transform.transform/2 -->

## Contributing

Pull Requests are happily accepted.

Please be aware of one _caveat_ when correcting/improving `README.md`.

The `README.md` is generated by the mix task `readme` from `README.template` and
docstrings by means of `%moduledoc` or `%functiondoc` directives.

Please identify the origin of the generated text you want to correct and then
apply your changes there.

Then issue the mix task `readme`, this is important to have a correctly updated `README.md` after the merge of
your PR.

Thank you all who have already helped with Earmark, your names are duely noted in [CHANGELOG.md](CHANGELOG.md).

## Author

Copyright © 2014,5,6,7,8 Dave Thomas, The Pragmatic Programmers
@/+pragdave,  dave@pragprog.com

# LICENSE

Same as Elixir, which is Apache License v2.0. Please refer to [LICENSE](LICENSE) for details.

SPDX-License-Identifier: Apache-2.0
