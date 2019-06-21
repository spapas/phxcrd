defmodule PhxcrdWeb.ThermostatLiveView do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(PhxcrdWeb.PageView, "thermostat.html", assigns)
  end

  def mount(%{user_id: user_id}, socket) do
    case get_user_reading(user_id) do
      {:ok, temperature} ->
        {:ok, assign(socket, :temperature, temperature)}

      {:error, reason} ->
        {:ok, assign(socket, :temperature, reason)}
    end
  end

  defp get_user_reading(user_id) do
    case user_id do
      nil -> {:error, "Please login"}
      v -> {:ok, v * 100}
    end
  end
end
