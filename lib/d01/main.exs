defmodule Foo do

  def parse(s) when is_binary(s) do
    case Integer.parse(s) do
      {i, ""} ->
        i
      _ ->
        :nil
    end
  end

  def sum(val, cur) do
    case val do
      :nil ->
        {[cur], 0}
      val ->
        if val > 0 do
          {[:nil], cur + val}
        else
          {:halt, cur}
        end
    end
  end

end

"input.txt"
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&Foo.parse/1)
  |> Stream.transform(0, &Foo.sum/2)
  |> Stream.filter(fn x -> x != nil end)
  |> Enum.to_list()
  |> Enum.sort(:desc)
  |> Enum.take(3)
  |> Enum.sum()
  |> IO.puts()
