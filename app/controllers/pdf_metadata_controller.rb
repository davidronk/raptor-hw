class PdfMetadataController < ApplicationController
  
  DocRaptor.configure do |config|
    config.username = "YOUR_API_KEY_HERE"
    # config.debugging = true
  end

  # takes an array of urls and returns json metadata for each
  def index

    results = {}
    if params[:urls].present?
      params[:urls].each do |url|

        # use docraptor to convert html > pdf
        pdf_str = docraptor_sync url

        # read the metadata from the pdf
        meta = metadata_from_pdf(url, pdf_str)

        # populate results grouped by page_count
        page_count = meta[:page_count]
        results[page_count] = [] if results[page_count].nil?
        results[page_count] << meta
      end

      # sort each page group by url
      results.each_value do |same_size_pdfs|
        same_size_pdfs.sort_by! {|doc| doc[:url]}
      end
    end

    results[0] = {
      :params => params[:urls].size,
      :urls => params[:urls]
    }

    render :json => results
  end

  private
  def docraptor_sync(url)
    docraptor = DocRaptor::DocApi.new
    docraptor.create_doc(
      test:             true,                                         # test documents are free but watermarked
      document_url:   url,
      # name:             "docraptor-ruby.pdf",                         # help you find a document later
      document_type:    "pdf",                                        # pdf or xls or xlsx
      # javascript:       true,                                       # enable JavaScript processing
      prince_options: {
      #   media: "screen",                                            # use screen styles instead of print styles
      #   # baseurl: "http://hello.com",                                # pretend URL when using document_content
      },
    )
  end

  def metadata_from_pdf(url, pdf_str)
    meta = {}
    StringIO.open(pdf_str, "rb") do |io|
      reader = PDF::Reader.new(io)
      meta[:url] = url
      meta[:pdf_version] = reader.pdf_version
      meta[:info] = reader.info
      meta[:metadata] = reader.metadata
      meta[:page_count] = reader.page_count
    end
    meta
  end

  def set_default_response_format
    request.format = :json
  end
end
