alias Sas.Repo
alias Sas.User

name = "admin"
pass = "admin"
role = User.admin

pass_hash = Comeonin.Bcrypt.hashpwsalt(pass)

admin = Repo.get_by!(User, name: name)
Repo.delete(admin)
Repo.insert!(%User{name: name, password_hash: pass_hash, role: role})
