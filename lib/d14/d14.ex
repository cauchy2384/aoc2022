defmodule D14 do

  require Matrix
  def solve(fname) do

    m = Matrix.new(1000, 1000, ?.)
    m = Matrix.set(m, 0, 500, ?o)

    max_y = fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.flat_map(fn l ->
      String.split(l, "->")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&(String.split(&1, ",")))
      |> Enum.map(fn [_, y] -> String.to_integer(y) end)
    end)
    |> Enum.max()

    IO.puts(max_y)
    m = Enum.reduce(0..1000, m, fn x, m -> Matrix.set(m, max_y + 2, x, ?#) end)

    [ m ] = fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.flat_map(fn l ->
      String.split(l, "->")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&(String.split(&1, ",")))
      |> Enum.map(fn [col, row] -> [String.to_integer(col), String.to_integer(row)] end)
      |> Enum.chunk_every(2, 1, :discard)
    end)
    |> Stream.scan(m, fn [[x1, y1], [x2, y2]], m ->
      if x1 == x2 do
        [ m ] = Enum.scan(Enum.min([y1,y2])..Enum.max([y1,y2]), m, fn y, m ->
          Matrix.set(m, y, x1, ?#)
        end)
        |> Enum.take(-1)
        m
      else
        [ m ] = Enum.scan(Enum.min([x1,x2])..Enum.max([x1,x2]), m, fn x, m ->
          Matrix.set(m, y1, x, ?#)
         end)
        |> Enum.take(-1)
        m
      end
    end)
    |> Stream.take(-1)
    |> Enum.to_list()

    print_cave(m, max_y+3)
    IO.puts("***********************************************8")

    {m, _coords, total} = Stream.iterate(0, &(&1+1))
    |> Enum.reduce_while({m, nil, 0}, fn _tick, {m, coords, total} ->
      # print_cave(m, max_y+3)
      if is_out(coords, max_y) do
        {:halt , {m, coords, total}}
      else
        {m, coords, total, go} = tick(m, coords, total)
        {go , {m, coords, total}}
      end
    end)

    print_cave(m, max_y+3)

    total

  end

  def print_cave(m, max_y) do
    Enum.each(0..max_y - 1, fn y ->
      [ l ] = Enum.scan(300..700, [], fn x, l ->
        l ++ [ Matrix.elem(m, y, x) ]
      end)
      |> Enum.take(-1)

      IO.puts(to_string(l))
      0
    end)
  end

  def tick(m, coords, total) when is_nil(coords) do
    tick(m, [500, 0], total)
  end

  def tick(m, coords, total) do
    {moveable, next_coords} = can_move(m, coords)
    cond do
    moveable ->
      [x, y] = coords
      m = Matrix.set(m, y, x, ?.)
      [x, y] = next_coords
      m = Matrix.set(m, y, x, ?o)
      {m, next_coords, total, :cont}
    !moveable and coords == [500, 0] ->
      {m, nil, total, :halt}
    true ->
      {m, nil, total + 1, :cont}
    end
  end

  def can_move(m, [x, y]) do
    [b, lb, rb] = [
      Matrix.elem(m, y + 1, x, ?#),
      Matrix.elem(m, y + 1, x - 1, ?#),
      Matrix.elem(m, y + 1, x + 1, ?#)
    ]
    cond do
      b == ?. -> {true, [x, y + 1]}
      lb == ?. -> {true, [x - 1, y + 1]}
      rb == ?. -> {true, [x + 1, y + 1]}
      true -> {false, nil}
    end
  end

  def is_out(coords, _max_y) when is_nil(coords) do
    false
  end

  def is_out(coords, max_y) do
    [_x, y] = coords
    if y > max_y + 3 do
      true
    else
      false
    end
  end

end
