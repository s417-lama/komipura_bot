defmodule KomipuraBot do
  @moduledoc """
  Documentation for KomipuraBot.
  """

  def url do
    "http://www.com-pla.com/reservation/index.php"
  end

  def post(url, month, year) do
    body = "target_ym%5By%5D=#{year}&target_ym%5Bm%5D=#{month}&house=north&facility_id=&usehour_id=&act=&val="
    header = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Content-Length", String.length(body)}
    ]
    HTTPoison.post!(url, body, header)
  end

  def fetch(day, month, year) do
    url()
    |> post(month, year)
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
    "○"
  end

  def is_ok(<<129, 126>>) do
    "×"
  end

  def tweet(text) do
    ExTwitter.update(text)
  end

  def tweet_format_row(n, data) do
    data
    |> Enum.map(&(Enum.at(&1, n)))
    |> Enum.join("     ")
    |> row_title(n)
  end

  def row_title(text, n) when n < 2 do
    "#{n + 1}限     " <> text
  end

  def row_title(text, 2) do
    "昼        " <> text
  end

  def row_title(text, n) when n > 2 do
    "#{n}限     " <> text
  end

  def set_title(text, day, month) do
    "#{month}/#{day} コミプラ予約状況\n" <> "  身体1 身体2 身体3\n" <> text
  end

  def tweet_format(data, day, month) do
    0..6
    |> Enum.map(fn n -> tweet_format_row(n, data) end)
    |> Enum.join("\n")
    |> set_title(day, month)
  end

  def fetch_and_tweet(day, month, year) do
    fetch(day, month, year)
    |> tweet_format(day, month)
    |> tweet
  end

  def exec do
    {{year, month, day}, _} = :calendar.local_time
    fetch_and_tweet(day, month, year)
  end

  def exec_tomorrow do
    {{year, month, day}, _} = :calendar.local_time |> Timex.shift(days: 1)
    fetch_and_tweet(day, month, year)
  end

end
