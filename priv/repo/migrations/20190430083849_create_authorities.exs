defmodule Phxcrd.Repo.Migrations.CreateAuthorities do
  use Ecto.Migration

  def change do
    create table(:authorities) do
      add :name, :string, size: 64, null: false
      add :authority_kind_id, references(:authority_kinds, on_delete: :restrict), null: false

      timestamps()
    end

    create index(:authorities, [:authority_kind_id])
  end
end
