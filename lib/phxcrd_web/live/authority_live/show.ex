defmodule PhxcrdWeb.AuthorityLive.Show do
  use PhxcrdWeb, :live_view

  alias Phxcrd.Auth

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:authority, Auth.get_authority!(id))}
  end

  defp page_title(:show), do: "Show Authority"
  defp page_title(:edit), do: "Edit Authority"
end
