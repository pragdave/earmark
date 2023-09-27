defmodule Test.Cli.OptionsTest do
  use ExUnit.Case

  import Earmark.Cli.Implementation, only: [parse_args: 1]

  describe "boolean args" do
    [
      compact_output: false,
      breaks: false,
      eex: false,
      escape: true,
      footnotes: false,
      gfm: true,
      gfm_tables: false,
      ignore_strings: false,
      inner_html: false,
      pedantic: false,
      pure_links: true,
      smartypants: true,
      sub_sup: false,
      template: false,
      wikilinks: false
    ]
    |> Enum.each(fn {arg, default} ->
      empty_test_name = "boolean #{arg}, default: #{default}. No args"

      test empty_test_name do
        assert parse_args([]) |> Map.get(unquote(arg)) == unquote(default)
      end

      expl_test_name = "boolean #{arg} set "

      test expl_test_name do
        assert parse_args(["--#{mk_arg(unquote(arg))}", "a_file"]) |> Map.get(unquote(arg)) ==
                 true
      end

      nega_test_name = "boolean #{arg} unset "

      test nega_test_name do
        assert parse_args(["--no-#{mk_arg(unquote(arg))}", "a_file"]) |> Map.get(unquote(arg)) ==
                 false
      end
    end)
  end

  describe "value args" do
    [
      {:footnote_offset, 1, 41},
      {:line, 1, 42},
      {:timeout, nil, 2_000}
    ]
    |> Enum.each(fn {arg, default, value} ->
      empty_test_name = "value #{arg}, default: #{default}. No args"

      test empty_test_name do
        assert parse_args([]) |> Map.get(unquote(arg)) == unquote(default)
      end

      value_test_name = "value #{arg}, explicit value #{value}"
      test value_test_name do
        assert parse_args(["--#{mk_arg(unquote(arg))}=#{to_string(unquote(value))}", "a_file"]) |> Map.get(unquote(arg)) ==
                 unquote(value)
      end
    end)

    defp mk_arg(arg) do
      arg
      |> to_string
      |> String.replace("_", "-")
    end

    # test "default, smarty pants" do
    #   %Options{smartypants: true} = parse_args([])
    # end
    # test "can be set explicitly" do
    #   assert parse_args(~w[--smartypants some_file]).smartypants
    # end
    # test "can be unset explicitly" do
    #   refute parse_args(~w[--no-smartypants some_file]).smartypants
    # end
  end
end

#  SPDX-License-Identifier: Apache-2.0
