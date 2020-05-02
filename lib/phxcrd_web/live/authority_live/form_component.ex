defmodule PhxcrdWeb.AuthorityLive.FormComponent do
  use PhxcrdWeb, :live_component

  alias Phxcrd.Auth

  @impl true
  def update(%{authority: authority} = assigns, socket) do
    changeset = Auth.change_authority(authority)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"authority" => authority_params}, socket) do
    changeset =
      socket.assigns.authority
      |> Auth.change_authority(authority_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"authority" => authority_params}, socket) do
    save_authority(socket, socket.assigns.action, authority_params)
  end

  defp save_authority(socket, :edit, authority_params) do
    case Auth.update_authority(socket.assigns.authority, authority_params) do
      {:ok, _authority} ->
        {:noreply,
         socket
         |> put_flash(:info, "Authority updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_authority(socket, :new, authority_params) do
    case Auth.create_authority(authority_params) do
      {:ok, _authority} ->
        {:noreply,
         socket
         |> put_flash(:info, "Authority created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
