defmodule PhxcrdWeb.ThermostatLiveView do
  use Phoenix.LiveView

  def render(assigns) do
    PhxcrdWeb.PageView.render("thermostat.html", assigns)
    # or
    # Phoenix.View.render(PhxcrdWeb.PageView, "thermostat.html", assigns)
  end

  def mount(%{user_id: user_id}, socket) do
    if connected?(socket), do: :timer.send_interval(500, self(), :update)

    case get_user_reading(user_id) do
      {:ok, temperature} ->
        {:ok, socket |> assign(:temperature, temperature) |> assign(:user_id, temperature)}

      {:error, reason} ->
        {:ok, assign(socket, :temperature, reason)}
    end
  end

  def handle_info(:update, socket) do
    {:ok, temperature} = get_user_reading(socket.assigns.user_id)
    {:noreply, socket |> assign(:temperature, temperature) |> assign(:user_id, temperature)}
  end

  def handle_event("reset_temperature", _value, socket) do
    {:noreply, socket |> assign(:temperature, 0) |> assign(:user_id, 0)}
  end

  defp get_user_reading(user_id) do
    case user_id do
      nil -> {:error, "Please login"}
      v -> {:ok, v + 1}
    end
  end
end
