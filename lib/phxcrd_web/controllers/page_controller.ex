defmodule PhxcrdWeb.PageController do
  use PhxcrdWeb, :controller
  import Bamboo.Email

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def test_presence(conn, _params) do
    render(conn, "test_presence.html")
  end

  def test_live(conn, _params) do
    render(conn, "test_live.html")
    # live_render(conn, PhxcrdWeb.ThermostatLiveView, session: %{id: 32, current_user_id: 33})
  end

  def test_sentry(conn, _params) do
    if conn.assigns[:perms] |> Enum.member?("superuser") do
      try do
        ThisWillError.reall()
      rescue
        my_exception ->
          Sentry.capture_exception(my_exception,
            stacktrace: System.stacktrace(),
            extra: %{extra: "Error"}
          )
      end

      conn
      |> put_flash(:info, "Message to sentry sent!")
      |> redirect(to: Routes.page_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Please login as superuser!")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def test_mail(conn, _params) do
    # More info: https://phoenixframework.org/blog/sending-email-with-smtp
    if conn.assigns[:perms] |> Enum.member?("superuser") do
      new_email(
        to: "foo@bar.com",
        from: "bar@bar.gr",
        subject: "Testing email",
        html_body: "<strong>Thanks for testing!</strong>",
        text_body: "Thanks for testing!"
      )
      |> Phxcrd.Mailer.deliver_later()

      # or use deliver now to block (and raise exception) until mail has been sent
      # |> Phxcrd.Mailer.deliver_now()

      conn
      |> put_flash(:info, "Message  sent!")
      |> redirect(to: Routes.page_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Please login as superuser!")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def test_xlsx(conn, _params) do
    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header("content-disposition", "attachment; filename=\"report.xlsx\"")
    |> render("report.xlsx", %{posts: ["a", "b", "c"]})
  end

  def test_pdf(conn, _params) do
    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header("content-disposition", "attachment; filename=\"report.pdf\"")
    |> render("root.pdf", %{posts: ["a", "b", "c"]})
  end
end
