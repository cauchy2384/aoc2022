defmodule RSP do

  def round(values, score) do
    [opponent, me] = String.split(values, " ")

    opponent = map_opponent(opponent)
    me = map_me(me)

    score = score + points_me(me)
    score = score + points_match(opponent, me)

    {[score], score}
  end

  def map_opponent(v) do
    case v do
      "A" -> :rock
      "B" -> :paper
      _ -> :scissors
    end
  end

  def map_me(v) do
    case v do
      "X" -> :rock
      "Y" -> :paper
      _ -> :scissors
    end
  end

  def points_me(shape) do
    case shape do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
      _ -> 0
    end
  end

  def points_match(opponent, me) do
    cond do
      opponent == me -> 3
      opponent == :rock && me == :paper -> 6
      opponent == :paper && me == :scissors -> 6
      opponent == :scissors && me == :rock -> 6
      true -> 0
    end
  end

end


"input.txt"
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.transform(0, &RSP.round/2)
|> Stream.take(-1)
|> Stream.map(&IO.puts/1)
|> Stream.run()
