defmodule Phxcrd.Plugs.ExAuditPlug do
  def init(_) do
    nil
  end

  def call(conn, _) do
    ExAudit.track(actor_id: conn.assigns.user_id)
    conn
  end
end
