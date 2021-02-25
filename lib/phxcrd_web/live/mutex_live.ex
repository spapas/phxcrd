defmodule PhxcrdWeb.MutexLive do
  use PhxcrdWeb, :live_view
  require Logger

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    Logger.info("mounting ... #{user_id}")

    if Phxcrd.Mutex.lock(user_id) == :ok do
      {:ok, assign(socket, user_id: user_id, state: Phxcrd.Mutex.get_state())}
    else
      {:ok, redirect(socket, to: "/")}
    end
  end
end
