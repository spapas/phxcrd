defmodule Phxcrd.Auth.Authority do
  use Ecto.Schema

  import Ecto.Changeset
  alias Phxcrd.Auth.AuthorityKind
  alias Phxcrd.Auth.User

  schema "authorities" do
    field :name, :string

    belongs_to :authority_kind, AuthorityKind
    has_many :users, User, on_replace: :nilify

    timestamps()
  end

  @doc false
  def changeset(authority, attrs) do
    authority
    |> cast(attrs, [:name, :authority_kind_id])
    |> validate_required([:name, :authority_kind_id], message: "The field is required")
    |> foreign_key_constraint(:authority_kind_id)
    |> unique_constraint(:name, message: "The name already exists!")
  end

  use Accessible
end
