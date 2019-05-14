defmodule PhxcrdWeb.ApiView do
  use PhxcrdWeb, :view

  def render("authorities.json", %{authorities: authorities}) do
    Enum.map(authorities, &authority_json/1)
  end

  def authority_json(a) do
    %{
      id: a.id,
      kind: a.authority_kind.name,
      name: a.name
    }
  end
end
