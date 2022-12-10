defmodule D10 do

  def solve(fname) do

    fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.replace(&1, "\n", "")))
    # |> Stream.each(&IO.inspect/1)
    |> Stream.flat_map(&map/1)
    |> Stream.scan({0, 1}, &exec/2)
    |> Stream.filter(fn {tick, _} -> rem(tick, 40) == 20 end)
    |> Stream.dedup_by(fn {tick, _} -> tick end)
    |> Stream.map(fn {tick, v} -> tick * v end)
    |> Stream.scan(0, fn v, sum -> v + sum end)
    |> Stream.take(-1)
    |> Stream.each(&IO.inspect/1)
    |> Stream.run()

  end

  def solve2(fname) do

    fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Stream.flat_map(&map/1)
    |> Stream.scan({0, 1}, &exec/2)
    |> Stream.dedup_by(fn {tick, _} -> tick end)
    |> Stream.map(fn {tick, v} ->
      if abs(rem(tick - 1, 40) - v) <= 1, do: '#', else: '.'
    end)
    |> Stream.chunk_every(40)
    |> Stream.map(&List.to_string/1)
    |> Stream.each(&IO.inspect/1)
    |> Stream.run()

  end

  def map("addx" <> rest) do
    ["noop", "noop", "addx" <> rest]
  end

  def map(any) do [any] end

  def exec("addx " <> rest, {tick, v} ) do
    i = String.to_integer(rest)
    {tick, v + i}
  end

  def exec("noop", {tick, v}) do
    {tick + 1, v}
  end

end
