defmodule InlineTest do
  use ExUnit.Case

  import Support.Helpers

  ############################################################
  # Tests                                                    #
  ############################################################

  test "smoke" do
    result = convert_pedantic("hello")
    assert result == "hello"
  end

  test "line ending with 2 spaces causes a <br/>" do
    result = convert_pedantic("hello  \nworld")
    assert result == "hello<br/>world"
  end

  ############
  # Emphasis #
  ############

  test "asterisk means <em>" do
    result = convert_pedantic("hello *world*")
    assert result == "hello <em>world</em>"
  end

  test "underscore means <em>" do
    result = convert_pedantic("hello _world_")
    assert result == "hello <em>world</em>"
  end

  test "double asterisk means <strong>" do
    result = convert_pedantic("hello **world**")
    assert result == "hello <strong>world</strong>"
  end

  test "double underscore means <strong>" do
    result = convert_pedantic("hello __world__")
    assert result == "hello <strong>world</strong>"
  end

  test "emphasis works inside words" do
    result = convert_pedantic("un*frigging*believable")
    assert result == "un<em>frigging</em>believable"
  end

  test "asterisks surrounded by spaces are not emphasis in pedantic mode" do
    result = convert_pedantic("un * frigging * believable")
    assert result == "un * frigging * believable"
  end

  test "asterisks surrounded by spaces are emphasis in gfm mode" do
    result = convert_gfm("un * frigging * believable")
    assert result.value == "un <em> frigging </em> believable"
  end

  test "backslashes stop asterisks being significant" do
    result = convert_pedantic("hello \\*world\\*")
    assert result == "hello *world*"
  end

  test "tilde mean strikethrough" do
    result = convert_gfm("this ~~not this~~")
    assert result.value == "this <del>not this</del>"
  end

  #################
  # Inline images #
  #################

  test "inline image tag" do
    result = convert_pedantic("the ![image](/path.jpg) tag")
    assert result == ~S[the <img src="/path.jpg" alt="image"/> tag]
  end

  test "inline image tag with a title" do
    result = convert_pedantic(~s<the ![image](/path.jpg "a title") tag>)
    assert result == ~S[the <img src="/path.jpg" alt="image" title="a title"/> tag]
  end

  ###################
  # Automatic links #
  ###################
  test "automatic links" do
    result = convert_pedantic("a <http://google.com> link")
    assert result == ~s[a <a href="http://google.com">http://google.com</a> link]
  end

  test "email link" do
    result = convert_pedantic("a <dave@google.com> link")
    assert result == ~s[a <a href="mailto:dave@google.com">dave@google.com</a> link]
  end

  ################
  # Inline links #
  ################

  test "basic inline link" do
    result = convert_pedantic(~s{a [an example](http://example.com/ "Title") link})
    assert result == ~s[a <a href="http://example.com/" title="Title">an example</a> link]
  end

  test "basic inline link with title in single quotes" do
    result = convert_pedantic(~s{a [an example](http://example.com/ 'Title') link})
    assert result == ~s[a <a href="http://example.com/" title="Title">an example</a> link]
  end

  test "link with no title" do
    result = convert_pedantic(~s{a [an example](http://example.com/) link})
    assert result == ~s[a <a href="http://example.com/">an example</a> link]
  end

  ###################
  # Reference links #
  ###################

  test "basic reference link" do
    result = convert_pedantic(~s{a [my link][id1] link})
    assert result == ~s[a <a href=\"url%201\" title=\"title 1\">my link</a> link]
  end

  test "basic no link" do
    result = convert_pedantic(~s{a [my link][no-such-number] nolink})
    assert result == ~s{a [my link][no-such-number] nolink}
  end

  test "case insensitive reference link" do
    result = convert_pedantic(~s{a [my link][ID1] link})
    assert result == ~s[a <a href=\"url%201\" title=\"title 1\">my link</a> link]
  end

  test "basic reference link with no title" do
    result = convert_pedantic(~s{a [my link][id2] link})
    assert result == ~s[a <a href="url%202">my link</a> link]
  end

  test "basic reference link with a space inside" do
    result = convert_pedantic(~s{a [mylink]  [id1] link})
    assert result == ~s[a <a href=\"url%201\" title=\"title 1\">mylink</a> link]
  end

  test "shorthand reference link" do
    result = convert_pedantic(~s{a [id1][] link})
    assert result == ~s[a <a href="url%201" title="title 1">id1</a> link]
  end

  test "imbricated image inside reference link" do
    result = convert_pedantic(~s{a [![my link](url)][id1] link})
    assert result == "a <a href=\"url%201\" title=\"title 1\"><img src=\"url\" alt=\"my link\"/></a> link"
  end

  test "imbricated link inside reference link" do
    result = convert_pedantic(~s{a [[my link](url)][id1] link})
    assert result == "a <a href=\"url%201\" title=\"title 1\">[my link](url)</a> link"
  end


  #########################
  # Reference image links #
  #########################

  test "basic reference image link" do
    result = convert_pedantic(~s{a ![my image][img1] link})

    assert result ==
      ~s[a <img src="img%201" alt="my image" title="image 1"/> link]
  end

  test "basic reference image link with no title" do
    result = convert_pedantic(~s{a ![my image][img2] link})
    assert result ==
      ~s[a <img src="img%202" alt="my image"/> link]
  end

  test "basic reference image link with link in alt" do
    result = convert_pedantic(~s{a ![[my image](my url "my title")][img1] link})
    assert result ==
      ~s{a <img src="img%201" alt="[my image](my url &quot;my title&quot;)" title="image 1"/> link}
  end

  test "basic reference image link with image in alt" do
    result = convert_pedantic(~s{a ![![my image](my url "my title")][img1] link})
    assert result ==
      ~s{a <img src="img%201" alt="![my image](my url &quot;my title&quot;)" title="image 1"/> link}
  end

  ###############
  # Inline HTML #
  ###############

  test "inline HTML" do
    result = convert_pedantic(~s[a <span class="red">a&b</span> color])
    assert result == ~s[a <span class="red">a&amp;b</span> color]
  end
end
