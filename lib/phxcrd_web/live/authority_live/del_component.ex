defmodule PhxcrdWeb.AuthorityLive.DelComponent do
  use PhxcrdWeb, :live_component

  alias Phxcrd.Auth

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:errors, "")
     |> assign(assigns)}
  end

  @impl true
  def handle_event("delete", _, socket) do
    delete_authority(socket)
  end

  defp delete_authority(socket) do
    case Auth.delete_authority(socket.assigns.authority) do
      {:ok, _authority} ->
        {:noreply,
         socket
         |> put_flash(:info, "Authority deleted successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{errors: [users: {reason, _}]}} ->
        {:noreply, assign(socket, :errors, "Error while deleting (" <> reason <> ")!")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, assign(socket, :errors, "Error, cannot delete!")}
    end
  end
end
