defmodule Cleanup do
  def overlap(pair) do
    [first, second] = pair
    [a, b] = first
    [x, y] = second
    cond do
      a <= x and b >= y ->
        1
      x <= a and y >= b ->
        1
      true ->
        0
    end
  end
end

"input.txt"
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.map(&(String.replace(&1, "\n", "")))
|> Stream.map(&(String.split(&1, ",")))
|> Stream.map(fn l -> Enum.map(l, &(String.split(&1,"-"))) end)
|> Stream.map(fn l -> Enum.map(l,
  fn ll -> Enum.map(ll,
    fn s ->
      {d, _} = Integer.parse(s)
      d
    end)
  end)
end)
|> Stream.map(&Cleanup.overlap/1)
|> Stream.scan(&(&1 + &2))
|> Stream.take(-1)
|> Stream.map(&IO.inspect/1)
|> Stream.run()
