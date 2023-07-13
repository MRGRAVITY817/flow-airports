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

  @doc """
  Opens airports data at once - uploading on CPU.
  This might be slower than stream_airports/0.
  """
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

  @doc """
  Stream (lazily open) airports data.
  """
  def stream_airports() do
    airports_csv()
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn row ->
      %{
        id: :binary.copy(Enum.at(row, 0)),
        type: :binary.copy(Enum.at(row, 2)),
        name: :binary.copy(Enum.at(row, 3)),
        country: :binary.copy(Enum.at(row, 8))
      }
    end)
    |> Stream.reject(&(&1.type == "closed"))
    |> Enum.to_list()
  end

  @doc """
  Read airports with Flow
  """
  def flow_airports() do
    airports_csv()
    |> File.stream!()
    # |> CSV.parse_stream() <- we don't need this since flow is based on a single data source
    |> Flow.from_enumerable()
    |> Flow.map(fn row ->
      [row] = CSV.parse_string(row, skip_headers: false)

      %{
        id: Enum.at(row, 0),
        type: Enum.at(row, 2),
        name: Enum.at(row, 3),
        country: Enum.at(row, 8)
      }
    end)
    |> Flow.reject(&(&1.type == "closed"))
    |> Flow.partition(key: {:key, :country})
    |> Flow.reduce(fn -> %{} end, fn item, acc ->
      Map.update(acc, item.country, 1, &(&1 + 1))
    end)
    |> Enum.to_list()
  end
end
