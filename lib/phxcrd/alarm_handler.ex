defmodule Phxcrd.AlarmHandler do
  @behaviour :gen_event
  import Bamboo.Email

  @impl true
  def init({_args, {:alarm_handler, []}}) do
    "ALARMT INIT EMPTY" |> IO.inspect
    {:ok, []}
  end

  @impl true
  def init({_args, {:alarm_handler, alarms}}) do
    "ALARMT INIT NON EMPTY" |> IO.inspect
    for alarm <- alarms, do: handle_alarm(alarm)
    {:ok, []}
  end

  @impl true
  def handle_call(request, state) do
    "ALARMT HANDLE CALL " |> IO.inspect
    request |> IO.inspect
    state |> IO.inspect
    {:ok, :ok, state}
  end

  @impl true
  def handle_event(request, state) do
    "ALARMT HANDLE EVENT " |> IO.inspect
    request |> IO.inspect
    state |> IO.inspect
    {:ok, state}
  end

  def handle_alarm(alarm) do
    "CUSTOM ALARM HANDLER START" |> IO.inspect

    new_email(
      to: "spapas@gmail.com",
      from: "bar@bar.gr",
      subject: "New alarm!",
      html_body: "<strong>Alert:" <> inspect(alarm) <>  "</strong>",
      text_body: "Alert:" <> inspect(alarm)
    )
    |> Phxcrd.Mailer.deliver_later()
    "CUSTOM ALARM HANDLER END" |> IO.inspect
  end

end
