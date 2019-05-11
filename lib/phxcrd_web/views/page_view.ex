defmodule PhxcrdWeb.PageView do
  use PhxcrdWeb, :view

  alias Elixlsx.{Workbook, Sheet}

  @header [
    ["ID", bold: true, size: 22],
    ["Name", bold: true, size: 18, font: "Courier New"],
    "Title",
    "Content"
  ]
  def render("report.xlsx", %{posts: posts}) do
    report_generator(posts)
    |> Elixlsx.write_to_memory("report.xlsx")
    |> elem(1)
    |> elem(1)
  end

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
      ["goat", bold: true],
      "Δεζ",
      123
    ]
  end
end
