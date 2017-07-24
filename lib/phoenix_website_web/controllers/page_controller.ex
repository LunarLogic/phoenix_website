defmodule PhoenixWebsiteWeb.PageController do
  use PhoenixWebsiteWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
