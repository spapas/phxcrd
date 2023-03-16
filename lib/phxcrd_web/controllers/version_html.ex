defmodule PhxcrdWeb.VersionHTML do
  use PhxcrdWeb, :html
  import Scrivener.HTML

  def schemas() do
    Application.get_env(:ex_audit, :tracked_schemas, [])
  end

  embed_templates "version_html/*"
end
