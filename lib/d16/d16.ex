defmodule D16 do

  use Memoize

  require Graph
  require Graph.Pathfinding

  def prepare(fname) do
    # graph with vertexes
    g = fname
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse/1)
    |> Enum.reduce(Graph.new(), fn { valve, rate, _tunnels }, g -> Graph.add_vertex(g, valve, rate) end)

    # graph with nodes
    g = fname
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse/1)
    |> Enum.reduce(g, fn { valve, _rate, tunnels }, g ->
      Enum.reduce(tunnels, g, fn tunnel, g -> Graph.add_edge(g, valve, tunnel) end)
    end)

    # only nodes with weitght > 0 required
    vs = Graph.vertices(g)
    |> Enum.filter(fn v -> weight(g, v) > 0 end)
    # and a start node
    vs = ["AA"] ++ vs

    # new graph with vertexes
    g2 = vs
    |> Enum.reduce(Graph.new(), fn v, g2 ->
      Graph.add_vertex(g2, v, Graph.vertex_labels(g, v))
    end)

    # add edges
    g2 = Enum.reduce(vs, g2, fn v, g2 ->
      Enum.reduce(vs, g2, fn v2, g2 ->
        if v == v2 do
          g2
        else
          path = Graph.Pathfinding.dijkstra(g, v, v2)
          w = length(path) - 1
          Graph.add_edge(g2, v, v2, weight: w)
        end
      end)
    end)

    to_open = length(vs) - 1

    {g2, to_open}
  end

  # D16.solve("input/d16/example.txt")
  # path
  # AA DD CC BB AA II JJ II AA DD EE FF GG HH GG FF EE DD CC
  # opened (reversed)
  # CC EE HH JJ BB DD

  def solve(fname, seconds \\ 30) do

    {g, to_open} = prepare(fname)

    IO.inspect(["graph", g])
    IO.inspect(["to open:", to_open])

    dfs(g, seconds, "AA", [], to_open)

  end

  def dfs(g, _time, _v, opened, to_open) when length(opened) == to_open do
    calculate(g, opened)
  end

  def dfs(_g, time, _v, opened, _to_open) when time <= 1 do
    # calculate(g, opened)
    {opened, 0}
  end

  def dfs(g, time, v, opened, to_open) do
    Memoize.Cache.get_or_run({__MODULE__, :resolve, [time, v, opened]}, fn ->

      Graph.out_edges(g, v)
      |> Enum.filter(fn edge -> !is_opened(edge.v2, opened) end)
      |> Enum.map(fn edge ->
        open(g, time - edge.weight, edge.v2, opened, to_open)
      end)
      |> Enum.max(fn {_opened1, score1}, {_opened2, score2} -> score1 > score2 end)

    end)
  end

  def open(g, time, next, opened, to_open) when next == "AA" do
    dfs(g, time, next, opened, to_open)
  end

  def open(_g, time, _next, opened, _to_open) when time < 1 and length(opened) == 0 do
    {opened, 0}
  end

  def open(g, time, _next, opened, _to_open) when time < 1 do
    calculate(g, opened)
  end

  def open(g, time, next, opened, to_open) do
    # open
    time = time - 1
    opened = opened ++ [{time, next}]
    # go to next
    dfs(g, time, next, opened, to_open)
  end

  # D16.solve2("input/d16/example.txt")
  def solve2(fname, seconds \\ 26) do

    {g, to_open} = prepare(fname)

    IO.inspect(["graph", g])
    IO.inspect(["to open:", to_open])

    dfs2(g, seconds, seconds, "AA", [], to_open)

  end

  def dfs2(g, _seconds, _time, _v, opened, to_open) when length(opened) == to_open do
    calculate(g, opened)
  end

  def dfs2(g, seconds, time, _v, opened, to_open) when time <= 10 do
    dfs(g, seconds, "AA", opened, to_open)
  end

  def dfs2(g, seconds, time, v, opened, to_open) when time >= 20 do
    _dfs2(g, seconds, time, v, opened, to_open)
  end

  def dfs2(g, seconds, time, v, opened, to_open) do

    # IO.inspect(length(opened))

    Memoize.Cache.get_or_run({__MODULE__, :resolve, ["dfs2", time, v, opened]}, fn ->

      [
        _dfs2(g, seconds, time, v, opened, to_open),
        dfs(g, seconds, "AA", opened, to_open)
      ]
      |> Enum.max(fn {_opened1, score1}, {_opened2, score2} -> score1 > score2 end)

    end)
  end

  def _dfs2(g, seconds, time, v, opened, to_open) do
    # IO.inspect(["dfs2", opened, v])
    Memoize.Cache.get_or_run({__MODULE__, :resolve, ["_dfs2", time, v, opened]}, fn ->

      Graph.out_edges(g, v)
      |> Enum.filter(fn edge -> !is_opened(edge.v2, opened) end)
      |> Enum.map(fn edge ->
        open2(g, seconds, time - edge.weight, edge.v2, opened, to_open)
      end)
      |> Enum.max(fn {_opened1, score1}, {_opened2, score2} -> score1 > score2 end)

    end)
  end

  def open2(g, seconds, time, next, opened, to_open) when next == "AA" do
    # IO.inspect(["open2.skip AA", opened])
    dfs2(g, seconds, time, next, opened, to_open)
  end

  def open2(_g, _seconds, time, _next, opened, _to_open) when time < 1 and length(opened) == 0 do
    {opened, 0}
  end

  def open2(g, seconds, time, _next, opened, to_open) when time < 1 do
    # IO.inspect(["open2.timeout", opened])
    dfs(g, seconds, "AA", opened, to_open)
  end

  def open2(g, seconds, time, next, opened, to_open) do
    # IO.inspect(["open2", next, opened])
    # open
    time = time - 1
    opened = opened ++ [{time, next}]
    # go to next
    dfs2(g, seconds, time, next, opened, to_open)
  end

  def is_opened(_v, opened) when opened == [] do
    false
  end

  # skip AA and never try to open it
  def is_opened(v, _opened) when v == "AA" do
    true
  end

  def is_opened(v, opened) do
    opened
    |> Enum.map(fn {_time, v} -> v end)
    |> Enum.member?(v)
  end

  def weight(g, v) do
    [w] = Graph.vertex_labels(g, v)
    w
  end

  def calculate(_g, opened) when length(opened) == 0 do
    {opened, 0}
  end

  def calculate(g, opened) when length(opened) == 1 do
    {time, v} = Enum.at(opened, 0)
    score = weight(g, v) * time
    {opened, score}
  end

  def calculate(g, opened) do
    Memoize.Cache.get_or_run({__MODULE__, :resolve, [opened]}, fn ->

      {_opened1, score1} =  calculate(g, [hd(opened)])
      {_opened2, score2} =  calculate(g, tl(opened))
      score = score1 + score2

      {opened, score}

    end)
  end

  def parse(s) do
    [l, r] = String.split(s, ";")
    { valve, rate } = parse_valve(l)
    { valve, rate, parse_tunnels(r) }
  end

  def parse_valve("Valve " <> s) do
    [l, r] = String.split(s, "has flow rate=")
    { String.trim(l), String.to_integer(String.trim(r)) }
  end

  def parse_tunnels(s) do
    String.split(s, " ")
    |> Enum.drop(5)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&(String.replace(&1, ",", "")))
  end

end
