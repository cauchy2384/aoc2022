defmodule D07 do

  require Graph
  require Graph.Reducers.Bfs

  def solve(fname) do

    fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != "$ ls"))
    |> Stream.scan({Graph.new, nil, [], 0}, fn l, {g, v, path, d} -> match(g, v, l, path, d) end)
    |> Stream.map(fn {g, _, _, _} -> g end)
    |> Stream.take(-1)
    |> Stream.each(fn g -> IO.inspect(Graph.is_tree?(g)) end)
    |> Stream.each(fn g -> IO.inspect(Graph.is_cyclic?(g)) end)
    |> Stream.each(&IO.inspect/1)
    |> Stream.map(fn g ->
      Graph.Reducers.Dfs.reduce(g, 0, fn v, acc ->
        {g, w} = size(g, v, Graph.vertex_labels(g, v))

        if Graph.vertex_labels(g, v) == [:dir] and w <= 100000 do
          {:next, acc + w}
        else
          {:next, acc}
        end
      end)
    end)
    |> Stream.take(-1)
    |> Stream.each(&IO.inspect/1)
    |> Stream.run()

  end

  def solve2(fname) do

    fname
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != "$ ls"))
    |> Stream.scan({Graph.new, nil, [], 0}, fn l, {g, v, path, d} -> match(g, v, l, path, d) end)
    |> Stream.map(fn {g, _, _, _} -> g end)
    |> Stream.take(-1)
    |> Stream.each(fn g -> IO.inspect(Graph.is_tree?(g)) end)
    |> Stream.each(fn g -> IO.inspect(Graph.is_cyclic?(g)) end)
    |> Stream.each(&IO.inspect/1)
    |> Stream.map(fn g ->
      total = Graph.Reducers.Bfs.reduce(g, 0, fn v, acc ->
        {_, w} = size(g, v, Graph.vertex_labels(g, v))

        if w > acc do
          {:next, w}
        else
          {:next, acc}
        end
      end)
      IO.inspect(["total", total])
      {g , total}
    end)
    |> Stream.map(fn {g, total} ->
      to_free = total - (70000000 - 30000000)
      IO.inspect(["to free", to_free])

      nodes = Graph.Reducers.Bfs.reduce(g, [], fn v, acc ->
        {g, w} = size(g, v, Graph.vertex_labels(g, v))

        if Graph.vertex_labels(g, v) == [:dir] and w > to_free do
          {:next, acc ++ [w]}
        else
          {:next, acc}
        end
      end)

      Enum.sort(nodes, :asc) |> Enum.take(1)
    end)
    |> Stream.each(&IO.inspect/1)
    |> Stream.run()

  end

  def match(g, v, "$ cd " <> rest, path, d) do
    change_dir(g, v, rest, path, d)
  end

  def change_dir(g, v, "..", path, d) do
    edge = Graph.in_edges(g, v) |> Enum.at(0)
    if edge == nil do
      path = [ v ]
      {g, v, path, d}
    else
      v = edge.v1
      path = List.delete_at(path, length(path) - 1)
      {g, v, path, d - 1}
    end
  end

  def change_dir(g, _, name, path, d) do
    name = String.to_atom(name)
    path = path ++ [ name ]
    v = path
    g = Graph.add_vertex(g, v, :dir)
    {g, v, path, d + 1}
  end

  def match(g, v, "dir " <> dir, path, d) do
    name = String.to_atom(dir)
    v2 = path ++ [ name ]
    g = Graph.add_vertex(g, v2, :dir)
    |> Graph.add_edge(v, v2, weight: 0)
    {g, v, path, d}
  end

  def match(g, v, l, path, d) do
    [w, file] = String.split(l, " ")
    name = String.to_atom(file)
    v2 = path ++ [ name ]
    g = Graph.add_vertex(g, v2, :file)
    |> Graph.add_edge(v, v2, weight: String.to_integer(w))
    {g, v, path, d}
  end

  def size(g, v, labels) when labels == [:dir] do
    e = Graph.in_edges(g, v)
    |> Enum.at(0)
    if e != nil and e.weight != 0 do
      e.weight
    end

    {_, sum} = Graph.out_edges(g, v)
    |> Enum.scan({g, 0}, fn edge, {g, acc} ->
      v = edge.v2
      {g, sum} = size(g, v, Graph.vertex_labels(g, v))
      {g, acc + sum}
    end)
    |> Enum.take(-1)
    |> Enum.at(0)

    if sum == nil do
      g = Graph.update_edge(g, e.v1, e.v2, weight: 0)
      {g, 0}
    else
      if e != nil do
        g = Graph.update_edge(g, e.v1, e.v2, weight: sum)
      end
      {g, sum}
    end
  end

  def size(g, v, labels) when labels == [:file] do
    e = Graph.in_edges(g, v)
    |> Enum.at(0)

    {g, e.weight}
  end

end
