defmodule D25 do

  # D25.solve("input/d25/example.txt")
  # D25.solve("input/d25/input.txt")
  def solve(fname) do

    num = fname
    |> File.stream!()
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Stream.map(&from_snafu/1)
    # |> Stream.run()
    |> Enum.sum()

    to_snafu(num)

  end

  def from_snafu(s) do
    s = String.reverse(s)

    {l, _idx} = Enum.map(to_charlist(s), fn c ->
      case c do
        ?= -> -2
        ?- -> -1
        ?0 -> 0
        ?1 -> 1
        ?2 -> 2
      end
    end)
    |> Enum.reduce(
     {[], 0},
      fn c, {l, i} ->
        l = l ++ [{c, i}]
        {l, i+1}
      end
    )

    l
    |> Enum.reduce(0, fn {v, p}, acc ->
      acc + v * (5 ** p)
    end)

  end

  def to_snafu(num) do

    {l, _v} = Stream.iterate(0, &(&1+1))
    |> Enum.reduce_while(
      {[], num},
      fn _idx, {l, num} ->
        d = trunc(num/5)
        r = rem(num, 5)
        l = l ++ [r]
        if d != 0 do
          {:cont, {l, d}}
        else
          {:halt, {l, d}}
        end
      end
    )

    {l, carry} = l
    |> Enum.reduce(
      {[], 0},
      fn v, {l, carry} ->
        v = v + carry
        {c, carry} = case v do
          0 -> {?0, 0}
          1 -> {?1, 0}
          2 -> {?2, 0}
          3 -> {?=, 1}
          4 -> {?-, 1}
          5 -> {?0, 1}
        end
        {l ++ [c], carry}
      end
    )
    l = if carry == 0 do
      l
    else
      l ++ [?0 + carry]
    end

    l = l
    |> Enum.reduce([], fn v, l -> [v] ++ l end)

    to_string(l)

  end

end
