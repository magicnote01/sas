alias Sas.Repo
alias Sas.Table

name = "bar"
pass = "bar"

Repo.insert!(%Table{name: name, password: pass})
