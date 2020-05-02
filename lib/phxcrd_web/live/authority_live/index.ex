defmodule PhxcrdWeb.AuthorityLive.Index do
  use PhxcrdWeb, :live_view

  alias Phxcrd.Auth
  alias Phxcrd.Auth.Authority

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :authorities, fetch_authorities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Authority")
    |> assign(:authority, Auth.get_authority!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Authority")
    |> assign(:authority, %Authority{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Authorities")
    |> assign(:authority, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    authority = Auth.get_authority!(id)
    {:ok, _} = Auth.delete_authority(authority)

    {:noreply, assign(socket, :authorities, fetch_authorities())}
  end

  defp fetch_authorities do
    Auth.list_authorities()
  end
end
