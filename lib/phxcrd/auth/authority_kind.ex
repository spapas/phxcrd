defmodule Phxcrd.Auth.AuthorityKind do
  use Ecto.Schema
  import Ecto.Changeset
  alias Phxcrd.Auth.Authority

  schema "authority_kinds" do
    field :name, :string

    has_many :authorities, Authority

    timestamps()
  end

  @doc false
  def changeset(authority_kind, attrs) do
    authority_kind
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
