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
end
