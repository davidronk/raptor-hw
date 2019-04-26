class PdfMetadataController < ApplicationController
  
  # takes an array of urls and returns json metadata for each
  def index

    results = {}
    if params[:urls].present?

      @docraptor = DocRaptor::DocApi.new
      docraptor_futures = []
      
      # create async docraptor pdf requests for urls
      params[:urls].sort.each do |url|
        begin
          docraptor_futures << {
            :url => url,
            :async => docraptor_async(url)
          }
        rescue => e
          puts "Error creating async pdf request: #{e.message}"
        end
      end

      docraptor_futures.each do |future_doc|
        # wait for and process requested pdf
        pdf_str = process_future(future_doc[:async])

        if pdf_str.present?
          # read the metadata from the pdf
          meta = metadata_from_pdf(future_doc[:url], pdf_str)

          if meta.present?
            # populate results grouped by page_count
            page_count = meta[:page_count]
            results[page_count] = [] if results[page_count].nil?
            results[page_count] << meta
          end
        end
      end
    else
      # do something here
      results[:error] = "missing 'urls' parameter"
    end

    render :json => results
  end



  def docraptor_async(url)
    @docraptor.create_async_doc(
      test: true,
      document_url: url,
      document_type: "pdf"
    )
  end

  def process_future(create_response)
    begin
      loop do
        status_response = @docraptor.get_async_doc_status(create_response.status_id)
        puts "doc status: #{status_response.status}"
        case status_response.status
        when "completed"
          return @docraptor.get_async_doc(status_response.download_id)
        when "failed"
          puts "FAILED: #{status_response}"
          break
        else
          sleep 1
        end
      end
    rescue => e
      puts "Error processing async pdf request: #{e.message}"
    end
    nil
  end

  def metadata_from_pdf(url, pdf_str)
    # meta = nil
    begin
      return StringIO.open(pdf_str, "rb") do |io|
        reader = PDF::Reader.new(io)
        {
          :url => url,
          :pdf_version => reader.pdf_version,
          :info => reader.info,
          :metadata => reader.metadata,
          :page_count => reader.page_count
        }
      end
    rescue => e
      puts "Error reading PDF from #{url}: #{e.message}"
    end
    nil
  end
end
