defmodule D18 do

  def solve(fname) do

    set = fname
    |> File.stream!()
    |> Enum.map(&(String.replace(&1, "\n", "")))
    |> Enum.map(&(String.split(&1, ",")))
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)
    |> Enum.reduce(MapSet.new(), fn cube, set -> MapSet.put(set, cube) end)

    lims = limits(set)
    IO.inspect(lims)

    set = find_air(set, lims)
    |> Enum.reduce(set, fn cube, set ->
      { new_set, res } = flood(set, cube, lims)
      # IO.inspect([cube, res])
      case res do
        :failed -> set
        :success -> new_set
      end
    end)

    MapSet.to_list(set)
    |> Enum.reduce(0, fn cube, acc ->
      neighbors(cube)
      |> Enum.reduce(acc, fn neighbor, acc ->
        if MapSet.member?(set, neighbor) do
          acc
        else
          acc + 1
        end
      end)
    end)

  end

  def flood(set, [x, y, z], lims) do
    [
      {x_min, x_max},
      {y_min, y_max},
      {z_min, z_max},
    ] = lims

    cond do
      # check if we are out
      x < x_min or x > x_max -> {set, :failed}
      y < y_min or y > y_max -> {set, :failed}
      z < z_min or z > z_max -> {set, :failed}
      # already filled
      MapSet.member?(set, [x, y, z]) -> {set, :success}
      # otherwise fill
      true ->
        set = MapSet.put(set, [x, y, z])
        Enum.reduce_while(neighbors([x, y, z]), {set, nil}, fn nb, {set, _res} ->
          {new_set, res} = flood(set, nb, lims)
          case res do
            :failed -> {:halt, {set, :failed}}
            :success -> {:cont, {new_set, :success}}
          end
        end)
    end
  end

  def find_air(set, lims) do
    [
      {x_min, x_max},
      {y_min, y_max},
      {z_min, z_max},
    ] = lims

    Enum.reduce(x_min..x_max, [], fn x, l ->
      Enum.reduce(y_min..y_max, l, fn y, l ->
        Enum.reduce(z_min..z_max, l, fn z, l ->
          if !MapSet.member?(set, [x, y, z]) do
            l ++ [[x, y, z]]
          else
            l
          end
        end)
      end)
    end)
  end

  def limits(set) do
    xs = MapSet.to_list(set)
    |> Enum.map(fn [x, _y, _z] -> x end)

    ys = MapSet.to_list(set)
    |> Enum.map(fn [_x, y, _z] -> y end)

    zs = MapSet.to_list(set)
    |> Enum.map(fn [_x, _y, z] -> z end)

    [
      {Enum.min(xs), Enum.max(xs)},
      {Enum.min(ys), Enum.max(ys)},
      {Enum.min(zs), Enum.max(zs)},
    ]
  end

  def neighbors([x, y, z]) do
    [
      [x - 1, y, z],
      [x + 1, y, z],
      [x, y - 1, z],
      [x, y + 1, z],
      [x, y, z - 1],
      [x, y, z + 1],
    ]
  end

end
