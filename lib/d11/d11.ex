defmodule D11 do

  def solve(fname) do

    monkeys = fname
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
    |> Enum.chunk_every(6)
    |> Enum.map(fn monkey -> Enum.map(monkey, &parse/1) end)
    |> Enum.map(fn monkey ->
      %{
        id: Enum.at(monkey, 0),
        items: Enum.at(monkey, 1),
        op: Enum.at(monkey, 2),
        test: Enum.at(monkey, 3),
        test_passed: Enum.at(monkey, 4),
        test_failed: Enum.at(monkey, 5),
        inspected: 0,
      }
    end)
    |> Map.new(fn monkey -> {monkey.id, monkey} end)

    Enum.scan(1..20, monkeys, fn _, monkeys ->
      [ monkeys ] = Enum.scan(0..(map_size(monkeys) - 1), monkeys, fn id, monkeys ->
        monkey = Map.get(monkeys, id)

        if length(monkey.items) == 0 do
          monkeys
        else
          # inspect items
          monkey = Map.get(monkeys, id)
          monkey = Map.put(monkey, :items, Enum.map(monkey.items, &(inspect_item(&1, monkey.op))))
          inspected = Map.get(monkey, :inspected) + length(monkey.items)
          monkey = Map.put(monkey, :inspected, inspected)
          monkeys = Map.put(monkeys, id, monkey)

          # throw items
          [ monkeys ] = Enum.scan(monkey.items, monkeys, fn item, monkeys ->
            if rem(item, monkey.test) == 0 do
              throw_item(monkeys, monkey.test_passed, item)
            else
              throw_item(monkeys, monkey.test_failed, item)
            end
          end)
          |> Enum.take(-1)

          # clear monkey items
          monkey = Map.get(monkeys, id)
          monkey = Map.put(monkey, :items, [])
          monkeys = Map.put(monkeys, id, monkey)

          monkeys
        end
      end)
      |> Enum.take(-1)

      monkeys
    end)
    |> Enum.take(-1)
    |> Enum.at(0)
    |> Map.to_list()
    |> Enum.map(fn {_, monkey} -> monkey.inspected end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.scan(1, &(&1 * &2))
    |> Enum.take(-1)

  end

  def solve2(fname) do

    monkeys = fname
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
    |> Enum.chunk_every(6)
    |> Enum.map(fn monkey -> Enum.map(monkey, &parse/1) end)
    |> Enum.map(fn monkey ->
      %{
        id: Enum.at(monkey, 0),
        items: Enum.at(monkey, 1),
        op: Enum.at(monkey, 2),
        test: Enum.at(monkey, 3),
        test_passed: Enum.at(monkey, 4),
        test_failed: Enum.at(monkey, 5),
        inspected: 0,
      }
    end)
    |> Map.new(fn monkey -> {monkey.id, monkey} end)

    [ threshold ] = Enum.scan(Map.to_list(monkeys), 1, fn {_, monkey}, acc ->
      acc * monkey.test
    end)
    |> Enum.take(-1)
    IO.inspect(threshold)

    Enum.scan(1..10000, monkeys, fn round, monkeys ->
      # IO.puts(round)

      [ monkeys ] = Enum.scan(0..(map_size(monkeys) - 1), monkeys, fn id, monkeys ->
        monkey = Map.get(monkeys, id)

        if length(monkey.items) == 0 do
          monkeys
        else
          # inspect items
          monkey = Map.get(monkeys, id)
          monkey = Map.put(monkey, :items, Enum.map(monkey.items, &(inspect_item2(&1, monkey.op, threshold))))
          inspected = Map.get(monkey, :inspected) + length(monkey.items)
          monkey = Map.put(monkey, :inspected, inspected)
          monkeys = Map.put(monkeys, id, monkey)

          # throw items
          [ monkeys ] = Enum.scan(monkey.items, monkeys, fn item, monkeys ->
            if rem(item, monkey.test) == 0 do
              throw_item(monkeys, monkey.test_passed, item)
            else
              throw_item(monkeys, monkey.test_failed, item)
            end
          end)
          |> Enum.take(-1)

          # clear monkey items
          monkey = Map.get(monkeys, id)
          monkey = Map.put(monkey, :items, [])
          monkeys = Map.put(monkeys, id, monkey)

          monkeys
        end
      end)
      |> Enum.take(-1)

      monkeys
    end)
    |> Enum.take(-1)
    |> Enum.at(0)
    |> Map.to_list()
    |> Enum.map(fn {_, monkey} -> monkey.inspected end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.scan(1, &(&1 * &2))
    |> Enum.take(-1)

  end

  def parse("Monkey " <> rest) do
    String.to_integer(String.trim(rest, ":"))
  end

  def parse("Starting items: " <> rest) do
    String.split(rest, ",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end

  def parse("Operation: new = " <> rest) do
    rest
  end

  def parse("Test: divisible by " <> rest) do
    String.to_integer(rest)
  end

  def parse("If true: throw to monkey " <> rest) do
    String.to_integer(rest)
  end

  def parse("If false: throw to monkey " <> rest) do
    String.to_integer(rest)
  end

  def parse(any) do
     any
  end

  def inspect_item(old, op) do
    {new, _} = Code.eval_string(op, [old: old])
    trunc(new / 3)
  end

  def throw_item(monkeys, id, item) do
    monkey = Map.get(monkeys, id)
    items = Map.get(monkey, :items)
    items = items ++ [ item ]
    monkey = Map.put(monkey, :items, items)
    Map.put(monkeys, id, monkey)
  end

  def inspect_item2(old, op, threshold) do
    {new, _} = Code.eval_string(op, [old: old])
    rem(new, threshold)
  end

end
