defmodule Scipse.PDFUtil do
  require Logger

  def get_exes do
    pdfinfo_exe =
      case System.find_executable "pdfinfo" do
        nil -> raise("Can't find pdfinfo. Make sure poppler-utils >= 0.26.5-16 is installed and pdfinfo is on the $PATH.")
        path -> path
      end

    pdftocairo_exe =
      case System.find_executable "pdftocairo" do
        nil -> raise("Can't find pdftocairo. Make sure poppler-utils >= 0.26.5-16 is installed and pdfinfo is on the $PATH.")
        path -> path
      end

    %{:pdfinfo => pdfinfo_exe,
      :pdftocairo => pdftocairo_exe}
  end

  def get_page_count(src_pdf_path) do
    pdfinfo_exe = 
      get_exes()
      |> Map.get(:pdfinfo)

    {pdf_page_count, ""} =
      :os.cmd(~c(#{pdfinfo_exe} #{src_pdf_path} | grep "Pages: " | awk '{ printf $2 }'))
      |> to_string
      |> Integer.parse

    pdf_page_count
  end
end
