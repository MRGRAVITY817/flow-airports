defmodule Airports do
  @moduledoc """
  Documentation for `Airports`.
  """

  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Returns full path of airports csv file.
  """
  def airports_csv() do
    Application.app_dir(:airports, "/priv/airports.csv")
  end

  def open_airports() do
    airports_csv()
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.map(fn row ->
      %{
        id: Enum.at(row, 0),
        type: Enum.at(row, 2),
        name: Enum.at(row, 3),
        country: Enum.at(row, 8)
      }
    end)
    |> Enum.reject(&(&1.type == "closed"))
  end
end
