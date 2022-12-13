defmodule D13 do

  def solve(fname) do

    fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.chunk_every(2)
    |> Stream.map(fn [l, r] -> normalize(l,r) end)
    |> Stream.map(fn {l, r} -> compare(l,r) end)
    |> Stream.filter(&(&1 != 0))
    |> Stream.map(fn v -> if v == -1, do: 0, else: v end)
    |> Stream.with_index()
    |> Stream.filter(fn {v, _idx} -> v != 0 end)
    |> Stream.map(fn {_, idx} -> idx + 1 end)
    |> Stream.scan(0, &(&1 + &2))
    |> Stream.take(-1)
    |> Stream.each(&IO.inspect/1)
    |> Stream.run()

  end

  def solve2(fname) do

    list = fname
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn s -> normalize(s) end)
    |> Enum.to_list()

    list = list ++ [ [[2]] ] ++ [ [[6]] ]

    list
    |> Enum.sort(fn l, r -> compare(l,r) == 1 end)
    |> Enum.with_index()
    |> Enum.filter(fn {v, _idx} ->
      case v do
        [[2]] -> true
        [[6]] -> true
        v != 0
        _ -> false
      end
    end)
    |> Enum.map(fn {_, idx} -> idx + 1 end)
    |> Enum.scan(1, &(&1 * &2))
    |> Enum.take(-1)
    |> Enum.each(&IO.inspect/1)

  end

  def normalize(l) do
    {l, _} = Code.eval_string(l)
    l
  end

  def normalize(l, r) do
    {l, _} = Code.eval_string(l)
    {r, _} = Code.eval_string(r)
    {l, r}
  end

  def compare(l, r) when is_integer(l) and is_integer(r) do
    cond do
      l < r -> 1
      l == r -> 0
      true -> -1
    end
  end

  def compare(l, r) when is_integer(l), do: compare([l], r)
  def compare(l, r) when is_integer(r), do: compare(l, [r])

  def compare(l, r) when is_nil(l) and is_nil(r), do: 0
  def compare(l, _r) when is_nil(l), do: 1
  def compare(_l, r) when is_nil(r), do: -1

  def compare(l, r) do
    max = Enum.max([length(l), length(r)])

    eqs = Enum.map(0..max, fn idx ->
      compare(Enum.at(l, idx), Enum.at(r, idx))
    end)
    |> Enum.drop_while(&(&1 == 0))
    |> Enum.take(1)

    if length(eqs) == 0 do
      0
    else
      [eq] = eqs
      eq
    end
  end

end
