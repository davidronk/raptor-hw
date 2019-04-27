# README

## Running locally
* Run against Ruby 2.4.6.
* To run: clone the repo, run `bundle install`, then `bundle exec rails server`

## Running live
* hosted at [https://dmr-raptor-hw.herokuapp.com/pdf_metadata]
* pass `urls` to the above endpoint to convert the page to pdf then display metadata about those pdfs
* ex: [https://dmr-raptor-hw.herokuapp.com/pdf_metadata?urls[]=http://docraptor.com/examples/invoice.html&urls[]=http://google.com&urls[]=https://www.google.com]