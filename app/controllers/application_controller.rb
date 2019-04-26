class ApplicationController < ActionController::Base
  DocRaptor.configure do |config|
    config.username = "YOUR_API_KEY_HERE"
    # config.debugging = true
  end
end
