defmodule Support.WipHelpers do
  
  defmacro assert_size list, size do
    quote do
      assert Enum.count(unquote(list)) == unquote(size)
    end
  end
end
