require 'faraday'
require 'json'

class JsonPointerMiddleware < Faraday::Middleware
  JSON_MIME_TYPE = "application/json"

  def call(env)
    @app.call(env).on_complete do |env|
      unless env.response_headers["Content-Type"] == JSON_MIME_TYPE
        return
      end

      @body = JSON.parse(env.body)
      pointerize(@body)
      begin
        env.body = @body.to_json
      rescue JSON::NestingError
      end
    end
  end

  def pointerize(body)
    body.each do |key, value|
      if value.is_a?(Hash)
        pointerize(value)
      end
      next unless value =~ /\//

      pointer_keys = value.split("/")[1..-1]
      pointer_keys = pointer_keys.map do |key|
        key.gsub("~1", "/")
      end
      pointer_keys = pointer_keys.map do |key|
        key.gsub("~0", "~")
      end
      pointer_keys = pointer_keys.map do |key|
        # Convert array indices to Integers
        Integer(key) rescue key
      end
      new_value = pointer_keys.inject(@body) do |body, pointer_key|
        next if body.nil?
        body[pointer_key]
      end
      body[key] = new_value if new_value
    end
  end
end
