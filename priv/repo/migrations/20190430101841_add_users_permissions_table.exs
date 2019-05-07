defmodule Phxcrd.Repo.Migrations.AddUsersPermissionsTable do
  use Ecto.Migration

  def change do
    create table(:users_permissions) do
      add :permission_id, references(:permissions, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create(index(:users_permissions, [:permission_id]))
    create(index(:users_permissions, [:user_id]))

    create(
      unique_index(:users_permissions, [:user_id, :permission_id],
        name: :user_id_permission_id_unique_index
      )
    )
  end
end
