defmodule Phxcrd.AlarmHandler do
  import Bamboo.Email
  require Logger

  def init({_args, {:alarm_handler, alarms}}) do
    Logger.debug("Custom alarm handler init!")
    for {alarm_id, alarm_description} <- alarms, do: handle_alarm(alarm_id, alarm_description)
    {:ok, []}
  end

  def handle_event({:set_alarm, {alarm_id, alarm_description}}, state) do
    Logger.warn("Got an alarm " <> Atom.to_string(alarm_id) <> " " <> alarm_description)
    handle_alarm(alarm_id, alarm_description)
    {:ok, state}
  end

  def handle_event({:clear_alarm, alarm_id}, state) do
    Logger.debug("Clearing the alarm  " <> Atom.to_string(alarm_id))
    state |> IO.inspect()
    {:ok, state}
  end

  def handle_alarm(alarm_id, alarm_description) do
    Logger.debug("Handling alarm " <> Atom.to_string(alarm_id))

    new_email(
      to: "foo@foofoo.com",
      from: "bar@bar.gr",
      subject: "New alarm!",
      html_body:
        "<strong>Alert:" <> Atom.to_string(alarm_id) <> " " <> alarm_description <> "</strong>",
      text_body: "Alert:" <> Atom.to_string(alarm_id) <> " " <> alarm_description
    )
    |> Phxcrd.Mailer.deliver_later()

    Logger.debug("End handling alarm " <> Atom.to_string(alarm_id))
  end
end
