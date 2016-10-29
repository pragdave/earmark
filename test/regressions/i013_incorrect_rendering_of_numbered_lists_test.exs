defmodule Regressions.I013IncorrectRenderingOfNumberedLists do
  use ExUnit.Case
  @indented_list """
    Para

    1. l1

    2. l2
  """

  test "Issue https://github.com/pragdave/earmark/issues/13" do
    result = Earmark.as_html! @indented_list
    assert result == """
                     <p>  Para</p>
                     <ol>
                     <li><p>l1</p>
                     </li>
                     <li><p>l2</p>
                     </li>
                     </ol>
                     """
  end

end
