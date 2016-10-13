defmodule Sas.ReportView do
  use Sas.Web, :view

  use Timex

  def show_datetime(datetime) do
    Timezone.convert(datetime, "Asia/Bangkok")
    |> Timex.format!("{YYYY}-{0M}-{0D} {h24}:{m}")
  end

end
