defmodule D19 do

  # D19.solve("input/d19/example.txt", 24)
  def solve(fname, minutes \\ 24) do

    fname
    |> File.stream!()
    |> Enum.map(&(String.replace(&1, "\n", "")))
    |> Enum.map(&(String.split(&1, " ")))
    |> Enum.map(&Blueprint.new/1)
    |> Enum.map(&(Factory.new(&1, minutes)))
    |> Enum.map(fn f ->
      Memoize.invalidate()
      {v, _best} = Factory.run(f, %{})
      {f.blueprint.id, v}
    end)
    |> Enum.map(&IO.inspect/1)
    |> Enum.reduce(0, fn {id, v}, acc -> acc + id * v end)

  end

  # D19.solve2("input/d19/example.txt", 32)
  # 1, 41
  # 3, 28
  def solve2(fname, minutes \\ 32) do

    fname
    |> File.stream!()
    |> Enum.map(&(String.replace(&1, "\n", "")))
    |> Enum.map(&(String.split(&1, " ")))
    |> Enum.map(&Blueprint.new/1)
    |> Enum.map(&IO.inspect/1)
    # |> Stream.drop(1)
    |> Enum.take(1)
    |> Enum.map(&(Factory.new(&1, minutes)))
    |> Enum.map(fn f ->
      Memoize.invalidate()
      {v, _best} = Factory.run(f, %{})
      {f.blueprint.id, v}
    end)
    |> Enum.map(&IO.inspect/1)
    |> Enum.reduce(1, fn {_id, v}, acc -> acc * v end)

  end

end


defmodule Resources do

  defstruct ore: 0, clay: 0, obsidian: 0, geode: 0

end

defmodule Blueprint do

  defstruct id: 0,
  cost: %{
    ore: Resources,
    clay: Resources,
    obsidian: Resources,
    geode: Resources
  },
  required: Resoures

  def new(ll) do
    bp = %Blueprint{
      id: String.to_integer(String.replace(Enum.at(ll, 1), ":", "")),
      cost: %Resources{
        ore: %Resources{
          ore: String.to_integer((Enum.at(ll, 6))),
          clay: 0,
          obsidian: 0,
          geode: 0
        },
        clay: %Resources{
          ore: String.to_integer((Enum.at(ll, 12))),
          clay: 0,
          obsidian: 0,
          geode: 0
        },
        obsidian: %Resources{
          ore: String.to_integer((Enum.at(ll, 18))),
          clay: String.to_integer((Enum.at(ll, 21))),
          obsidian: 0,
          geode: 0
        },
        geode: %Resources{
          ore: String.to_integer((Enum.at(ll, 27))),
          clay: 0,
          obsidian: String.to_integer((Enum.at(ll, 30))),
          geode: 0
        }
      },
      required: %Resources{
        ore: 0,
        clay: 0,
        obsidian: 0,
      }
    }

    req = %Resources{}
    req = %{req | ore: Enum.max([
      bp.cost.ore.ore,
      bp.cost.clay.ore,
      bp.cost.obsidian.ore,
      bp.cost.geode.ore,
    ])}
    req = %{req | clay: bp.cost.obsidian.clay}
    req = %{req | obsidian: bp.cost.geode.obsidian}

    bp = %{bp | required: req}

    bp
  end

end

defmodule Factory do

  use Memoize
  require Comb

  defstruct blueprint: Blueprint,
    minutes: 24, time: 0,
    robots: %Resources{
      ore: 1,
      clay: 0,
      obsidian: 0,
      geode: 0
    },
    resources: %Resources{
      ore: 0,
      clay: 0,
      obsidian: 0,
      geode: 0
    }

  def new(blueprint, minutes) do
    %Factory{blueprint: blueprint, minutes: minutes}
  end

  def run(factory, best) when factory.time == factory.minutes do
    {factory.resources.geode, best}
  end

  # don't build anything last turn
  def run(factory, best) when factory.time + 1 == factory.minutes do
    Memoize.Cache.get_or_run({
      __MODULE__, :resolve,
      [factory.blueprint.id, factory.time, factory.robots, factory.resources]
    },
    fn ->

    factory = %{factory | time: factory.time + 1}

    robots_start = factory.robots

    # inc resources
    resources = factory.resources
    resources = %{resources | ore: resources.ore + robots_start.ore}
    resources = %{resources | clay: resources.clay + robots_start.clay}
    resources = %{resources | obsidian: resources.obsidian + robots_start.obsidian}
    resources = %{resources | geode: resources.geode + robots_start.geode}
    factory = %{factory | resources: resources}

    run(factory, best)

    end)
  end

  def run(factory, best) do

    # inc time
    factory = %{factory | time: factory.time + 1}

    geode_best = Map.get(best, factory.time, -1)

    if geode_best <= factory.robots.geode do
      best = Map.put(best, factory.time, factory.robots.geode)
      _run(factory, best)
    else
      {factory.resources.geode, best}
    end
  end

  def _run(factory, best) do
    Memoize.Cache.get_or_run({
      __MODULE__, :resolve,
      [factory.blueprint.id, factory.time, factory.robots, factory.resources]
    },
    fn ->

    # IO.inspect("------")
    # IO.inspect([factory.time - 1, "robots", factory.robots])
    # IO.inspect([factory.time - 1, "resources", factory.resources])

    robots_start = factory.robots

    factories = craft_robots(factory)
    # IO.inspect([factory.time, length(factories)])

    # inc resources
    factories = Enum.map(factories, fn factory ->
      # inc resources
      resources = factory.resources
      resources = %{resources | ore: resources.ore + robots_start.ore}
      resources = %{resources | clay: resources.clay + robots_start.clay}
      resources = %{resources | obsidian: resources.obsidian + robots_start.obsidian}
      resources = %{resources | geode: resources.geode + robots_start.geode}
      %{factory | resources: resources}
    end)

    Enum.reduce(factories, {0, best}, fn factory, {max, best} ->
      {geode, best} = run(factory, best)
      {Enum.max([max, geode]), best}
    end)

    end)
  end

  def craft_robots(factory) do
    vars = craft_variations(factory)
    # IO.inspect([factory.time, vars])
    if length(vars) == 0 do
      [factory]
    else
      [factory] ++ Enum.map(vars, fn rs ->
        craft(factory, rs)
      end)
    end
  end

  def craft_variations(factory) do

    cond do
      can_craft(factory, :geode) -> [:geode]
      true ->
        [:obsidian, :clay, :ore]
        |> Enum.filter(&(!enough(factory, &1)))
        |> Enum.filter(&(worth_craft(factory, &1)))
        |> Enum.filter(&(can_craft(factory, &1)))
    end
  end

  # D19.solve2("input/d19/example.txt", 24)

  def enough(factory, robot) do
    {bp, robots} = {factory.blueprint, factory.robots}
    r = Map.get(bp.required, robot)
    h = Map.get(robots, robot)
    r <= h
  end

  def can_craft(factory, robot) do
    rs = [:geode, :obsidian, :clay, :ore]

    cost = Map.get(factory.blueprint.cost, robot)
    have = factory.resources

    Enum.reduce(rs, true, fn resource, ok ->
      c = Map.get(cost, resource, 0)
      h = Map.get(have, resource, 0)
      ok && (h - c >= 0)
    end)
  end

  # def worth_craft(factory, r) do
  #   x = Map.get(factory.robots, r)
  #   y = Map.get(factory.resources, r)
  #   t = factory.minutes - factory.time
  #   z = Map.get(factory.blueprint.required, r)

  #   x * t + y > t * z
  # end

  def worth_craft(factory, r) do
    case r do
      :ore ->
        Map.get(factory.robots, :obsidian) < 1
      :clay ->
        Map.get(factory.robots, :geode) < 1
      _ ->
        true
    end
  end

  def craft(factory, robot) do
    if !can_craft(factory, robot) do
      factory
    else
      rs = [:geode, :obsidian, :clay, :ore]

      cost = Map.get(factory.blueprint.cost, robot)
      have = factory.resources

      factory = Enum.reduce(rs, factory, fn resource, factory ->
        c = Map.get(cost, resource)
        h = Map.get(have, resource)

        %{factory | resources: Map.put(factory.resources, resource, h - c)}
      end)

      robots_num = Map.get(factory.robots, robot)
      %{factory | robots: Map.put(factory.robots, robot, robots_num + 1)}
    end

  end

end
