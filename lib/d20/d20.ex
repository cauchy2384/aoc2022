defmodule D20 do

  # D20.solve("input/d20/example.txt")
  def solve(fname, mult \\ 811589153, mixes \\ 10) do

    {q, _idx} = fname
    |> File.stream!()
    |> Enum.map(&(String.replace(&1, "\n", "")))
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce({[], 0}, fn v, {l, i} ->
      v = v * mult
      {l ++ [{v, i + 1}], i + 1}
    end)

    # print(q)
    old_q = q

    q = Enum.reduce(1..mixes, q, fn _mix, q ->
      {q, _} = Enum.reduce(old_q, {q, 0}, fn {v, idx}, {l, i} ->
        i = i + 1
        # IO.puts(i)
        delta = rem(v, length(q) - 1)
        {move(l, {v, idx}, delta), i}
      end)
      print(q)
      q
    end)

    IO.puts("")
    print(q)

    i = Enum.find_index(q, fn {v, _idx} -> v == 0 end)
    IO.inspect([0, "at", i])

    Enum.reduce(1..3, 0, fn n, acc ->
      idx = rem(i + n * 1000, length(q))
      {v, _idx} = Enum.at(q, idx)
      IO.inspect([n*1000, v])
      acc + v
    end)

  end

  def move(q, {_v, _idx}, delta) when delta == 0 do
    # IO.puts("0 does not move:")
    # print(q)
    q
  end

  def move(q, {v, idx}, delta) when delta < 0 do
    move(q, {v, idx}, (length(q) - 1) + delta)
  end

  def move(q, {v, idx}, delta) do
    # i = Enum.find_index(q, fn x -> x == v end)

    # {q, _i} = if delta > 0 do
    #   Enum.reduce(1..delta, {q, i}, fn _i, {q, i} ->
    #     { swap(q, i, i+1), i + 1 }
    #   end)
    # else
    #   Enum.reduce(1..abs(delta), {q, i}, fn _i, {q, i} ->
    #     { swap(q, i, i-1), i - 1 }
    #   end)
    # end
    # q

    i = Enum.find_index(q, fn x -> x == {v, idx} end)
    i2 = rem(i + delta, length(q))

    # {l, _idx} = Enum.at(q, i2)
    # {r, _idx} = Enum.at(q, rem(i2+1, length(q)))
    # IO.puts("")
    # IO.puts("#{v} moves between #{l} and #{r}:")
    # IO.puts("from #{i} to #{i2}, delta is #{delta}")
    # print(q)

    q = List.update_at(q, i, fn _x -> {nil, nil} end)
    # print(q)
    q = List.insert_at(q, i2+1, {v, idx})
    # print(q)
    q = List.delete(q, {nil, nil})
    # print(q)
    q
  end

  def move_right(q) do
    Enum.reduce(0..length(q) - 1, [], fn i, l ->
      v = Enum.at(q, i-1)
      l ++ [v]
    end)
  end

  def swap(q, i, j) do
    i = rem(i, length(q))
    j = rem(j, length(q))

    vi = Enum.at(q, i)
    vj = Enum.at(q, j)

    q = List.update_at(q, i, fn _x -> vj end)
    q = List.update_at(q, j, fn _x -> vi end)

    q
  end

  def print(q) do
    q = Enum.map(q, fn {v, _idx} -> v end)
    IO.inspect(q)
  end

end
