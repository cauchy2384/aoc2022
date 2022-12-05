defmodule Rucksack do

  def priority(i) do
    if i >= 0x61 do
      i - 0x61 + 1
    else
      i - 0x41 + 27
    end
  end

end

"input.txt"
|> File.stream!()
|> Stream.map(&(String.replace(&1, "\n", "")))
|> Stream.map(&String.graphemes/1)
|> Stream.chunk_every(3)
|> Stream.map(fn l ->
  e = hd(l)
  Enum.map(
    Enum.filter(l, fn el -> e != el end),
    fn i -> MapSet.intersection(MapSet.new(i), MapSet.new(e)) end
  )
  end
)
|> Stream.map(fn l ->
  e = hd(l)
  Enum.map(
    Enum.filter(l, fn el -> e != el end),
    fn i -> MapSet.intersection(i, e) end
  )
  end
)
|> Stream.map(&(hd(&1)))
|> Stream.map(&hd(MapSet.to_list(&1)))
|> Stream.map(&:binary.first/1)
|> Stream.map(&Rucksack.priority/1)
|> Stream.scan(0, &(&1 + &2))
|> Stream.take(-1)
|> Stream.map(&IO.inspect/1)
|> Stream.run()
