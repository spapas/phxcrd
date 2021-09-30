defmodule PhxcrdWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `PhxcrdWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, PhxcrdWeb.AuthorityLive.FormComponent,
        id: @authority.id || :new,
        action: @live_action,
        authority: @authority,
        return_to: Routes.authority_index_path(@socket, :index) %>
  """
  def live_modal(_socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component( PhxcrdWeb.ModalComponent, modal_opts)
  end
end
