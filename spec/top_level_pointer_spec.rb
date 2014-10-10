require 'spec_helper'

describe "top level pointers" do
  specify "top level pointers are automatically dereferenced" do
    json = {
      "name" => "/first_name",
      "first_name" => "eric",
    }.to_json

    body = faraday(json).get("/").body
    expect(JSON.parse(body)).to eq({
      "name" => "eric",
      "first_name" => "eric",
    })
  end

  specify "second level object" do
    json = {
      "first_name" => "/name/first",
      "name" => {
        "first" => "eric",
      },
    }.to_json

      body = faraday(json).get("/").body
      expect(JSON.parse(body)).to eq({
        "name" => {
          "first" => "eric",
        },
        "first_name" => "eric",
      })
  end

  specify "pointer to an array index" do
    json = {
      "first_name" => "/names/0/first",
      "names" => [
        {
          "first" => "eric",
        },
      ],
    }.to_json

    body = faraday(json).get("/").body
    expect(JSON.parse(body)).to eq({
      "names" => [
        {
          "first" => "eric",
        },
      ],
      "first_name" => "eric",
    })
  end

  specify "handle escaped '/'" do
    json = {
      "first_name" => "/~1names/0/first",
      "/names" => [
        {
          "first" => "eric",
        },
      ],
    }.to_json

    body = faraday(json).get("/").body
    expect(JSON.parse(body)).to eq({
      "/names" => [
        {
          "first" => "eric",
        },
      ],
      "first_name" => "eric",
    })
  end

  specify "handle escaped ~" do
    json = {
      "first_name" => "/~0names/0/first",
      "~names" => [
        {
          "first" => "eric",
        },
      ],
    }.to_json

    body = faraday(json).get("/").body
    expect(JSON.parse(body)).to eq({
      "~names" => [
        {
          "first" => "eric",
        },
      ],
      "first_name" => "eric",
    })
  end

  specify "handle escaped possible error" do
    json = {
      "first_name" => "/~01names/0/first",
      "~1names" => [
        {
          "first" => "eric",
        },
      ],
    }.to_json

    body = faraday(json).get("/").body
    expect(JSON.parse(body)).to eq({
      "~1names" => [
        {
          "first" => "eric",
        },
      ],
      "first_name" => "eric",
    })
  end

  specify "keys that don't exist are left alone" do
    json = {
      "name" => "/firstname",
      "first_name" => "eric",
    }.to_json

    body = faraday(json).get("/").body
    expect(JSON.parse(body)).to eq({
      "name" => "/firstname",
      "first_name" => "eric",
    })
  end

  specify "an array key that doesn't exist" do
    json = {
      "first_name" => "/names/2/first",
      "names" => [
        {
          "first" => "eric",
        },
      ],
    }.to_json

    body = faraday(json).get("/").body
    expect(JSON.parse(body)).to eq({
      "names" => [
        {
          "first" => "eric",
        },
      ],
      "first_name" => "/names/2/first",
    })
  end

  specify "an key that doesn't exist further down" do
    json = {
      "first_name" => "/names/first/empty",
      "name" => {
        "first" => "eric",
      },
    }.to_json

      body = faraday(json).get("/").body
      expect(JSON.parse(body)).to eq({
        "first_name" => "/names/first/empty",
        "name" => {
          "first" => "eric",
        },
      })
  end

  specify "handles circular references" do
    json = {
      "name" => {
        "first" => "/name",
      },
    }.to_json

    body = faraday(json).get("/").body
    expect(JSON.parse(body)).to eq({
      "name" => {
        "first" => "/name",
      },
    })
  end
end
