defmodule PhxcrdWeb.PageView do
  use PhxcrdWeb, :view

  alias Elixlsx.{Workbook, Sheet}

  @header [
    ["ID", bold: true, size: 22],
    ["Name", bold: true, size: 18, font: "Courier New"],
    "Title",
    "Content"
  ]

  def report_generator(posts) do
    rows = posts |> Enum.map(&row(&1))

    %Workbook{
      sheets: [
        %Sheet{name: "Posts", rows: [@header] ++ rows} |> Sheet.set_row_height(1, 40)
      ]
    }
  end

  def row(post) do
    [
      post,
      ["foo", bold: true],
      "Δεζ",
      123
    ]
  end

  def render("report.xlsx", %{posts: posts}) do
    report_generator(posts)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

  def render("report.pdf", %{posts: _posts}) do
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
    pdf_content
  end
end
