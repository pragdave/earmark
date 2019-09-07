defmodule Support.Html1Helpers do

  def to_html1(markdown, options \\ []) do
    {status, ast, messages} = Earmark.as_ast(markdown, options)
    if System.get_env("DEBUG") do
      IO.inspect(ast)
    end
    {status, Earmark.Transform.transform(ast, options), messages}
  end
end
