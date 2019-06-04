defmodule PhxcrdWeb.ApiView do
  use PhxcrdWeb, :view

  def render("authorities.json", %{authorities: authorities}) do
    %{results: Enum.map(authorities, &authority_json/1)}
  end

  def authority_json(a) do
    %{
      id: a.id,
      text: "#{a.authority_kind.name} #{a.name}"
    }
  end
end
