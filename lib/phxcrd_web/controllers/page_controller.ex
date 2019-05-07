defmodule PhxcrdWeb.PageController do
  use PhxcrdWeb, :controller
  import Bamboo.Email

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def test_sentry(conn, _params) do
    username = conn.assigns[:username]

    if username == "spapas" do
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
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def test_mail(conn, _params) do
    username = conn.assigns[:username]

    if username == "spapas" do
      new_email(
        to: "spapas@gmail.com",
        from: "noreply@hcg.gr",
        subject: "Testing email",
        html_body: "<strong>Thanks for joining!</strong>",
        text_body: "Thanks for joining!"
      )
      |> Phxcrd.Mailer.deliver_now()

      conn
      |> put_flash(:info, "Message  sent!")
      |> redirect(to: Routes.page_path(conn, :index))
    else
      conn
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
