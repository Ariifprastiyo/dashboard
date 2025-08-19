# frozen_string_literal: true

class HttpService
  attr_reader :response, :response_body

  def initialize(*args); end

  def base_url
    raise NotImplementedError
  end

  def relative_url
    raise NotImplementedError
  end

  def http_method
    raise NotImplementedError

    this.downcase
  end

  def request_uuid
    SecureRandom.uuid.freeze
  end

  def success?
    @response.code == 200
  end

  def failed?
    !success?
  end

  def error_message
    {
      message: @response['message']
    }
  end

  def body; end

  def headers; end

  def query; end

  def call
    options = {
      body: body,
      query: query,
      headers: headers
    }

    case http_method
    when 'GET'
      @response = HTTParty.get(base_url + relative_url, options)
    when 'POST'
      @response = HTTParty.post(base_url + relative_url, options)
    when 'PUT'
      @response = HTTParty.put(base_url + relative_url, options)
    when 'DELETE'
      @response = HTTParty.delete(base_url + relative_url, options)
    end

    @response_body = JSON.parse(@response.body).with_indifferent_access if @response.body.present?
  end
end
