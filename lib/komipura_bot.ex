defmodule KomipuraBot do
  @moduledoc """
  Documentation for KomipuraBot.
  """

  def url do
    "http://www.com-pla.com/reservation/index.php"
  end

  def fetch(day) do
    url()
    |> HTTPoison.get!
    |> handle_result
    |> day_info(day)
  end

  def handle_result(%HTTPoison.Response{body: html, status_code: 200}) do
    html
  end

  def day_info(html, day) do
    html
    |> Floki.find("table table")
    |> Enum.take(-3)
    |> Enum.map(fn h -> (1..7 |> Enum.map(&(period_info(h, day, &1)))) end)
  end

  def period_info(html, day, period) do
    html
    |> Floki.find("tr:nth-child(#{period + 2}) th:nth-child(#{day + 1})")
    |> Floki.find("font")
    |> Floki.text
    |> is_ok
  end

  def is_ok(<<129, 155>>) do
    true
  end

  def is_ok(<<129, 126>>) do
    false
  end
end
