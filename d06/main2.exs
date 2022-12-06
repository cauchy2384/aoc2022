[fname] = System.argv()

# This is the solution.
# End of comments.
fname
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.map(fn s ->
  to_charlist(s)
  |> Enum.chunk_every(14, 1)
  |> Enum.map(fn w ->
    w
    |> Enum.group_by(&(&1))
    |> Enum.map(fn {k, v} -> {k, length(v)} end)
  end)
  |> Enum.with_index()
  |> Enum.filter(fn {m, _} ->
    Enum.count(m) == 14
  end)
  |> Enum.map(fn {_, idx} -> idx + 14 end)
  |> Enum.take(1)
end)
|> Stream.map(&IO.inspect/1)
|> Stream.run()
