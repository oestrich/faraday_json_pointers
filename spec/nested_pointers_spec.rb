require 'spec_helper'

describe "nested pointers" do
  specify "top level pointers are automatically dereferenced" do
    json = {
      "name" => {
        "first" => "/first_name",
      },
      "first_name" => "eric",
    }.to_json

    body = faraday(json).get("/").body
    expect(JSON.parse(body)).to eq({
      "name" => {
        "first" => "eric",
      },
      "first_name" => "eric",
    })
  end
end
