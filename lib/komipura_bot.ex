defmodule KomipuraBot do
  @moduledoc """
  Documentation for KomipuraBot.
  """

  @url "http://www.com-pla.com/reservation/index.php"

  def post(url, month, year) do
    body = "target_ym%5By%5D=#{year}&target_ym%5Bm%5D=#{month}&house=north&facility_id=&usehour_id=&act=&val="
    header = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Content-Length", String.length(body)}
    ]
    HTTPoison.post!(url, body, header)
  end

  def fetch(day, month, year) do
    post(@url, month, year)
    |> handle_result()
    |> day_info(day)
    |> holiday_filter(day, month, year)
  end

  def holiday_filter(data, day, month, year) do
    date = Date.from_erl!({year, month, day})
    case Date.day_of_week(date) do
      weekday when weekday < 6 ->
        case HolidayJp.holiday?(date) do
          true  -> remove_1period(data)
          false -> data
        end
      _ ->
        remove_1period(data)
    end
  end

  def remove_1period(data) do
    Enum.map(data, fn([_head | tail]) -> ["-" | tail] end)
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

  def is_ok(<<129, 155>>), do: "○"
  def is_ok(<<129, 126>>), do: "×"

  def tweet(text) do
    ExTwitter.update(text)
  end

  def tweet_format_row(n, data) do
    data
    |> Enum.map(&(Enum.at(&1, n)))
    |> Enum.join("     ")
    |> row_title(n)
  end

  def row_title(text, n) when n < 2, do: "#{n + 1}限     " <> text
  def row_title(text, 2)           , do: "昼        "      <> text
  def row_title(text, n) when n > 2, do: "#{n}限     "     <> text

  def set_title(text, day, month) do
    case :calendar.local_time() do
      {{_year, ^month, ^day}, _} -> "本日のコミプラ予約状況\n"           <> "  身体1 身体2 身体3\n" <> text
      _                          -> "#{month}/#{day} コミプラ予約状況\n" <> "  身体1 身体2 身体3\n" <> text
    end
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
    |> tweet()
  end

  def exec() do
    {{year, month, day}, _} = :calendar.local_time
    fetch_and_tweet(day, month, year)
  end

  def exec_tomorrow() do
    {{year, month, day}, _} = :calendar.local_time |> Timex.shift(days: 1)
    fetch_and_tweet(day, month, year)
  end
end
