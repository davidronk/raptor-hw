class PdfMetadataController < ApplicationController
  DocRaptor.configure do |config|
    config.username = "YOUR_API_KEY_HERE"
    # config.debugging = true
  end

  before_action :set_default_response_format

  def index
    docraptor = DocRaptor::DocApi.new
    response = docraptor.create_doc(
      test:             true,                                         # test documents are free but watermarked
      document_content: "<html><body>Hello World</body></html>",      # supply content directly
      # document_url:   "http://docraptor.com/examples/invoice.html", # or use a url
      name:             "docraptor-ruby.pdf",                         # help you find a document later
      document_type:    "pdf",                                        # pdf or xls or xlsx
      # javascript:       true,                                       # enable JavaScript processing
      # prince_options: {
      #   media: "screen",                                            # use screen styles instead of print styles
      #   # baseurl: "http://hello.com",                                # pretend URL when using document_content
      # },
    )
    puts response.class



    # reader PDF::Reader.new(response)
    StringIO.open(response, "rb") do |io|
      reader = PDF::Reader.new(io)
      puts "pdf_version: #{reader.pdf_version}"
      puts "info #{reader.info}"
      puts "metadata #{reader.metadata}"
      puts "page_count #{reader.page_count}"
    end

    # puts reader.pdf_version
    # puts reader.info
    # puts reader.metadata
    # puts reader.page_count
  end

  private
  def set_default_response_format
    request.format = :json
  end
end
