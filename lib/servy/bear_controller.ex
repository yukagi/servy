defmodule Servy.BearController do
  import Servy.View, only: [render: 3]

  alias Servy.Wildthings
  alias Servy.Bear

  def index(conv) do
    bears = 
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asending_by_name/2)

    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type} = _params) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end

  def delete(conv, _params) do
    %{conv | status: 403, resp_body: "Cannot delete da bears"}
  end
end
