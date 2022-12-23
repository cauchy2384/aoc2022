defmodule D22p2 do

  require Matrix

  def rotate(m) do
    {rows, cols} = Matrix.size(m)

    m2 = Matrix.new(rows, cols, ?.)

    Enum.reduce(0..rows - 1, m2, fn row, m2 ->
      Enum.reduce(0..cols - 1, m2, fn col, m2 ->
        el = Matrix.elem(m, row, col)
        Matrix.set(m2, col, cols - 1 - row, el)
      end)
    end)
  end

  # D22p2.solve("input/d22/example.txt")
  def solve(fname, size \\ 4) do
    ms = read_labirynth(fname, size)
    # ms = rotate_lab(ms, size)

    cmds = read_commands(fname)

    {mi, ms, {row, col}, dir} = run(ms, cmds, size)

    ms = matrix_set(mi, ms, row, col, ?K)

    # ms = rotate_back(ms, size)
    print_ms(ms, size)

    # Enum.each(ms, fn m ->
    #   Enum.each(0..size - 1, fn row ->
    #     Enum.each(0..size - 1, fn col ->
    #       c = Matrix.elem(m, row, col)
    #       if c == ?K do
    #         IO.inspect(m_to_mi(size, 3, row, col))
    #       end
    #     end)
    #   end)
    # end)

    IO.inspect([mi, row, col, dir])

    score(mi, row, col, dir, size)
    # {136, 11}
    # score(mi, 136, 11, :left, size)
  end

  # def rotate_lab(ms, 4) do
  #   ms
  # end

  # def rotate_lab(ms, _size) do
  #   ms2 = ms

  #   m = Enum.at(ms, 1)
  #   m = rotate(rotate(m))
  #   ms2 = List.replace_at(ms2, 5, m)

  #   m = Enum.at(ms, 2)
  #   ms2 = List.replace_at(ms2, 3, m)

  #   m = Enum.at(ms, 3)
  #   m = rotate(rotate(rotate(m)))
  #   ms2 = List.replace_at(ms2, 2, m)

  #   m = Enum.at(ms, 5)
  #   m = rotate(rotate(rotate(m)))
  #   ms2 = List.replace_at(ms2, 1, m)

  #   ms2
  # end

  # def rotate_back(ms, 4) do
  #   ms
  # end

  # def rotate_back(ms, _size) do
  #   ms2 = ms

  #   m = Enum.at(ms, 5)
  #   m = rotate(rotate(m))
  #   ms2 = List.replace_at(ms2, 1, m)

  #   m = Enum.at(ms, 3)
  #   ms2 = List.replace_at(ms2, 2, m)

  #   m = Enum.at(ms, 2)
  #   m = rotate(m)
  #   ms2 = List.replace_at(ms2, 3, m)

  #   m = Enum.at(ms, 1)
  #   m = rotate(m)
  #   ms2 = List.replace_at(ms2, 5, m)

  #   ms2
  # end

  def score(mi, row, col, dir, size) do
    {row, col} = m_to_mi(size, mi, row, col)
    score = (row + 1) * 1000 + (col + 1) * 4
    case dir do
      :right -> score
      :down -> score + 1
      :left -> score + 2
      :up -> score + 3
    end
  end

  def run(ms, cmds, size)  do
    {mi, row, col} = start()
    sym = symbol(:right)

    ms = matrix_set(mi, ms, row, col, sym)

    IO.puts("start at #{mi} [#{row}, #{col}]")
    # print(m)

    # cmds = Enum.take(cmds, 13)

    Enum.reduce(cmds, {mi, ms, {row, col}, :right}, fn cmd, {mi, ms, pos, dir} ->
      {mi, ms, pos, dir} = exec(mi, ms, pos, dir, cmd, size)

      # {row, col} = pos
      # IO.puts("now at: [#{row}, #{col}], looking #{dir}")
      # print(m)

      {mi, ms, pos, dir}
    end)
  end

  def exec(mi, ms, {row, col}, dir, cmd, size) do

    # print_ms(ms, size)
    # IO.inspect(cmd)
    cond do
      cmd == "R" ->
        dir = rotate_right(dir)
        sym = symbol(dir)
        ms = matrix_set(mi, ms, row, col, sym)
        {mi, ms, {row, col}, dir}
      cmd == "L" ->
        dir = rotate_left(dir)
        sym = symbol(dir)
        ms = matrix_set(mi, ms, row, col, sym)
        {mi, ms, {row, col}, dir}
      true ->
        move(mi, ms, {row, col}, dir, size, String.to_integer(cmd))
    end
  end

  def move(mi, ms, {row, col}, dir, size, steps) do

    {mi, ms, row, col, dir} = Enum.reduce_while(
      1..steps,
      {mi, ms, row, col, dir},
      fn _i, {prev_mi, ms, prev_row, prev_col, prev_dir} ->
        # print_ms(ms, size)
        {c, mi, row, col, dir} = matrix_elem(prev_mi, ms, prev_row, prev_col, prev_dir, size)
        # IO.inspect([mi, row, col, dir])
        cond do
          c == ?# ->
            {:halt, {prev_mi, ms, prev_row, prev_col, prev_dir}}
          true ->
            sym = symbol(dir)
            ms = matrix_set(mi, ms, row, col, sym)
            {:cont, {mi, ms, row, col, dir}}
        end
      end
    )

    {mi, ms, {row, col}, dir}
  end

  def matrix_elem(mi, ms, row, col, dir, size) when dir == :right or dir == :down do
    _matrix_elem(mi, ms, row, col, dir, size, 1)
  end

  def matrix_elem(mi, ms, row, col, dir, size) when dir == :left or dir == :up do
    _matrix_elem(mi, ms, row, col, dir, size, -1)
  end

  def _matrix_elem(mi, ms, row, col, dir, size, delta) do

    # IO.inspect({row, col, dir, size, delta})
    if dir == :right or dir == :left do
      col = col + delta
      {mi, row, col, dir} = next_mi(mi, row, col, dir, size)
      c = matrix_elem(mi, ms, row, col)
      {c, mi, row, col, dir}
    else
      row = row + delta
      {mi, row, col, dir} = next_mi(mi, row, col, dir, size)
      c = matrix_elem(mi, ms, row, col)
      {c, mi, row, col, dir}
    end
  end


  def next_mi(mi, row, col, dir, size) when size == 4 do
    sz = size - 1
    # IO.inspect({"next", mi, row, col, dir})
    cond do
      (row >= 0 and row < size) and (col >= 0 and col < size) ->
        {mi, row, col, dir}

      mi == 0 ->
        cond do
          row < 0 -> {1, 0, sz - col, :down}
          row > sz -> {3, 0, col, :down}
          col > sz -> {5, sz - row, sz, :left}
          col < 0 -> {2, 0, row, :down}
        end

      mi == 1 ->
         cond do
          row < 0 -> {0, 0, sz - col, :down}
          row > sz -> {4, sz, sz - col, :up}
          col > sz -> {2, row, 0, :right}
          col < 0 -> {5, sz, sz - row, :up}
        end

      mi == 2 ->
         cond do
          row < 0 -> {0, col, 0, :right}
          row > sz -> {4, sz - col, 0, :right}
          col > sz -> {3, row, 0, :right}
          col < 0 -> {1, row, sz, :left}
        end

      mi == 3 ->
         cond do
          row < 0 -> {0, sz, col, :up}
          row > sz -> {4, 0, col, :down}
          col > sz -> {5, 0, sz - row, :down}
          col < 0 -> {2, row, sz, :left}
        end

      mi == 4 ->
         cond do
          row < 0 -> {3, sz, col, :up}
          row > sz -> {1, sz, sz - col, :up}
          col > sz -> {5, row, 0, :right}
          col < 0 -> {2, sz, sz - row, :up}
        end

      mi == 5 ->
         cond do
          row < 0 -> {3, sz - col, sz, :left}
          row > sz -> {1, sz - col, 0, :right}
          col > sz -> {0, sz - row, sz, :left}
          col < 0 -> {4, row, sz, :left}
        end


      true ->
        raise "ok #{mi}"
    end
  end

  def next_mi(mi, row, col, dir, size) when size == 50 do
    sz = size - 1
    # IO.inspect({"next", mi, row, col, dir})
    cond do
      (row >= 0 and row < size) and (col >= 0 and col < size) ->
        {mi, row, col, dir}

      mi == 0 ->
        cond do
          row < 0 -> {5, col, 0, :right}
          row > sz -> {2, 0, col, :down}
          col > sz -> {1, row, 0, :right}
          col < 0 -> {3, sz - row, 0, :right}
        end

      mi == 1 ->
         cond do
          row < 0 -> {5, sz, col, :up}
          row > sz -> {2, col, sz, :left}
          col > sz -> {4, sz - row, sz, :left}
          col < 0 -> {0, row, sz, :left}
        end

      mi == 2 ->
         cond do
          row < 0 -> {0, sz, col, :up}
          row > sz -> {4, 0, col, :down}
          col > sz -> {1, sz, row, :up}
          col < 0 -> {3, 0, row, :down}
        end

      mi == 3 ->
         cond do
          row < 0 -> {2, col, 0, :right}
          row > sz -> {5, 0, col, :down}
          col > sz -> {4, row, 0, :right}
          col < 0 -> {0, sz - row, 0, :right}
        end

      mi == 4 ->
         cond do
          row < 0 -> {2, sz, col, :up}
          row > sz -> {5, col, sz, :left}
          col > sz -> {1, sz - row, sz, :left}
          col < 0 -> {3, row, sz, :left}
        end

      mi == 5 ->
         cond do
          row < 0 -> {3, sz, col, :up}
          row > sz -> {1, 0, col, :down}
          col > sz -> {4, sz, row, :up}
          col < 0 -> {0, 0, row, :down}
        end


      true ->
        raise "ok #{mi}"
    end
  end

  def matrix_set(mi, ms, row, col, sym) do
    # IO.inspect({mi, ms, row, col, sym})
    m = Enum.at(ms, mi)
    m = Matrix.set(m, row, col, sym)
    ms = List.replace_at(ms, mi, m)
    ms
  end


  def matrix_elem(mi, ms, row, col) do
    m = Enum.at(ms, mi)
    Matrix.elem(m, row, col)
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

  def start() do
    {0, 0, 0}
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

  def print_ms(ms, size) do

    rows = 4 * size
    cols = 4 * size
    m = Matrix.new(rows, cols, 32)

    m = Enum.reduce(0..rows-1, m, fn row, m ->
      Enum.reduce(0..cols-1, m, fn col, m ->
        {mi, mrow, mcol} = mi_to_m(size, row, col)
        if mi == nil do
          m
        else
          el = matrix_elem(mi, ms, mrow, mcol)
          Matrix.set(m, row, col, el)
        end
      end)
    end)

    print(m)
  end

  def mi_to_m(size, row, col) when size == 4 do

    ri = trunc(row / size)
    ci = trunc(col / size)
    {row, col} = {rem(row, size), rem(col, size)}

    case {ri, ci} do
      {0, 2} -> {0, row, col}
      {1, 0} -> {1, row, col}
      {1, 1} -> {2, row, col}
      {1, 2} -> {3, row, col}
      {2, 2} -> {4, row, col}
      {2, 3} -> {5, row, col}
      _ -> {nil, nil, nil}
    end

  end

  def mi_to_m(size, row, col) do

    ri = trunc(row / size)
    ci = trunc(col / size)
    {row, col} = {rem(row, size), rem(col, size)}

    case {ri, ci} do
      {0, 1} -> {0, row, col}
      {0, 2} -> {1, row, col}
      {1, 1} -> {2, row, col}
      {2, 0} -> {3, row, col}
      {2, 1} -> {4, row, col}
      {3, 0} -> {5, row, col}
      _ -> {nil, nil, nil}
    end
  end

  def m_to_mi(size, mi, row, col) when size == 4 do
    case mi do
      0 -> {row, col + size*2}
      1 -> {row + size*1, col}
      2 -> {row + size*1, col + size*1}
      3 -> {row + size*1, col + size*2}
      4 -> {row + size*2, col + size*2}
      5 -> {row + size*2, col + size*3}
      _ -> {nil, nil}
    end
  end

  def m_to_mi(size, mi, row, col) do
    case mi do
      0 -> {row, col + size*1}
      1 -> {row, col + size*2}
      2 -> {row + size*1, col + size*1}
      3 -> {row + size*2, col}
      4 -> {row + size*2, col + size*1}
      5 -> {row + size*3, col}
      _ -> {nil, nil}
    end
  end

  def read_labirynth(fname, size) do

    chunks = fname
    |> File.stream!()
    |> Enum.map(&(String.replace(&1, "\n", "")))
    |> Enum.map(&String.trim/1)
    |> Enum.take_while(&(&1 != ""))
    |> Enum.chunk_every(size)

    list = Enum.at(chunks, 0)

    list = Enum.reduce(
      1..length(chunks) -1,
      list,
      fn i, list ->
        chunk = Enum.at(chunks, i)
        {list, _j} = Enum.reduce(chunk, {list, 0}, fn l, {list, j} ->
          ll = Enum.at(list, j)
          ll = "#{ll}#{l}"
          list = List.replace_at(list, j, ll)
          {list, j+1}
        end)
        list
      end
    )

    list = Enum.map(list, fn line -> Enum.chunk_every(to_charlist(line), size) end)
    # IO.inspect(list)

    list = Enum.reduce(0..size - 1, [], fn num, ll ->
      row = Enum.at(list, num)
      if num == 0 do
        row |> Enum.map(fn l -> [l] end)
      else
        {ll, _j} = Enum.reduce(row, {ll, 0}, fn s, {ll, idx} ->
          s2 = Enum.at(ll, idx)
          ll = List.replace_at(ll, idx, s2 ++ [s])
          {ll, idx+1}
        end)
        ll
      end
    end)
    # IO.inspect(list)

    ms = Enum.reduce(list, [], fn ll, ms ->
      {m, _row} = Enum.reduce(ll, {Matrix.new(size, size), 0}, fn line, {m, row} ->
        {m, _col} = to_charlist(line)
        |> Enum.reduce({m, 0}, fn c, {m, col} ->
          m = Matrix.set(m, row, col, c)
          {m, col + 1}
        end)
        {m, row + 1}
      end)

      ms ++ [m]
    end)

    ms
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
