defmodule D24 do

  # D24.solve("input/d24/example.txt", 20)
  def solve(fname, max_steps \\ 3) do
    Memoize.invalidate()

    start = start_position(fname)
    finish = finish_position(fname)
    size = size(fname)
    bzs = blizzards(fname)

    IO.inspect({start, finish, size})
    # IO.inspect(bzs)


    cache = Map.new()
    {res, _cache} = run(cache, start, start, finish, size, bzs, 0, max_steps, max_steps)

    res
  end

  def run(cache, pos, start, finish, size, bzs, steps, max_steps, limit) do
    key = {pos, bzs}

    if Map.has_key?(cache, key) do
      {cached_steps, cached_res} = Map.get(cache, key)
      cond do
      steps > cached_steps ->
        {cached_res, cache}
      (steps < cached_steps) and (max_steps != limit)
        res = cached_res - (cached_steps - steps)
        cache = Map.put(cache, key, {steps, res})
        {res, cache}
      true ->
        {res, cache} = _run(cache, pos, start, finish, size, bzs, steps, max_steps, limit)
        cache = Map.put(cache, key, {steps, res})
        {res, cache}
      end
    else
      {res, cache} = _run(cache, pos, start, finish, size, bzs, steps, max_steps, limit)
      cache = Map.put(cache, key, {steps, res})
      {res, cache}
    end
  end

  def _run(cache, pos, start, finish, size, bzs, steps, max_steps, limit) do
    # IO.puts("Minute #{steps}, max minutes #{max_steps}")
    # print(pos, finish, bzs, size)

    cond do
    pos == finish ->
      IO.puts(steps)
      # print(pos, finish, bzs, size)
      {steps, cache}
    has_collided(pos, bzs) ->
      {max_steps, cache}
    distance_to_finish(pos, finish) + steps >= max_steps ->
      {max_steps, cache}
    steps + 1 == max_steps ->
      {max_steps, cache}
    true ->
      next_bzs = move_blizzards(bzs, size)

      moves = elf_moves(pos, start, finish, next_bzs, size)
      # IO.inspect(["moves", moves])

      if length(moves) == 0 do
        {max_steps, cache}
      else
        moves
        |> Enum.reduce({max_steps, cache}, fn next_pos, {max_steps, cache} ->
          {res, cache} = run(cache, next_pos, start, finish, size, next_bzs, steps + 1, max_steps, limit)
          res = Enum.min([res, max_steps])
          {res, cache}
        end)
      end

    end
  end

  def distance_to_finish(pos, finish) do
    {a, b} = pos
    {c, d} = finish
    abs(c - a) + abs(d - b)
  end

  def elf_moves(pos, start, finish, bzs, size) do
    {row, col} = pos

    moves = [
      {row, col + 1},
      {row + 1, col},
      {row, col},
      {row, col - 1},
      {row - 1, col},
    ]
    # IO.inspect({"possible moves", moves})
    # IO.inspect(["blizzards", bzs])

    moves = moves
    |> Enum.reduce([], fn pos, moves ->
      cond do
        pos == start ->
          moves ++ [start]
        pos == finish ->
          moves ++ [pos]
        is_wall(pos, size) ->
          moves
        Map.has_key?(bzs, pos) ->
          moves
        true ->
          moves ++ [pos]
      end
    end)

    if Enum.find_value(moves, fn x -> x == finish end) do
      [finish]
    else
      moves
    end
  end

  def print(pos, finish, bzs, size) do
    {rows, cols} = size
    Enum.each(0..rows-1, fn row ->
      cs = Enum.reduce(0..cols-1, [], fn col, l ->
        cond do
        pos == {row, col} ->
          l ++ [?E]
        finish == {row, col} ->
          l ++ [?F]
        is_wall({row, col}, size) ->
          l ++ [?#]
        Map.has_key?(bzs, {row, col}) ->
          bzl = Map.get(bzs, {row, col})
          if length(bzl) == 1 do
            l ++ [hd(bzl)]
          else
            l ++ [Integer.to_string(length(bzl))]
          end
        true ->
          l ++ [?.]
        end
      end)
      IO.puts(to_string(cs))
    end)

    IO.puts("")
  end

  def move_blizzards(bzs, size) do
    Enum.reduce(
      Map.to_list(bzs),
      Map.new(),
      fn {pos, l}, m ->
        Enum.reduce(l, m, fn c, m ->
          next = move_blizzard(pos, c, size)

          # {r1, c1} = pos
          # {r2, c2} = next
          # IO.puts("wind #{c} from #{r1}, #{c1} to #{r2}, #{c2}")

          l = Map.get(m, next, [])
          l = l ++ [c]
          l = Enum.sort(l)
          Map.put(m, next, l)
        end)
      end)
  end

  def move_blizzard({row, col}, c, size) do
    {rows, cols} = size
    case c do
      ?> ->
        next_pos = {row, col + 1}
        if !is_wall(next_pos, size) do
          next_pos
        else
          {row, 1}
        end

      ?< ->
        next_pos = {row, col - 1}
        if !is_wall(next_pos, size) do
          next_pos
        else
          {row, cols - 2}
        end

      ?^ ->
        next_pos = {row - 1, col}
        if !is_wall(next_pos, size) do
          next_pos
        else
          {rows - 2, col}
        end

      ?v ->
        next_pos = {row + 1, col}
        if !is_wall(next_pos, size) do
          next_pos
        else
          {1, col}
        end
    end
  end

  def is_wall({row, col}, size) do
    {rows, cols} = size
    cond do
      row <= 0 -> true
      row >= (rows - 1) -> true
      col <= 0 -> true
      col >= (cols - 1) -> true
      true -> false
    end
  end

  def has_collided(pos, bzs) do
    Map.has_key?(bzs, pos)
  end

  def start_position(fname) do
    col = fname
    |> File.stream!()
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Enum.take(1)
    |> Enum.reduce(-1, fn l, _col ->
      Enum.reduce_while(to_charlist(l), 0, fn c, col ->
        if c == ?. do
          {:halt, col}
        else
          {:cont, col + 1}
        end
      end)
    end)

    {0, col}
  end

  def finish_position(fname) do
    fname
    |> File.stream!()
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Enum.reduce({-1, -1}, fn l, {row, _col} ->
      col = Enum.reduce_while(to_charlist(l), 0, fn c, col ->
        if c == ?. do
          {:halt, col}
        else
          {:cont, col + 1}
        end
      end)
      {row + 1, col}
    end)
  end

  def size(fname) do
    fname
    |> File.stream!()
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Enum.reduce({0, 0}, fn l, {rows, _cols} ->
      {rows + 1, String.length(l)}
    end)
  end

  def blizzards(fname) do
    {m, _row} = fname
    |> File.stream!()
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Enum.reduce({Map.new(), 0}, fn l, {m, row} ->
      {m, _col} = Enum.reduce(to_charlist(l), {m, 0}, fn c, {m, col} ->
        if is_blizzard(c) do
          m = Map.put(m, {row, col}, [c])
          {m, col + 1}
        else
          {m, col + 1}
        end
      end)
      {m, row + 1}
    end)

    m
  end

  def is_blizzard(c) do
    [?<, ?v, ?^, ?>]
    |> Enum.find_value(fn x -> x == c end)
  end

end
