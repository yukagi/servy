defmodule Servy.Api.BearController do
  import Servy.Conv, only: [put_resp_content_type: 2, put_status_code: 2, put_response_body: 2]

  def index(conv) do
    json = Servy.Wildthings.list_bears
    |> Poison.encode!

    conv
    |> put_resp_content_type("application/json")
    |> put_status_code(200)
    |> put_response_body(json)
  end

  def create(conv, params) do
    conv
    |> put_resp_content_type("application/json")
    |> put_status_code(201)
    |> put_response_body("Created a Polar bear named #{params["name"]}!")
  end
end
