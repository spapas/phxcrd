defmodule Phxcrd.Repo.Migrations.AddUserIsEnabled do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_enabled, :boolean, default: true
    end
  end
end
