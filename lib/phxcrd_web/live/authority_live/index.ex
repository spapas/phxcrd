defmodule PhxcrdWeb.AuthorityLive.Index do
  use PhxcrdWeb, :live_view
  alias Phxcrd.Auth.User
  alias Phxcrd.Auth
  alias Phxcrd.Auth.{Authority, AuthorityKind}
  alias Phxcrd.Repo
  import Ecto.Query, only: [from: 2, order_by: 3]
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

  defp parse_int(s) do
    with {number, ""} <- Integer.parse(s) do
      number
    else
      _ -> 1
    end
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Authorities")
    |> assign(:authority, nil)
    |> assign(:params, %{
      "page" => Map.get(params, "page", "1") |> parse_int,
      "filter" => Map.get(params, "filter", %{"name" => ""})
    })
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
  def handle_event("filter", %{"filter" => %{"name" => name}}, socket) do
    socket |> IO.inspect()
    params = Map.update!(socket.assigns.params, "filter", fn _v -> %{"name" => name} end)
    params = params |> Map.put("page", 1)

    {:noreply,
     socket
     |> assign(:authorities, filter_authorities(params))
     |> assign(:params, params)
     |> push_patch(to: AdminRoutes.authority_index_path(socket, :index, params))}
  end

  def handle_event("next_page", _args, socket) do
    params = Map.update!(socket.assigns.params, "page", &(&1 + 1)) |> IO.inspect()

    {:noreply,
     socket
     |> assign(:authorities, filter_authorities(params))
     |> assign(:params, params)
     |> push_patch(to: AdminRoutes.authority_index_path(socket, :index, params))}
  end

  def handle_event("prev_page", _args, socket) do
    params = Map.update!(socket.assigns.params, "page", &(&1 - 1)) |> IO.inspect()

    {:noreply,
     socket
     |> assign(:authorities, filter_authorities(params))
     |> assign(:params, params)
     |> push_patch(to: AdminRoutes.authority_index_path(socket, :index, params))}
  end

  defp fetch_authorities do
    # Auth.list_authorities()  |> Repo.paginate

    from(a in Authority,
      as: :authority,
      join: ak in AuthorityKind,
      as: :authority_kind,
      on: [id: a.authority_kind_id],
      preload: [authority_kind: ak]
    )
    |> Repo.paginate()
  end

  defp filter_authorities(params) do
    from(a in Authority,
      as: :authority,
      join: ak in AuthorityKind,
      as: :authority_kind,
      on: [id: a.authority_kind_id],
      preload: [authority_kind: ak],
      where: ilike(a.name, ^("%" <> Map.get(params["filter"], "name", "") <> "%"))
    )
    |> Repo.paginate(params)
  end
end
