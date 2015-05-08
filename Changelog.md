# 0.1.16 5/8/15
* Another fix from José, this time for & in code blocks.

# 0.1.13 01/31/15

* José fixed a bug in Regex that revealed a problem with some
  Earmark replacement strings. As he's a true gentleman, he then
  fixed Earmark.
  
# 0.1.11 08/18/14

* Matthew Lyon contributed footnote support.

      the answer is clearly 42.[^fn-why] In this case
      we need to…

      [^fn-why]: 42 is the only two digit number with
                 the digits 4 and 2 that starts with a 4.

  For now, consider it experimental. For that reason, you have
  to enable it by passing the `footnotes: true` option.
  
# 0.1.10 08/13/14

* The spec is ambiguous when it comes to setext headings. I assumed
  that they needed a blank line after them, but common practice says
  no. Changed the parser to treat them as headings if there's no
  blank.

# 0.1.9 08/05/14

* Bug fix—extra blank lines could be appended to code blocks.
* Tidied up code block HTML

# 0.1.7 07/26/16

* Block rendering is now performed in parallel


# 0.1.6 07/25/16

* Added support for Kramdown-style attribute annotators for all block
  elements, so you can write

        # Warning
        {: .red}

        Do not turn off the engine
        if you are at altitude.
        {: .boxed #warning spellcheck="true"}

  and generate

        <h1 class="red">Warning</h1>
        <p spellcheck="true" id="warning" class="boxed">Do not turn 
        off the engine if you are at altitude.</p>

        
# 0.1.5 07/20/16

* Merged two performance improvements from José Valim
* Support escaping of pipes in tables, so

        a  |  b
        c  |  d \| e

  has two columns, not three.

  
# 0.1.4 07/14/16

* Allow list bullets to be indented, and deal with potential subsequent
  additional indentation of the body of an item.
  

# 0.1.3 07/14/16

* Added tasks to the Hex file list


# 0.1.2 07/14/14 

* Add support for GFM tables


# 0.1.1 07/09/14 

* Move readme generation task out of mix.exs and into tasks/
* Fix bug if setext heading started on first line


# 0.1.0 07/09/14 Initial Release
