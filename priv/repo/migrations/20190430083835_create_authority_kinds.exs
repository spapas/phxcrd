defmodule Phxcrd.Repo.Migrations.CreateAuthorityKinds do
  use Ecto.Migration

  def change do
    create table(:authority_kinds) do
      add :name, :string, size: 64, null: false

      timestamps()
    end
  end
end
