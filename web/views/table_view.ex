defmodule Sas.TableView do
  use Sas.Web, :view

  def render("table.json", %{table: table}) do
    %{name: table.name}
  end
end
