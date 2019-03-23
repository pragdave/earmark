
### Creating docs

This is tricky as we have a circular dependency problem between `Earmark` and `ExDoc`

Therfore we will use an alias `mix doc` task that will use an ex_doc escript built apart

E.g.

```
  git clone https://github.com/elixir-lang/ex_doc
  git checkout v0.19.3 # or latest version
  mix escript.build
  cd <earmark>
  EX_DOC_ESCRIPT=<your local escript path unless in $PATH> ./build_docs.sh

```

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
