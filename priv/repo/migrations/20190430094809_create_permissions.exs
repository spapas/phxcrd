defmodule Phxcrd.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :name, :string, size: 64, null: false
      add :verbose_name, :string, size: 64, null: false

      timestamps()
    end
  end
end
