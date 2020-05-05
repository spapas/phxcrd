defmodule PhxcrdWeb.AuthorityLive.Index do
  use PhxcrdWeb, :live_view
  alias Phxcrd.Auth.User
  alias Phxcrd.Auth
  alias Phxcrd.Auth.Authority
  import Canada, only: [can?: 2]


  defp cancan(socket, _options \\ []) do
    if %User{permissions: socket.assigns[:perms]} |> can?(index(Authority)) do
      socket
    else
      socket
      |> put_flash(:error, "Access Denied!")
      |> redirect(to: Routes.page_path(socket, :index))
    end
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(:authorities, fetch_authorities())
     |> assign(:user_id, session |> Map.fetch!("user_id"))
     |> assign(:perms, session |> Map.fetch!("permissions"))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Authorities")
    |> assign(:authority, nil)
    |> cancan()
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Authority")
    |> assign(:authority, Auth.get_authority!(id))
    |> cancan()
  end

  defp apply_action(socket, :delete, %{"id" => id}) do
    socket
    |> assign(:page_title, "Delete Authority")
    |> assign(:authority, Auth.get_authority!(id))
    |> cancan()
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Authority")
    |> assign(:authority, %Authority{})
    |> cancan()
  end

  @impl true


  @impl true
  def handle_event("filter", %{"filter" => %{"name"=> name}}, socket) do
    name |> IO.inspect
    {:noreply, socket|> assign(:authorities, filter_authorities(name))
  }
  end

  defp fetch_authorities do
    Auth.list_authorities()
  end

  defp filter_authorities(name)  do
    Auth.filter_authorities(name)
  end
end
