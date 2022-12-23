defmodule D22 do

  require Matrix

  # D22.solve("input/d22/example.txt")
  def solve(fname) do
    m = read_labirynth(fname)
    cmds = read_commands(fname)

    # cmds = [Enum.at(cmds, 0)]
    {m, {row, col}, dir} = run(m, cmds)

    print(m)
    score(row, col, dir)
  end

  def score(row, col, dir) do
    score = (row + 1) * 1000 + (col + 1) * 4
    case dir do
      :right -> score
      :down -> score + 1
      :left -> score + 2
      :up -> score + 3
    end
  end

  def run(m, cmds)  do
    {row, col} = start(m)
    sym = symbol(:right)
    m = Matrix.set(m, row, col, sym)

    # IO.puts("start at [#{row}, #{col}]")
    # print(m)

    # cmds = Enum.take(cmds, 5)

    Enum.reduce(cmds, {m, {row, col}, :right}, fn cmd, {m, pos, dir} ->
      {m, pos, dir} = exec(m, pos, dir, cmd)

      # {row, col} = pos
      # IO.puts("now at: [#{row}, #{col}], looking #{dir}")
      # print(m)

      {m, pos, dir}
    end)
  end

  def exec(m, {row, col}, dir, cmd) do

    # IO.inspect(cmd)
    cond do
      cmd == "R" ->
        dir = rotate_right(dir)
        sym = symbol(dir)
        m = Matrix.set(m, row, col, sym)
        {m, {row, col}, dir}
      cmd == "L" ->
        dir = rotate_left(dir)
        sym = symbol(dir)
        m = Matrix.set(m, row, col, sym)
        {m, {row, col}, dir}
      true ->
        move(m, {row, col}, dir, String.to_integer(cmd))
    end
  end

  def move(m, {row, col}, dir, steps) do

    sym = symbol(dir)

    case dir do
      :right ->
        {m, col} = Enum.reduce_while(1..steps, {m, col}, fn _i, {m, prev_col} ->
          {c, _row, col} = matrix_elem_col(m, row, prev_col, 1)
          cond do
            c == ?# ->
              {:halt, {m, prev_col}}
            true ->
              m = Matrix.set(m, row, col, sym)
              {:cont, {m, col}}
          end
        end)
        {m, {row, col}, dir}

      :down ->
        {m, row} = Enum.reduce_while(1..steps, {m, row}, fn _i, {m, prev_row} ->
          {c, row, _col} = matrix_elem_row(m, prev_row, col, 1)
          cond do
            c == ?# ->
              {:halt, {m, prev_row}}
            true ->
              m = Matrix.set(m, row, col, sym)
              {:cont, {m, row}}
          end
        end)
        {m, {row, col}, dir}

        :left ->
          {m, col} = Enum.reduce_while(1..steps, {m, col}, fn _i, {m, prev_col} ->
            {c, _row, col} = matrix_elem_col(m, row, prev_col, - 1)
            cond do
              c == ?# ->
                {:halt, {m, prev_col}}
              true ->
                m = Matrix.set(m, row, col, sym)
                {:cont, {m, col}}
            end
          end)
          {m, {row, col}, dir}

        :up ->
          {m, row} = Enum.reduce_while(1..steps, {m, row}, fn _i, {m, prev_row} ->
            {c, row, _col} = matrix_elem_row(m, prev_row, col, -1)
            IO.inspect([row, col, c])
            cond do
              c == ?# ->
                {:halt, {m, prev_row}}
              true ->
                m = Matrix.set(m, row, col, sym)
                {:cont, {m, row}}
            end
          end)
          {m, {row, col}, dir}
    end
  end

  def matrix_elem_col(m, row, col, delta) do
    col = col + delta

    {_rows, cols} = Matrix.size(m)
    {c, col} = Enum.reduce_while(1..cols, {0, col}, fn _i, {_c, col} ->
      col = rem(col + cols, cols)
      c = Matrix.elem(m, row, col)
      if c == 32 do
        {:cont, {c, col + delta}}
      else
        {:halt, {c, col}}
      end
    end)

    {c, row, col}
  end

  def matrix_elem_row(m, row, col, delta) do
    row = row + delta

    {rows, _cols} = Matrix.size(m)
    {c, row} = Enum.reduce_while(1..rows, {0, row}, fn _i, {_c, row} ->
      row = rem(row + rows, rows)
      c = Matrix.elem(m, row, col)
      if c == 32 do
        {:cont, {c, row + delta}}
      else
        {:halt, {c, row}}
      end
    end)

    {c, row, col}
  end

  def symbol(dir) do
    case dir do
      :right -> ?>
      :left -> ?<
      :up -> ?^
      :down -> ?v
    end
  end

  def rotate_right(dir) do
    rotate(dir, [:right, :down, :left, :up])
  end

  def rotate_left(dir) do
    rotate(dir, [:right, :up, :left, :down])
  end

  def rotate(dir, dirs) do
    idx = Enum.find_index(dirs, fn x -> x == dir end)
    idx = rem(idx + 1, length(dirs))

    Enum.at(dirs, idx)
  end

  def start(m) do
    {_rows, cols} = Matrix.size(m)
    col = Enum.reduce_while(0..cols-1, 0, fn col, v ->
      if Matrix.elem(m, 0, col) == 32 do
        {:cont, v+1}
      else
        {:halt, v}
      end
    end)

    {0, col}
  end

  def print(m) do
    {rows, cols} = Matrix.size(m)
    Enum.each(0..rows-1, fn row ->
      s = Enum.reduce(0..cols-1, [], fn col, s ->
        s ++ [Matrix.elem(m, row, col)]
      end)
      IO.puts(to_string(s))
    end)
  end

  def read_labirynth(fname) do

    lines = fname
    |> File.stream!()
    |> Enum.map(&(String.replace(&1, "\n", "")))
    |> Enum.take_while(&(&1 != ""))

    rows = length(lines)
    cols = Enum.reduce(lines, 0, fn l, acc -> if String.length(l) > acc, do: String.length(l), else: acc end)

    m = Matrix.new(rows, cols, 32)

    {m, _row} = Enum.reduce(lines, {m, 0}, fn l, {m, row} ->
      {m, _col} = Enum.reduce(to_charlist(l), {m, 0}, fn c, {m, col} ->
        m = Matrix.set(m, row, col, c)
        {m, col + 1}
      end)
      {m, row + 1}
    end)

    m

  end

  def read_commands(fname) do
    [line] = fname
    |> File.stream!()
    |> Enum.map(&(String.replace(&1, "\n", "")))
    |> Enum.take(-1)

    Enum.reduce(to_charlist(line), [], fn c, l ->
      cond do
        length(l) == 0 ->
          l ++ [[c]]
        c == ?R or c == ?L ->
          l ++ [[c]] ++ [[]]
        true ->
          idx = length(l) - 1
          last = Enum.at(l, idx)
          last = last ++ [c]
          List.replace_at(l, idx, last)
      end
    end)
    |> Enum.map(fn l -> to_string(l) end)
    |> Enum.filter(&(&1 != ""))
  end

end
