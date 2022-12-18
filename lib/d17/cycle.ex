defmodule Cycle_detection do
  def find_cycle(x0, f) do
    lambda = find_lambda(f, x0, f.(x0), 1, 1)
    hare = Enum.reduce(1..lambda, x0, fn _,hare -> f.(hare) end)
    mu = find_mu(f, x0, hare, 0)
    {lambda, mu}
  end

  # Find lambda, the cycle length
  defp find_lambda(_, tortoise, hare, _, lambda) when tortoise==hare, do: lambda
  defp find_lambda(f, tortoise, hare, power, lambda) do
    if power == lambda, do: find_lambda(f, hare, f.(hare), power*2, 1),
                      else: find_lambda(f, tortoise, f.(hare), power, lambda+1)
  end

  # Find mu, the zero-based index of the start of the cycle
  defp find_mu(_, tortoise, hare, mu) when tortoise==hare, do: mu
  defp find_mu(f, tortoise, hare, mu) do
    find_mu(f, f.(tortoise), f.(hare), mu+1)
  end
end
