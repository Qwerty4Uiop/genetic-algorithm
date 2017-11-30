defmodule GA do
  @population_size 200

  def read_file do
    File.stream!("25.txt")
    |> Stream.map(fn x -> String.split(x) |> Enum.map(&(elem(Float.parse(&1), 0))) end)
  end

  def main_process do
    [[carrying, capacity] | items] = Enum.to_list(read_file())
    sorted_items = items |> Enum.with_index(1) |> Enum.sort_by(&(Enum.at(elem(&1, 0), 2)), &>=/2) |> List.to_tuple
    initial_population(sorted_items, carrying, capacity) |> fitness_all(items) |> selection_and_crossing
  end

  def initial_population(items, carrying, capacity) do
    for _i <- 1..@population_size, do: create_individual(items, :rand.uniform(tuple_size(items)) - 1, carrying, capacity, []) |> individual_encode(tuple_size(items))
  end

  def create_individual(items, index, carrying, capacity, individual) do
    if index < tuple_size(items) and
       summary_carrying(individual ++ [elem(items, index)]) < carrying and
       summary_capacity(individual ++ [elem(items, index)]) < capacity do
          create_individual(items, index + 1, carrying, capacity, individual ++ [elem(items, index)])
    else
      individual
    end
  end

  def summary_carrying(items) do
    items
    |> Enum.map(&(Enum.at(elem(&1, 0), 0)))
    |> Enum.sum
  end

  def summary_capacity(items) do
    items
    |> Enum.map(&(Enum.at(elem(&1, 0), 1)))
    |> Enum.sum
  end

  def individual_encode(individual, item_count) do
    Enum.map(1..item_count, &(if in_set?(individual, &1), do: 1, else: 0))
  end

  def in_set?(individual, item) do
    if(is_nil(Enum.find(individual, &(elem(&1, 1) == item))), do: false, else: true)
  end

  def fitness_all(population, items) do
    population
    |> Enum.map(&Enum.zip(&1, items))
    |> Enum.map(&Enum.reduce(&1, 0, fn(x, acc) -> elem(x, 0) * Enum.at(elem(x, 1), 2) + acc end))
    |> Enum.zip(population)
    |> Enum.sort_by(&(elem(&1, 0)), &>=/2)
  end

  def fitness(individual, items) do
    individual
    |> Enum.zip(items)
    |> Enum.reduce(0, fn(x, acc) -> elem(x, 0) * Enum.at(elem(x, 1), 2) + acc end)
  end

  def selection_and_crossing(population) do
    population
    |> Enum.take(round(@population_size * 0.2))
  end
end
