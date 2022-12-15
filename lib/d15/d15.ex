defmodule D15 do

  require Matrix

  def solve(fname, y_line) do

    set = fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.flat_map(&(String.split(&1, ":")))
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Stream.chunk_every(2)
    |> Stream.filter(fn [{xs, ys}, {xb, yb}] ->
      abs(y_line - ys) <= dist({xs, ys}, {xb, yb})
    end)
    |> Enum.reduce(MapSet.new(), fn  [{xs, ys}, {xb, yb}], set ->
      d = dist({xs, ys}, {xb, yb})
      n = d - abs(y_line - ys)
      Enum.reduce(xs-n..xs+n, set, fn x, set -> MapSet.put(set, x) end)
    end)

    set = fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.flat_map(&(String.split(&1, ":")))
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Enum.reduce(set, fn {x, y}, set ->
      if y == y_line do
        MapSet.delete(set, x)
      else
        set
      end
    end)

    MapSet.size(set)

  end

  def solve2(fname, x_max, y_max) do

    m = fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.flat_map(&(String.split(&1, ":")))
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Stream.chunk_every(2)
    |> Stream.filter(fn [{xs, ys}, {xb, yb}] ->
      d = dist({xs, ys}, {xb, yb})
      cond do
        ys < 0 -> abs(ys) <= d
        ys > y_max -> abs(y_max - ys) <= d
        xs < 0 -> abs(xs) <= d
        xs > x_max -> abs(x_max - xs) <= d
        true -> true
      end
    end)
    |> Enum.reduce(Map.new(), fn  [{xs, ys}, {xb, yb}], m ->
      d = dist({xs, ys}, {xb, yb})
      Enum.reduce(0..y_max, m, fn y, m ->
        n = d - abs(y - ys)
        if n >= 0 do
          xl = min(x_max, max(0, xs - n))
          xr = max(0, min(x_max, xs + n))

          l = Map.get(m, y, [])
          l = l ++ [{xl, xr}]
          Map.put(m, y, l)
        else
          m
        end
      end)
    end)

    Enum.take_while(0..y_max, fn y ->
      l = Map.get(m, y, [])
      l = Enum.sort(l, fn {xl, _x}, {xr, _} ->  xl < xr end)

      l = Enum.reduce(l, [], fn el, l ->
        cond do
          length(l) == 0 -> l ++ [el]
          true ->
            {a, b} = Enum.at(l, length(l) - 1)
            {c, d} = el
            if (c - b) > 1 do
              l ++ [el]
            else
              l = List.delete_at(l, length(l) - 1)
              l = l ++ [{min(a,c) , max(b,d)}]
              l
            end
        end
      end)

      if length(l) != 1 do
        [{_a, _b}, {c, _d}] = l
        # 11379394658764
        IO.puts(calc(c - 1, y))
        false
      else
        true
      end

    end)

    0

  end

  def parse("Sensor at " <> rest) do
    parse_coords(rest)
  end

  def parse("closest beacon is at " <> rest) do
    parse_coords(rest)
  end

  def parse_coords(l) do
    [x, y] = String.split(l, ",")
    |> Enum.map(&String.trim/1)

    {parse_coord(x), parse_coord(y)}
  end

  def parse_coord("x=" <> rest) do
    String.to_integer(rest)
  end

  def parse_coord("y=" <> rest) do
    String.to_integer(rest)
  end

  def dist({xs, ys}, {xb, yb}) do
    abs(xs - xb) + abs(ys - yb)
  end

  def calc(x, y) do
    x * 4000000 + y
  end

end
