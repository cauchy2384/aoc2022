defmodule D09 do

  require Matrix

  def solve(fname) do

    start = {0, 0}

    fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [d, num] -> [d, String.to_integer(num)] end)
    |> Stream.flat_map(fn [d, s] -> Enum.map(1..s, fn _ -> d end) end)
    |> Stream.scan(
      { start, start },
      fn direction, { head, tail } ->
        head = move_head(direction, head)
        tail = follow_tail(head, tail)
        { head, tail }
      end)
    |> Stream.map(fn {_, tail} -> tail end)
    |> Stream.uniq()
    |> Stream.with_index()
    |> Stream.map(fn {_, idx} -> idx + 1 end)
    |> Stream.take(-1)
    |> Stream.each(&IO.inspect/1)
    |> Stream.run()

  end

  def solve2(fname) do

    start = {0, 0}

    fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [d, num] -> [d, String.to_integer(num)] end)
    |> Stream.flat_map(fn [d, s] -> Enum.map(1..s, fn _ -> d end) end)
    |> Stream.scan(
      Enum.map(1..10, fn _ -> start end),
      fn direction, rope ->
        head = hd(rope)
        tail = tl(rope)
        head = move_head(direction, head)
        tail = Enum.scan(tail, head, fn tail, head ->
          follow_tail(head, tail)
        end)
        [head] ++ tail
      end)
    |> Stream.map(fn rope -> Enum.at(rope, -1) end)
    |> Stream.uniq()
    |> Stream.with_index()
    |> Stream.map(fn {_, idx} -> idx + 1 end)
    |> Stream.take(-1)
    |> Stream.each(&IO.inspect/1)
    |> Stream.run()

  end

  def move_head(d, {x, y}) when d == "R" do {x + 1, y} end
  def move_head(d, {x, y}) when d == "L" do {x - 1, y} end
  def move_head(d, {x, y}) when d == "U" do {x, y + 1} end
  def move_head(d, {x, y}) when d == "D" do {x, y - 1} end

  def follow_tail(head, tail) do
    cond do
      are_touching(head, tail) -> tail
      true -> move_tail(head, tail)
    end
  end

  def are_touching({hx, hy}, {tx, ty}) do
    cond do
      abs(hx - tx) > 1 or abs(hy - ty) > 1 -> false
      true -> true
    end
  end

  def move_tail({hx, hy}, {tx, ty}) do
    dx = hx - tx
    dy = hy - ty
    cond do
      hx == tx and hy > ty -> {tx, ty + 1}
      hx == tx and hy < ty -> {tx, ty - 1}
      hy == ty and hx > tx -> {tx + 1, ty}
      hy == ty and hx < tx -> {tx - 1, ty}
      dx > 0 and dy > 0 -> {tx + 1, ty + 1}
      dx > 0 and dy < 0 -> {tx + 1, ty - 1}
      dx < 0 and dy > 0 -> {tx - 1, ty + 1}
      dx < 0 and dy < 0 -> {tx - 1, ty - 1}
      true -> {tx, ty}
    end
  end

end
