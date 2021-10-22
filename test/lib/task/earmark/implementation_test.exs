defmodule Test.Lib.Task.Earmark.ImplementationTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Mix.Tasks.Earmark

  describe "help and version" do
    test "can show some help" do
      help_text = capture_io(:stderr, fn -> run(~W[--help]) end)
      assert help_text == "Coming soon\n\n"
    end
    test "version is semantic" do
      version = capture_io(:stdio, fn -> run(~W[--version]) end)
      Version.parse!(String.trim_trailing(version))
    end
  end

  describe "error handling" do
    test "bad option" do
      error_text = capture_io(:stderr, fn -> run(~W[--hlp --vsn]) end)
      assert error_text == "Illegal options --hlp, --vsn\n"
    end
    test "bad file type" do
      error_text = capture_io(:stderr, fn -> run(~W[test/fixtures/base.html]) end)
      assert error_text == "Input file needs to be an eex template, not test/fixtures/base.html\n"
    end
    test "no such file" do
      error_text = capture_io(:stderr, fn -> run(~W[no-such-file.html.eex]) end)
      assert error_text == "Cannot open no-such-file.html.eex, reason: enoent\n"
    end
  end

  describe "simple fixture" do
    test "no options" do
      run(~W[test/fixtures/base.html.eex])

      expected =
        "<html>\n  <body>\n    <h1>\nMain</h1>\n<h2>\n  Sub</h2>  Gallia est omnis divisa in partes tres</h2>\n\n  </body>\n</html>\n"

      result = File.read!("test/fixtures/base.html")

      assert result == expected
    end

    test "bad file" do
      assert_raise Earmark.Error,
                   "Cannot open test/fixtures/does-not-exist.md.eex for reading: enoent",
                   fn ->
                     run(~W[test/fixtures/bad_filename.html.eex])
                   end
    end
  end

  describe "complex fixture" do
    @complex "test/fixtures/complex.html"
    test "no options" do
      run([@complex <> ".eex"])

      expected =
        "<h1>Complex</h1>\n<strong>Text</strong> of level 1\n<h2>\n  Content of Level2</h2>  line1  <br />  line2      ### End</h2>\n\n"

      result = File.read!(@complex)
      assert result == expected
    end
  end
end
