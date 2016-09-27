defmodule Sas.PageController do
  use Sas.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def admin_index(conn, _params) do
    render conn, "index_admin.html"
  end
end
