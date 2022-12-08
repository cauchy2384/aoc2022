defmodule D08 do

  require Matrix

  def solve(fname) do

    [{cols, rows}] = get_size(fname)

    mx = parse_matrix(fname, rows, cols)

    # number of trees
    Enum.scan(0..rows-1, 0, fn row, acc ->
      [ acc ] = Enum.scan(0..cols-1, acc, fn col, acc ->
        if is_visible(mx, row, col), do: acc + 1, else: acc
      end)
      |> Enum.take(-1)
      acc
    end)
    |> Enum.take(-1)
    |> Enum.each(&IO.inspect/1)

  end

  def solve2(fname) do

    [{cols, rows}] = get_size(fname)

    mx = parse_matrix(fname, rows, cols)

    # score of trees
    Enum.map(0..rows-1, fn row ->
      Enum.map(0..cols-1, fn col -> score(mx, row, col) end)
      |> Enum.max()
    end)
    |> Enum.max()

  end

  def get_size(fname) do
    fname
    |> File.stream!()
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Stream.map(&String.trim/1)
    |> Stream.scan({0, 0}, fn line, { _, size_y} -> { String.length(line), size_y + 1 } end)
    |> Stream.take(-1)
    |> Enum.to_list()
  end

  def parse_matrix(fname, rows, cols) do
    [{ mx, _ }] = fname
    |> File.stream!()
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Stream.map(&String.trim/1)
    |> Stream.scan({ Matrix.new(rows, cols), 0}, fn line, { mx, row } ->
      [{ mx, _ }] = line
      |> to_charlist()
      |> Enum.map(&(String.to_integer(to_string([&1]))))
      |> Enum.scan({mx, 0}, fn c, { mx, col } ->
        { Matrix.set(mx, row, col, c), col + 1 }
      end)
      |> Enum.take(-1)
      { mx, row + 1}
    end)
    |> Stream.take(-1)
    |> Enum.to_list()

    mx
  end

  def is_visible(_, row, col) when row == 0 or col == 0 do
    true
  end

  def is_visible(mx, row, col) do
    {rows, cols} = Matrix.size(mx)

    cond do
      row == rows - 1 -> true
      col == cols - 1-> true
      is_visible_left(mx, row, col) -> true
      is_visible_right(mx, row, col) -> true
      is_visible_top(mx, row, col) -> true
      is_visible_bottom(mx, row, col) -> true
      true -> false
    end
  end

  def is_visible_left(mx, row, col) do
    v = Matrix.elem(mx, row, col)
    higher = Enum.drop_while(0..col - 1, fn c ->
      Matrix.elem(mx, row, c) < v
    end) |> Enum.take(-1) |> Enum.to_list()
    length(higher) == 0
  end

  def is_visible_right(mx, row, col) do
    {_, cols} = Matrix.size(mx)
    v = Matrix.elem(mx, row, col)
    higher = Enum.drop_while(col + 1..cols - 1, fn c ->
      Matrix.elem(mx, row, c) < v
    end) |> Enum.take(-1) |> Enum.to_list()
    length(higher) == 0
  end

  def is_visible_top(mx, row, col) do
    v = Matrix.elem(mx, row, col)
    higher = Enum.drop_while(0..row - 1, fn r ->
      Matrix.elem(mx, r, col) < v
    end) |> Enum.take(-1) |> Enum.to_list()
    length(higher) == 0
  end

  def is_visible_bottom(mx, row, col) do
    {rows, _} = Matrix.size(mx)
    v = Matrix.elem(mx, row, col)
    higher = Enum.drop_while(row + 1..rows - 1, fn r ->
      Matrix.elem(mx, r, col) < v
    end) |> Enum.take(-1) |> Enum.to_list()
    length(higher) == 0
  end

  def score(mx, row, col) do
    {rows, cols} = Matrix.size(mx)

    cond do
      row == rows - 1 -> 0
      col == cols - 1-> 0
      true ->
        vl = visible_left(mx, row, col)
        vr = visible_right(mx, row, col)
        vt = visible_top(mx, row, col)
        vb = visible_bottom(mx, row, col)
        score = vl * vr * vt * vb

        score
    end
  end

  def visible_left(_, _, col) when col == 0 do
    0
  end

  def visible_left(mx, row, col) do
    v = Matrix.elem(mx, row, col)

    cnt = Enum.take_while(col-1..0, fn c ->
      Matrix.elem(mx, row, c) < v
    end)
    |> Enum.count()

    if cnt == col, do: cnt, else: cnt + 1
  end

  def visible_right(mx, row, col) do
    v = Matrix.elem(mx, row, col)
    {_, cols} = Matrix.size(mx)

    cnt = Enum.take_while(col+1..cols-1, fn c ->
      Matrix.elem(mx, row, c) < v
    end)
    |> Enum.count()

    cond do
      col == cols - 1 -> 0
      cnt == (cols - 1) - col -> cnt
      true -> cnt + 1
    end
  end

  def visible_top(_, row, _) when row == 0 do
    0
  end

  def visible_top(mx, row, col) do
    v = Matrix.elem(mx, row, col)

    cnt = Enum.take_while(row-1..0, fn r ->
      Matrix.elem(mx, r, col) < v
    end)
    |> Enum.count()

    if cnt == row, do: cnt, else: cnt + 1
  end

  def visible_bottom(mx, row, col) do
    v = Matrix.elem(mx, row, col)
    {rows, _} = Matrix.size(mx)

    cnt = Enum.take_while(row+1..rows-1, fn r ->
      Matrix.elem(mx, r, col) < v
    end)
    |> Enum.count()

    cond do
      row == rows - 1 -> 0
      cnt == (rows - 1) - row -> cnt
      true -> cnt + 1
    end
  end

end
