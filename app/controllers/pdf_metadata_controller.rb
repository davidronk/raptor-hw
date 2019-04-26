class PdfMetadataController < ApplicationController
  
  # takes an array of urls and returns json metadata for each
  def index

    results = {}
    if params[:urls].present?

      @docraptor = DocRaptor::DocApi.new
      docraptor_futures = []
      
      # create async docraptor pdf requests for urls
      params[:urls].sort.each do |url|
        docraptor_futures << {
          :url => url,
          :async => docraptor_async(url)
        }
      end

      docraptor_futures.each do |future_doc|
        # wait for and process requested pdf
        pdf_str = process_future(future_doc[:async])

        # read the metadata from the pdf
        meta = metadata_from_pdf(future_doc[:url], pdf_str)

        # populate results grouped by page_count
        page_count = meta[:page_count]
        results[page_count] = [] if results[page_count].nil?
        results[page_count] << meta
      end
    end

    render :json => results
  end



  def docraptor_async(url)
    @docraptor.create_async_doc(
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

  def process_future(create_response)
    loop do
      status_response = @docraptor.get_async_doc_status(create_response.status_id)
      puts "doc status: #{status_response.status}"
      case status_response.status
      when "completed"
        return @docraptor.get_async_doc(status_response.download_id)
      when "failed"
        puts "FAILED"
        puts status_response
        break
      else
        sleep 1
      end
    end
    nil
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
end
