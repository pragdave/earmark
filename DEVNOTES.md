
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
