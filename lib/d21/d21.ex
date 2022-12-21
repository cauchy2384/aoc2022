defmodule D21 do

  # D21.solve("input/d21/example.txt")
  def solve(fname) do

    {numbers, _operations} = fname
    |> File.stream!()
    |> Enum.map(&(String.replace(&1, "\n", "")))
    |> Enum.map(&parse/1)
    |> Enum.map(&IO.inspect/1)
    |> Enum.reduce({Map.new(), Map.new()}, fn {monkey, v, type}, {numbers, operations} ->
      case type do
        :number ->
          numbers = Map.put(numbers, monkey, v)

          Stream.iterate(0, &(&1+1))
          |> Enum.reduce_while(
            {numbers, operations},
            fn _idx, {numbers, operations} ->
              {{numbers, operations}, ops} = calculate(numbers, operations)
              if ops == 0 do
                {:halt, {numbers, operations}}
              else
                {:cont, {numbers, operations}}
              end
            end)

        :math ->
          ss = String.split(v, " ")
          [l, r] = [Enum.at(ss, 0), Enum.at(ss, 2)]
          operations = Map.put(operations, monkey, {v, [l, r]})
          {numbers, operations}
      end
    end)

    Map.get(numbers, "root")

  end

# D21.solve2("input/d21/example.txt")

  def solve2(fname) do

    op = desctruct(fname)
    IO.inspect(op)

    Stream.iterate(3910938071000, &(&1 + 1))
    |> Enum.reduce_while(nil, fn v, res ->
      cond do
      # v > 0 -> {:halt, 0}
      true ->
        op = String.replace(op, "humn", to_string(v))
        {eq, _bind} = Code.eval_string(op)
        IO.inspect([v, eq])
        if eq < 0 do
          {:halt, v}
        else
          # s
          {:cont, res}
        end
      end
    end)

  end

  def desctruct(fname) do

    numbers = Map.put(Map.new(), "humn", "humn")

    {numbers, operations} = fname
    |> File.stream!()
    |> Enum.map(&(String.replace(&1, "\n", "")))
    |> Enum.map(&parse/1)
    |> Enum.filter(fn {monkey, _v, _type} -> monkey != "humn" end)
    |> Enum.map(fn {monkey, v, type} ->
      if monkey != "root" do
        {monkey, v, type}
      else
        ss = String.split(v, " ")
        v = "#{Enum.at(ss, 0)} - #{Enum.at(ss, 2)}"
        {monkey, v, type}
      end
    end)
    # |> Enum.map(&IO.inspect/1)
    |> Enum.reduce({numbers, Map.new()},
      fn {monkey, v, type}, {numbers, operations} ->
      case type do
        :number ->
          numbers = Map.put(numbers, monkey, v)
          {numbers, operations}
        :math ->
          operations = Map.put(operations, monkey, v)
          {numbers, operations}
      end
    end)

    # IO.inspect([numbers, operations])

    {_numbers, operations} = Enum.reduce(
      Map.keys(numbers),
      {numbers, operations},
      fn monkey, {numbers, operations} ->

        v = Map.get(numbers, monkey)
        # IO.inspect([monkey ,v])

        operations = Enum.reduce(Map.keys(operations), operations, fn monkey2, operations ->
          op = Map.get(operations, monkey2)
          # IO.inspect([monkey2 ,op])
          op = String.replace(op, monkey, "(#{v})")
          # IO.inspect([monkey2 ,op])
          Map.put(operations, monkey2, op)
        end)

        numbers = Map.delete(numbers, monkey)

        {numbers, operations}
    end)

    # IO.inspect([_numbers, operations])

    operations = Stream.iterate(0, &(&1+1))
    |> Enum.reduce_while(operations, fn _idx, operations ->
      if map_size(operations) == 1 do
        {:halt, operations}
      else
        operations = Enum.reduce(Map.keys(operations), operations,
          fn monkey, operations ->
            v = Map.get(operations, monkey)

            # IO.puts("")
            # IO.inspect([monkey, v])
            # IO.inspect(operations)

            operations = Enum.reduce(Map.keys(operations), operations,
              fn monkey2, operations ->
                if monkey == monkey2 do
                  operations
                else
                  op = Map.get(operations, monkey2)

                  # IO.puts("")
                  # IO.inspect([monkey, v])
                  # IO.inspect([monkey2, op])

                  op = String.replace(op, monkey, "(#{v})")
                  # IO.inspect(op)

                  operations = Map.put(operations, monkey2, op)

                  operations
                end
              end
            )

            if monkey != "root" do
              operations = Map.delete(operations, monkey)
              operations
            else
              operations
            end
          end
        )
        {:cont, operations}
      end
    end)

    Map.get(operations, "root")

  end

  def calculate(numbers, operations) do

    Enum.reduce(
      Map.keys(operations),
      {{numbers, operations}, 0},
      fn key, {{numbers, operations}, ops} ->
        {op, [l, r]} = Map.get(operations, key)

        lv = Map.get(numbers, l, nil)
        rv = Map.get(numbers, r, nil)

        if lv == nil or rv == nil do
          {{numbers, operations}, ops}
        else
          # print(key, op, l, lv, r, rv)
          op = String.replace(op, l, to_string(lv))
          op = String.replace(op, r, to_string(rv))

          {res, _bind} = Code.eval_string(op, [])
          # IO.inspect(res)
          operations = Map.delete(operations, key)
          numbers = Map.put(numbers, key, res)

          {{numbers, operations}, ops + 1}
        end
      end)
  end

  def print(key, op, l, lv, r, rv) do
    if key == "root" do
      IO.inspect([key, op, l, lv, r, rv])
    end
  end

  def parse(s) do
    ss = String.split(s, ":")

    monkey = Enum.at(ss, 0)
    words = String.trim(Enum.at(ss, 1))

    res = Integer.parse(words)
    if res == :error do
      {monkey, words, :math}
    else
      {v, _rest} = res
      {monkey, v, :number}
    end
  end

end
