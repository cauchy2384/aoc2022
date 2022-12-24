defmodule D24 do

  # D24.solve("input/d24/example.txt", 20)
  # D24.solve("input/d24/input.txt", 500)
  def solve(fname, max_steps \\ 3) do

    start = start_position(fname)
    finish = finish_position(fname)
    size = size(fname)
    bzs = blizzards(fname)

    IO.inspect({start, finish, size})
    # IO.inspect(bzs)

    {blz_vars, _s, _bzs} = Stream.iterate(0, &(&1+1))
    |> Enum.reduce_while(
        {Map.new(), MapSet.new(), bzs},
        fn step, {m, s, bzs} ->
          if MapSet.member?(s, bzs) do
            {:halt, {m, s, bzs}}
          else
            m = Map.put(m, step, bzs)
            s = MapSet.put(s, bzs)
            bzs = move_blizzards(bzs, size)
            {:cont, {m, s, bzs}}
          end
        end
    )
    IO.puts("precached blizzards number: #{map_size(blz_vars)}")

    cache = MapSet.new()
    res = run(cache, start, start, finish, size, blz_vars, 0, max_steps)
    res2 = run(cache, finish, finish, start, size, blz_vars, res, max_steps)
    res3 = run(cache, start, start, finish, size, blz_vars, res2, max_steps)

    IO.inspect([res, res2, res3])
  end

  def run(cache, pos, start, finish, size, blz_vars, step, max_steps) do

    Stream.iterate(step, &(&1+1))
    |> Enum.reduce_while(
      {cache, [{pos, step}], step},
      fn _idx, {cache, queue, prev_step} ->
        if length(queue) == 0 do
          {:halt, -1}
        else
          {pos, steps} = hd(queue)
          queue = tl(queue)

          log(prev_step, steps, queue, cache)
          # IO.inspect(cache)

          key = {pos, steps}

          {res, cache} = _run(cache, pos, start, finish, size, blz_vars, steps, max_steps)

          cache = MapSet.put(cache, key)

          cond do
            is_list(res) ->
              res = Enum.map(res, fn r -> {r, steps + 1} end)
              queue = queue ++ res
              {:cont, {cache, queue, steps}}
            is_integer(res) ->
              {:halt, res}
          end
        end
      end
    )
  end

  def log(step, steps, queue, cache) do
    if step != steps do
      IO.puts("Step: #{step}, queue: #{length(queue)}, cache: #{MapSet.size(cache)}")
    end
  end

  def _run(cache, pos, start, finish, size, blz_vars, steps, max_steps) do
    # IO.puts("Minute #{steps}, max minutes #{max_steps}")
    # print(pos, finish, bzs, size)
    key = {pos, steps}
    bzs = Map.get(blz_vars, rem(steps, map_size(blz_vars)))

    cond do
    pos == finish ->
      IO.puts(steps)
      print(pos, finish, bzs, size)
      # cache = MapSet.put(cache, key)
      {steps, cache}
    MapSet.member?(cache, key) ->
      {[], cache}
    has_collided(pos, bzs) ->
      {[], cache}
    distance_to_finish(pos, finish) + steps >= max_steps ->
      {[], cache}
    steps + 1 == max_steps ->
      {[], cache}
    true ->
      bzs = Map.get(blz_vars, rem(steps + 1, map_size(blz_vars)))
      moves = elf_moves(pos, start, finish, bzs, size)
      |> Enum.filter(fn x -> !MapSet.member?(cache, {x, steps + 1}) end)
      {moves, cache}
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
