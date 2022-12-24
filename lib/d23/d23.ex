defmodule D23 do

  require Matrix

  # D23.solve("input/d23/example.txt")
  def solve(fname, turns \\ 10) do
    m = read(fname)

    IO.inspect(m)
    print(m)

    {m, turn} = run(m, turns)

    print(m)
    turn

    # rect = find_rectangle(m)
    # count_empty(m, rect)
  end

  def count_empty(m, [{row_min, col_min}, {row_max, col_max}]) do
    Enum.reduce(row_min..row_max, 0, fn row, acc ->
      Enum.reduce(col_min..col_max, acc, fn col, acc ->
        if !is_elf(m, row, col) do
          acc + 1
        else
          acc
        end
      end)
    end)
  end

  def find_rectangle(m) do

    elves = MapSet.to_list(m)

    row_min = Enum.reduce(elves, 100500, fn {row, _col}, min ->
      if row < min do
        row
      else
        min
      end
    end)

    row_max = Enum.reduce(elves, -1, fn {row, _col}, max ->
      if row > max do
        row
      else
        max
      end
    end)

    col_min = Enum.reduce(elves, 100500, fn {_row, col}, min ->
      if col < min do
        col
      else
        min
      end
    end)

    col_max = Enum.reduce(elves, -1, fn {_row, col}, max ->
      if col > max do
        col
      else
        max
      end
    end)

    [{row_min, col_min}, {row_max, col_max}]
  end

  def run(m, turns) do

    directions =  [:n, :s, :w, :e]

    {m, _directions, turn} = Enum.reduce_while(
      1..turns,
      {m, directions, 1},
      fn turn, {m, directions, _turn} ->
        elves = elves_to_move(m)
        # IO.inspect(elves)
        if map_size(elves) == 0 do
          {:halt, {m, directions, turn}}
        else
          moves = planned_moves(m, elves, directions)
          # IO.inspect(moves)

          {m, moved} = move_elves(m, moves)
          # print(m)

          if moved == 0 do
            {:halt, {m, directions, turn}}
          else
            directions = rotate_directions(directions)
            {:cont, {m, directions, turn}}
          end
        end
      end
    )

    {m, turn}

  end

  def rotate_directions(directions) do
    tl(directions) ++ [hd(directions)]
  end

  def move_elves(m, moves) do
    Enum.reduce(
      Map.keys(moves),
      {m, 0},
      fn next, {m, moved} ->
        elves = Map.get(moves, next, [])
        if length(elves) != 1 do
          {m, moved}
        else
          {row, col} = hd(elves)
          {next_row, next_col} = next
          m = MapSet.put(m, {next_row, next_col})
          m = MapSet.delete(m, {row, col})
          {m, moved + 1}
        end
      end
    )
  end

  def planned_moves(m, elves, directions) do
    Enum.reduce(
      MapSet.to_list(elves),
      Map.new(),
      fn elf, moves ->
        Enum.reduce_while(
          directions,
          moves,
          fn direction, moves ->
            if !can_move(m, elf, direction) do
              {:cont, moves}
            else
              next = move_next(elf, direction)
              l = Map.get(moves, next, [])
              l = l ++ [elf]
              moves = Map.put(moves, next, l)
              {:halt, moves}
            end
          end
        )
      end)
  end

  def move_next({row, col}, dir) when dir == :n do
    {row - 1, col}
  end

  def move_next({row, col}, dir) when dir == :s do
    {row + 1, col}
  end

  def move_next({row, col}, dir) when dir == :w do
    {row, col - 1}
  end

  def move_next({row, col}, dir) when dir == :e do
    {row, col + 1}
  end

  def can_move(m, {row, col}, dir) when dir == :n do
    taken = Enum.reduce([
      {row - 1, col - 1},
      {row - 1, col},
      {row - 1, col + 1},
    ], 0, fn {row, col}, taken -> if is_elf(m, row, col), do: taken + 1, else: taken end)

    taken == 0
  end

  def can_move(m, {row, col}, dir) when dir == :s do
    taken = Enum.reduce([
      {row + 1, col - 1},
      {row + 1, col},
      {row + 1, col + 1},
    ], 0, fn {row, col}, taken -> if is_elf(m, row, col), do: taken + 1, else: taken end)

    taken == 0
  end

  def can_move(m, {row, col}, dir) when dir == :w do
    taken = Enum.reduce([
      {row - 1, col - 1},
      {row, col - 1},
      {row + 1, col - 1},
    ], 0, fn {row, col}, taken -> if is_elf(m, row, col), do: taken + 1, else: taken end)

    taken == 0
  end

  def can_move(m, {row, col}, dir) when dir == :e do
    taken = Enum.reduce([
      {row - 1, col + 1},
      {row, col + 1},
      {row + 1, col + 1},
    ], 0, fn {row, col}, taken -> if is_elf(m, row, col), do: taken + 1, else: taken end)

    taken == 0
  end

  def elves_to_move(m) do

    elves = Enum.reduce(MapSet.to_list(m), MapSet.new(), fn {row, col}, elves ->
      cond do
      !is_elf(m, row, col) ->
        elves
      !has_elves_around(m, row, col) ->
        elves
      true ->
        MapSet.put(elves, {row, col})
      end
    end)

    elves
  end

  def is_elf(m, row, col) do
    MapSet.member?(m, {row, col})
  end

  def has_elves_around(m, row, col) do
    nb = Enum.reduce([
      {row - 1, col - 1},
      {row - 1, col},
      {row - 1, col + 1},
      {row, col - 1},
      {row, col + 1},
      {row + 1, col - 1},
      {row + 1, col},
      {row + 1, col + 1},
    ], 0, fn {row, col}, nb -> if is_elf(m, row, col), do: nb + 1, else: nb end)

    nb > 0
  end

  def print(m) do
    {rows, cols} = {10, 10}

    Enum.each(0..rows-1, fn row ->
      cs = Enum.reduce(0..cols-1, [], fn col, l ->
        if MapSet.member?(m, {row, col}) do
          l ++ [?#]
        else
          l ++ [?.]
        end
      end)
      IO.puts(to_string(cs))
    end)
  end

  def read(fname) do

    m = MapSet.new()

    {m, _row} = fname
    |> File.stream!()
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Enum.reduce({m, 0}, fn l, {m, row} ->
      {m, _col} = to_charlist(l)
      |> Enum.reduce({m, 0}, fn c, {m, col} ->
        if c == ?# do
          m = MapSet.put(m, {row, col})
          {m, col + 1}
        else
          {m, col + 1}
        end
      end)
      {m, row + 1}
    end)

    m
  end

end
