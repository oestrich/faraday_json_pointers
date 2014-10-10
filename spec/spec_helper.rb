load 'json_pointer_middleware.rb'

def faraday(json)
  stubs = Faraday::Adapter::Test::Stubs.new do |stub|
    stub.get("/") do |env|
      [200, {"Content-Type" => "application/json"}, json]
    end
  end
  faraday = Faraday.new do |builder|
    builder.use JsonPointerMiddleware
    builder.adapter :test, stubs
  end
end
