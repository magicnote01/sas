# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sas.Repo.insert!(%Sas.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Sas.Repo
alias Sas.Category
alias Sas.Table
alias Sas.User

for category <- ~w(Alcohol Cocktail Mixer Snack) do
  Repo.insert!(%Category{name: category})
end

name = "bar"
pass = "bar"

Repo.insert!(%Table{name: name, password: pass})

name = "admin"
pass = "admin"
role = User.admin

pass_hash = Comeonin.Bcrypt.hashpwsalt(pass)

admin = Repo.get_by!(User, name: name)
Repo.delete(admin)
Repo.insert!(%User{name: name, password_hash: pass_hash, role: role})
