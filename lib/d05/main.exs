defmodule Stack do

  def push(stack, v) do
    [v] ++ stack
  end

  def pop(stack) do
    { tl(stack), hd(stack) }
  end

end

[fname] = System.argv()

stacks = fname
|> File.stream!()
|> Stream.map(&(String.replace(&1, "\n", "")))
|> Stream.take_while(&(!String.contains?(&1, "1")))
|> Stream.map(fn l ->
  String.graphemes(l)
  |> Enum.chunk_every(4)
  |> Enum.map(&(Enum.at(&1, 1)))
  |> Enum.map(fn c ->
    if c == " " do nil else c end
  end)
  |> Enum.to_list()
end)
|> Enum.to_list()
|> List.zip
|> Enum.map(&Tuple.to_list/1)
|> Enum.map(fn l -> Enum.filter(l, &(&1 != nil)) end)

fname
|> File.stream!()
|> Stream.map(&(String.replace(&1, "\n", "")))
|> Stream.drop_while(&(&1 != ""))
|> Stream.drop(1)
|> Stream.map(&(String.split(&1, " ")))
|> Stream.map(&(Enum.drop_every(&1, 2)))
|> Stream.map(fn l -> Enum.map(l, &String.to_integer/1) end)
|> Stream.map(fn [move, from, to] -> [move, from - 1, to - 1] end)
|> Stream.scan(stacks, fn [move, from, to], stacks ->
  stack_from = Enum.at(stacks, from)
  stack_to = Enum.at(stacks, to)

  [{stack_from, stack_to}] = Enum.scan(1..move, {stack_from, stack_to}, fn _, {stack_from, stack_to} ->
    {stack_from, v} = Stack.pop(stack_from)
    stack_to = Stack.push(stack_to, v)
    {stack_from, stack_to}
  end)
  |> Enum.take(-1)

  stacks = Enum.with_index(stacks)
    |> Enum.map(fn {stack, idx} ->
      case idx do
        ^from -> stack_from
        ^to -> stack_to
        _ -> stack
      end
    end)

  stacks
end)
|> Stream.take(-1)
|> Stream.map(&(Enum.map(&1, fn l ->
  hd(l)
end)))
|> Stream.map(&to_string/1)
|> Stream.map(&IO.inspect/1)
|> Stream.run()
