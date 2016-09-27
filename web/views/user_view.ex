defmodule Sas.UserView do
  use Sas.Web, :view

  def render("user.json", %{user: user}) do
    %{name: user.name,
      role: user.role}
  end
end
