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
|> Stream.map(&(String.split_at(&1, trunc(String.length(&1)/2))))
|> Stream.map(&Tuple.to_list/1)
|> Stream.map(&(String.myers_difference(List.first(&1), List.last(&1))))
|> Stream.map(&(Enum.into(&1, %{})[:eq]))
|> Stream.map(&:binary.first/1)
|> Stream.map(&Rucksack.priority/1)
|> Stream.scan(0, &(&1 + &2))
|> Stream.take(-1)
|> Stream.map(&IO.inspect/1)
|> Stream.run()
