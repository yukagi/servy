defmodule Servy.Conv do
  defstruct method: "",
    path: "",
    resp_headers: %{
      "Content-Type" => "text/html",
    },
    resp_body: "",
    params: %{},
    headers: %{},
    status: nil

  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

  def put_resp_content_type(conv, type) do
    headers = Map.put(conv.resp_headers, "Content-Type", type)
    %{ conv | resp_headers: headers }
  end

  def put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body))
    %{ conv | resp_headers: headers }
  end

  def put_status_code(conv, code) do
    %{ conv | status: code }
  end

  def put_response_body(conv, body) do
    %{ conv | resp_body: body }
  end
end
