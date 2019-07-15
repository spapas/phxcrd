defmodule Phxcrd.Repo.Migrations.AddUserPhotoPath do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :photo_path, :string
    end
  end
end
