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

for category <- ~w(Alcohol Cocktail Mixer Snack) do
  Repo.insert!(%Category{name: category})
end
