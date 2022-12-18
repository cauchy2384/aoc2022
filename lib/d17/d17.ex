defmodule D17 do

  def solve(fname) do

    pattern = File.read!(fname)
    # IO.inspect(pattern)

    g = Stream.iterate(0, &(&1+1))
    |> Enum.reduce_while(Game.new(pattern), fn _, g ->
      g = Game.exec(g)

      # Game.draw(g)
      # IO.inspect(g.state)
      # :timer.sleep(100);

      if g.spawned == 6000 do
        {:halt, g}
      else
        {:cont, g}
      end
    end)

    # Stream.iterate(1, &(&1+1))
    # |> Enum.reduce_while(false, fn delta, _ ->
    #   {_deltas, found} = Enum.reduce_while(1..delta, {g.deltas, false}, fn offset, {deltas, _found} ->
    #     deltas = tl(deltas)

    #     [a, b,
    #     c,
    #     ] = deltas
    #     |> Enum.chunk_every(delta)
    #     |> Enum.take(3)

    #     # IO.inspect([delta, Enum.max(ll), Enum.min(ll)])
    #     if a == b
    #     and b == c and a == c
    #     do
    #       IO.inspect([
    #         offset, delta,
    #         Enum.take(g.deltas, offset),
    #         Enum.drop(g.deltas, offset) |> Enum.take(delta),
    #         a, b,
    #         # c,
    #       ])
    #       {:halt, {deltas, true}}
    #     else
    #       {:cont, {deltas, false}}
    #     end
    #   end)

    #   cond do
    #     delta > 100 -> {:halt, false}
    #     found == true -> {:halt, true}
    #     true -> {:cont, false}
    #   end
    # end)


    # {15, 35}
    # l = g.deltas
    # |> Enum.take(15)
    # |> Enum.sum()

    # r = g.deltas
    # |> Enum.take(15+35)
    # |> Enum.sum()

    # r2 = g.deltas
    # |> Enum.take(15+35+35)
    # |> Enum.sum()

    # IO.inspect([l, r, r-l, r2, r2-r])
    # # [25, 78, 53, 131, 53]

    # 1514285714288
    h = 25 + div(1000000000000 - 15, 35) * 53
    IO.inspect(h)

    IO.inspect(div(1000000000000 - 15, 35))
    IO.inspect(rem(1000000000000 - 15, 35))

    # {72, 1745}
    l = g.deltas
    |> Enum.take(72)
    |> Enum.sum()

    r = g.deltas
    |> Enum.take(72+1745)
    |> Enum.sum()

    r2 = g.deltas
    |> Enum.take(72+1745+1745)
    |> Enum.sum()

    r3 = g.deltas
    |> Enum.take(72+1745+1745+938)
    |> Enum.sum()

    IO.inspect([l, r, r-l, r2, r2-r, r3, r3-r2])
    # [106, 2844, 2738, 5582, 2738]

    h = 106 + div(1000000000000 - 72, 1745) * 2738 + 1461
    IO.inspect(h)

    IO.inspect(div(1000000000000 - 72, 1745))
    IO.inspect(rem(1000000000000 - 72, 1745))

    g.highest + 1


  end

end


defmodule Game do

  defstruct tick: 0, spawned: 0, pushed: 0,
    wind: [],
    field: Matrix.new(4000*4, 7, ?\.),
    highest: -1, deltas: [],
    lowest: [-1, -1, -1, -1, -1, -1, -1],
    bottom: -1,
    state: :spawn, fig: []

  def new(wind) do
    %Game{wind: to_charlist(wind)}
  end

  def exec(g) do
    case g.state do
      :spawn ->
        g = spawn_fig(g)
        # draw(g)
        # IO.inspect(g.lowest)
        %{g | state: :move}
      :move ->
        g = move_fig(g)
        g = tick(g)
        g
      s ->
        IO.inspect(["unknown state", s])
        g
    end
  end

  def tick(g) do
    { _, g } = Map.get_and_update!(g, :tick, fn v -> {v, v+ 1} end)
    g
  end

  def get_action(g) do
    if rem(g.tick, 2) == 0 do
      :push
    else
      :fall
    end
  end

  def spawn_fig(g) do
    { spawned, g } = Map.get_and_update!(g, :spawned, fn v -> {v, v+ 1} end)

    {x, y} = {2, g.highest + 4}

    case rem(spawned, 5) do
      0 ->
        # IO.inspect([g.spawned, g.pushed])
        # IO.inspect(g.lowest)
        %{g | fig: [{x, y}, {x + 1, y}, {x + 2, y}, {x + 3, y}]}
      1 -> %{g | fig: [{x, y + 1}, {x + 1, y}, {x + 1, y + 1}, {x + 1, y + 2}, {x + 2, y + 1}]}
      2 -> %{g | fig: [{x, y}, {x + 1, y}, {x + 2, y}, {x + 2, y + 1}, {x + 2, y + 2}]}
      3 -> %{g | fig: [{x, y}, {x, y + 1}, {x, y + 2}, {x, y + 3}]}
      4 -> %{g | fig: [{x, y}, {x, y + 1}, {x + 1, y}, {x + 1, y + 1}]}
    end
  end

  def move_fig(g) do
    action = get_action(g)
    # IO.inspect(action)

    case action do
      :push -> push_fig(g)
      :fall -> fall_fig(g)
    end
  end

  def push_fig(g) do
    { pushed, g } = Map.get_and_update!(g, :pushed, fn v -> {v, v+ 1} end)
    dir = get_direction(g, pushed)

    # IO.inspect(dir)
    case dir do
      :right -> move_fig(g, 1)
      :left -> move_fig(g, -1)
    end
  end

  def move_fig(g, dx) do
    fig = Enum.map(g.fig, fn {x, y} -> {x + dx, y} end)

    if valid_fig(g, fig) do
      %{g | fig: fig}
    else
      g
    end
  end

  def get_direction(g, pushed) do
    i = rem(pushed, length(g.wind))

    case Enum.at(g.wind, i) do
      ?\> -> :right
      ?\< -> :left
    end
  end

  def fall_fig(g) do
    fig = Enum.map(g.fig, fn {x, y} -> {x, y - 1} end)
    if valid_fig(g, fig) do
      %{g | fig: Enum.map(g.fig, fn {x, y} -> {x, y - 1} end)}
    else
      g = rock_fig(g)
      %{g | state: :spawn}
    end
  end

  def valid_fig(g, fig) do
    m = Map.get(g, :field)
    {rows, cols} = Matrix.size(m)

    Enum.reduce(fig, 0, fn {x, y}, acc ->
      cond do
      x < 0 or x >= cols -> acc + 1
      y < 0 or y >= rows -> acc + 1
      Matrix.elem(m, y, x) != ?\. -> acc + 1
      true -> acc
      end
    end) == 0
  end

  def rock_fig(g) do
    fig = g.fig
    m = Map.get(g, :field)

    m = Enum.reduce(fig, m, fn {x, y}, m ->
      Matrix.set(m, y, x, ?\#)
    end)

    g = %{g | field: m, fig: []}

    # g = adjust(g, fig)

    max_y = Enum.map(fig, fn {_x, y} -> y end)
    |> Enum.max()

    if max_y > g.highest do
      deltas = g.deltas ++ [max_y - g.highest]
      %{g | highest: max_y, deltas: deltas}
    else
      deltas = g.deltas ++ [0]
      %{g | deltas: deltas}
    end
  end

  def adjust(g, fig) do
    lowest = g.lowest
    lowest = Enum.reduce(fig, lowest, fn {x, y}, lowest ->
      # IO.inspect([{x, y}, Enum.at(lowest, x)])
      if Enum.at(lowest, x) < y do
        List.replace_at(lowest, x, y)
      else
         lowest
      end
    end)

    g = %{g | lowest: lowest}
    g

    # if Enum.min(lowest) > g.bottom do
    #   g = rotate(g, Enum.min(lowest) - g.bottom)
    #   %{g | bottom: Enum.min(lowest)}
    # else
    #   g
    # end
  end

  def rotate(g, delta) do
    m = Map.get(g, :field)
    {rows, cols} = Matrix.size(m)

    m = Enum.reduce(0..rows-1-delta, m, fn y, m ->
      Enum.reduce(0..cols-1, m, fn x, m ->
        v = Matrix.elem(m, y + delta, x)
        Matrix.set(m, y, x, v)
      end)
    end)

    m = Enum.reduce(rows-1-delta..rows-1, m, fn y, m ->
      Enum.reduce(0..cols-1, m, fn x, m ->
        Matrix.set(m, y, x, ?\.)
      end)
    end)

    %{g | field: m}
  end

  def draw(g) do
    m = Map.get(g, :field)

    m = Enum.reduce(g.fig, m, fn {x, y}, m -> Matrix.set(m, y, x, ?\@) end)

    {rows, cols} = Matrix.size(m)
    Enum.each(rows-1..0, fn row ->
      l = Enum.reduce(0..cols-1, [], fn col, l ->
        l ++ [Matrix.elem(m, row, col)]
      end)
      l = ["|"] ++ l ++ ["|"]
      IO.puts(to_string(l))
    end)

    l = Enum.reduce(0..cols-1, [], fn _, l ->
      l ++ ["-"]
    end)
    l = ["+"] ++ l ++ ["+"]
    IO.puts(to_string(l))
  end

end
