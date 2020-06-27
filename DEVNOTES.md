### For issue #337
Specs to be rewritten:


   .
 ✓ ├── atx_headers_test.exs
 ✓ ├── block_ial_test.exs
 ✓ ├── block_quotes_test.exs
 ✓ ├── comment_test.exs
 ✓ ├── diverse_test.exs
 ✓ ├── emphasis_test.exs
 - ├── empty_test.exs
 ✓ ├── escape_test.exs
 ✓ ├── fenced_code_blocks_test.exs
 ✓ ├── footnotes_test.exs
 ✓ ├── hard_line_breaks_test.exs
 ✓ ├── horizontal_rules_test.exs
   ├── html
 ✓ │   ├── block_test.exs
   │   ├── oneline_test.exs
   │   └── permissive_test.exs
   ├── ial_test.exs
   ├── indented_code_blocks_test.exs
   ├── inline_code_test.exs
   ├── line_breaks_test.exs
   ├── links_images
   │   ├── img_test.exs
   │   ├── link_test.exs
   │   ├── pure_links_test.exs
   │   └── titles_test.exs
   ├── list_and_block_test.exs
   ├── list_and_inline_code_test.exs
   ├── list_indent_test.exs
   ├── list_test.exs
   ├── paragraphs_test.exs
   ├── reflink_test.exs
   ├── setext_headers_test.exs
   ├── table_test.exs
   └── utf8_test.exs

### Creating docs

This is tricky as we have a circular dependency problem between `Earmark` and `ExDoc`

However, helped by José Valim it can be done with a rather simple workaround for the doc task
in [mix.exs](mix.exs)  


###### How block elements are rendered:

     a line
     <div>headline</div>

as

      <p>a line</p>
      <div>headline</div>

###### List of Block Elements

* address
* article
* aside
* blocksuote
* canvas
* dd
* div
* dl
* fieldset
* figcaption
* h1
* h2
* h3
* h4
* h5
* h6
* header
* hgroup
* li
* main
* nav
* noscript
* ol
* output
* p
* pre
* section
* table
* tfoot
* ul
* video
