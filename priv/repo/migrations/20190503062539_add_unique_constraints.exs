defmodule Phxcrd.Repo.Migrations.AddUniqueConstraints do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
    create unique_index(:permissions, [:name])
    create unique_index(:authority_kinds, [:name])
    create unique_index(:authorities, [:name])
  end
end
