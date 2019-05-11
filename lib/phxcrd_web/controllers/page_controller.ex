defmodule PhxcrdWeb.PageController do
  use PhxcrdWeb, :controller
  import Bamboo.Email

  def index(conn, _params) do
    render(conn, "index.html")
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
    invoice_html = """
    <!doctype html>
    <html>
    <head>
    <meta charset="utf-8">
    <style>
    .invoice-box {
        max-width: 800px;
        margin: auto;
        padding: 30px;
        font-size: 16px;
        line-height: 24px;
        font-family: 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif;
        color: #555;
    }

    .invoice-box table {
        width: 100%;
        line-height: inherit;
        text-align: left;
    }

    .invoice-box table td {
        padding: 5px;
        vertical-align: top;
    }

    .invoice-box table tr td:nth-child(2) {
        text-align: right;
    }

    .invoice-box table tr.top table td {
        padding-bottom: 20px;
    }

    .invoice-box table tr.top table td.title {
        font-size: 45px;
        line-height: 45px;
        color: #333;
    }

    .invoice-box table tr.information table td {
        padding-bottom: 40px;
    }

    .invoice-box table tr.heading td {
        background: #eee;
        border-bottom: 1px solid #ddd;
        font-weight: bold;
    }

    .invoice-box table tr.details td {
        padding-bottom: 20px;
    }

    .invoice-box table tr.item td{
        border-bottom: 1px solid #eee;
    }

    .invoice-box table tr.item.last td {
        border-bottom: none;
    }

    .invoice-box table tr.total td:nth-child(2) {
        border-top: 2px solid #eee;
        font-weight: bold;
    }

    @media only screen and (max-width: 600px) {
        .invoice-box table tr.top table td {
            width: 100%;
            display: block;
            text-align: center;
        }

        .invoice-box table tr.information table td {
            width: 100%;
            display: block;
            text-align: center;
        }
    }

    </style>
    </head>

    <body>
    <div class="invoice-box">
        <table cellpadding="0" cellspacing="0">
            <tr class="top"><td colspan="2"><table>
                        <tr><td class="title">Τίτλος!</td>
                            <td>
                                Τιμολόγιο #: 123<br>
                                Ημ. δημιουργίας: 1η Ιανουαρίου 2015<br>
                                Μέχρι: 1η Φεβρουαρίου 2015
                            </td></tr></table></td>
            </tr>

            <tr class="information">
                <td colspan="2"><table><tr><td>
                                Sparksuite, Inc.<br>
                                12345 Sunny Road<br>
                                Sunnyville, CA 12345
                </td></tr></table></td>
            </tr>

            <tr class="heading"><td>Payment Method</td><td>Check #</td></tr>
            <tr class="details"><td>Check</td><td>1000</td></tr>
            <tr class="details"><td>Check 2</td><td>10100</td></tr>
            <tr class="heading"><td>Item</td><td>Price</td></tr>
            <tr class="item"><td>Website design</td><td>$300.00</td></tr>
            <tr class="item"><td>Hosting (3 months)</td><td>$75.00</td></tr>
            <tr class="item"><td>Domain name (1 year)</td><td>$10.00</td></tr>
            <tr class="item"><td>Domain name (1 year)</td><td>$10.00</td></tr>
            <tr class="item"><td>Domain name (1 year)</td><td>$10.00</td></tr>
            <tr class="item"><td>Domain name (1 year)</td><td>$10.00</td></tr>
            <tr class="item last"><td>Domain name (1 year)</td><td>$10.00</td></tr>
            <tr class="total"><td></td><td>Total: $385.00</td></tr>
        </table>
    </div>
    </body>
    </html>
    """

    {:ok, filename} =
      PdfGenerator.generate(invoice_html,
        page_size: "A4",
        # shell_params: ["--outline", "--outline-depth3", "--footer-center", "[page]/[topage]"],
        shell_params: ["--outline", "--footer-right", "[page] από [topage]"],
        delete_temporary: true
      )

    {:ok, pdf_content} = File.read(filename)

    conn
    |> put_resp_content_type("application/pdf")
    #    |> put_resp_header("content-disposition", "attachment; filename=\"example_deck.pdf\"")
    |> send_resp(200, pdf_content)
  end
end
