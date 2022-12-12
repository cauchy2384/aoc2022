# I was drunk, but it works lol
defmodule D12 do

  require Graph
  require Matrix
  require Graph.Pathfinding

  def solve(fname) do

    # calculate matrix size
    [{cols, rows}] = fname
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.scan({0, 0}, fn l, {_, acc} -> {String.length(l), acc+1} end)
    |> Enum.take(-1)

    m = Matrix.new(rows, cols)

    # fill matrix
    [{_, m}] = fname
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.scan({0, m}, fn row, {r, m} ->
      [{_, m}] = Enum.scan(to_charlist(row), {0, m}, fn el, {c, m} ->
        case el do
          ?S -> {c + 1, Matrix.set(m, r, c, ?a)}
          ?E -> {c + 1, Matrix.set(m, r, c, ?z)}
          _ -> {c + 1, Matrix.set(m, r, c, el)}
        end
      end)
      |> Enum.take(-1)
      {r + 1, m}
    end)
    |> Enum.take(-1)

    # create nodes
    [ g ] = Enum.scan(0..rows - 1, Graph.new(), fn r, g ->
      [ g ] = Enum.scan(0..cols - 1, g, fn c, g ->
        v = Matrix.elem(m, r, c)
        Graph.add_vertex(g, {r, c}, v)
      end)
      |> Enum.take(-1)
      g
    end)
    |> Enum.take(-1)

    # create edges
    [ g ] = Enum.scan(0..rows - 1, g, fn r, g ->
      [ g ] = Enum.scan(0..cols - 1, g, fn c, g ->
        v = Matrix.elem(m, r, c)
        [ g ] = Enum.scan(
          [{r - 1, c}, {r + 1, c}, {r, c - 1}, {r, c + 1}],
          g,
          fn {r2, c2}, g ->
            cond do
            r2 < 0 or r2 > (rows - 1) -> g
            c2 < 0 or c2 > (cols - 1) -> g
            true ->
              v2 = Matrix.elem(m, r2, c2)
              if v == ?S or v2 == ?E or (v2 - v) <= 1 do
                Graph.add_edge(g, {r, c}, {r2, c2})
              else
                g
              end
            end
          end
          )
          |> Enum.take(-1)
        g
      end)
      |> Enum.take(-1)
      g
    end)
    |> Enum.take(-1)

    # find S and E
    [{s, e, _}] = fname
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.scan({{0, 0}, {0, 0}, 0}, fn row, {s, e, r} ->
      [{s, e, _}] = Enum.scan(to_charlist(row), {s, e, 0}, fn el, {s, e, c} ->
        case el do
          ?S -> {{r, c}, e, c + 1}
          ?E -> {s, {r, c}, c + 1}
          _ -> {s, e, c + 1}
        end
      end)
      |> Enum.take(-1)
      {s, e, r + 1}
    end)
    |> Enum.take(-1)

    path = Graph.Pathfinding.dijkstra(g, s, e)
    length(path) - 1

  end

  def solve2(fname) do

    # calculate matrix size
    [{cols, rows}] = fname
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.scan({0, 0}, fn l, {_, acc} -> {String.length(l), acc+1} end)
    |> Enum.take(-1)

    m = Matrix.new(rows, cols)

    # fill matrix
    [{_, m}] = fname
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.scan({0, m}, fn row, {r, m} ->
      [{_, m}] = Enum.scan(to_charlist(row), {0, m}, fn el, {c, m} ->
        case el do
          ?S -> {c + 1, Matrix.set(m, r, c, ?a)}
          ?E -> {c + 1, Matrix.set(m, r, c, ?z)}
          _ -> {c + 1, Matrix.set(m, r, c, el)}
        end
      end)
      |> Enum.take(-1)
      {r + 1, m}
    end)
    |> Enum.take(-1)

    # create nodes
    [ g ] = Enum.scan(0..rows - 1, Graph.new(), fn r, g ->
      [ g ] = Enum.scan(0..cols - 1, g, fn c, g ->
        v = Matrix.elem(m, r, c)
        Graph.add_vertex(g, {r, c}, v)
      end)
      |> Enum.take(-1)
      g
    end)
    |> Enum.take(-1)

    # create edges
    [ g ] = Enum.scan(0..rows - 1, g, fn r, g ->
      [ g ] = Enum.scan(0..cols - 1, g, fn c, g ->
        v = Matrix.elem(m, r, c)
        [ g ] = Enum.scan(
          [{r - 1, c}, {r + 1, c}, {r, c - 1}, {r, c + 1}],
          g,
          fn {r2, c2}, g ->
            cond do
            r2 < 0 or r2 > (rows - 1) -> g
            c2 < 0 or c2 > (cols - 1) -> g
            true ->
              v2 = Matrix.elem(m, r2, c2)
              if v == ?S or v2 == ?E or (v2 - v) <= 1 do
                Graph.add_edge(g, {r, c}, {r2, c2})
              else
                g
              end
            end
          end
          )
          |> Enum.take(-1)
        g
      end)
      |> Enum.take(-1)
      g
    end)
    |> Enum.take(-1)

    # find E
    [{_, e, _}] = fname
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Enum.scan({{0, 0}, {0, 0}, 0}, fn row, {s, e, r} ->
      [{s, e, _}] = Enum.scan(to_charlist(row), {s, e, 0}, fn el, {s, e, c} ->
        case el do
          ?S -> {{r, c}, e, c + 1}
          ?E -> {s, {r, c}, c + 1}
          _ -> {s, e, c + 1}
        end
      end)
      |> Enum.take(-1)
      {s, e, r + 1}
    end)
    |> Enum.take(-1)

    [aas] = Enum.scan(0..rows - 1, [], fn r, aas ->
      [aas] = Enum.scan(0..cols - 1, aas, fn c, aas ->
        v = Matrix.elem(m, r, c)
        if v == ?a do
          aas ++ [{r, c}]
        else
          aas
        end
      end
      )
      |> Enum.take(-1)
      aas
    end
    )
    |> Enum.take(-1)

    [ l ] = Enum.map(aas, fn {r, c} ->
      path = Graph.Pathfinding.dijkstra(g, {r, c}, e)
      if path == nil do
        nil
      else
        length(path) - 1
      end
    end)
    |> Enum.filter(&(&1 != nil))
    |> Enum.sort(:asc)
    |> Enum.take(1)

    l

  end

end
