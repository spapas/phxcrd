defmodule PhxcrdWeb.VersionView do
  use PhxcrdWeb, :view

  import Scrivener.HTML

  def schemas() do
    Application.get_env(:ex_audit, :tracked_schemas, [])
  end
end
