defmodule PhxcrdWeb.ModalComponent do
  use PhxcrdWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="phx-modal"
      phx-capture-click=""
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>

      <div class="phx-modal-content" >

        <%= live_patch raw("&times;"), to: @return_to, class: "close phx-modal-close" %>
        <%= live_component @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
