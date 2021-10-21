defmodule Test.Lib.Task.Earmark.ImplementationTest do
  use ExUnit.Case

  import Mix.Tasks.Earmark

  describe "simple fixture" do
    test "no switches" do
      run(~W[test/fixtures/base.html.eex])
      expected = "<html>\n  <body>\n    <h1>\nMain</h1>\n<h2>\n  Sub</h2>  Gallia est omnis divisa in partes tres</h2>\n\n  </body>\n</html>\n" 
      result = File.read!("test/fixtures/base.html")


      assert result == expected

    end
  end
end
