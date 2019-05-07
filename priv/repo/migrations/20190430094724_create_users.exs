defmodule Phxcrd.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, size: 64, null: false
      add :name, :string, size: 64, null: false
      add :first_name, :string
      add :last_name, :string
      add :email, :string, size: 64, null: false
      add :am, :string
      add :am_phxcrd, :string
      add :dsn, :string
      add :kind, :string
      add :extra, :string
      add :obj_cls, :string
      add :authority_id, references(:authorities, on_delete: :restrict)
      add :last_login, :utc_datetime

      timestamps()
    end

    create index(:users, [:authority_id])
  end
end
