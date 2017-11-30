defmodule GA do
  @population_size 200

  def read_file do
    File.stream!("25.txt")
    |> Stream.map(fn x -> String.split(x) |> Enum.map(&(elem(Float.parse(&1), 0))) end)
  end

  def main_process do
    [[carrying, capacity] | items] = Enum.to_list(read_file())
    sorted_items = items |> Enum.with_index(1) |> Enum.sort_by(&(Enum.at(elem(&1, 0), 2)), &>=/2) |> List.to_tuple
    init_population = initial_population(sorted_items, carrying, capacity) |> fitness_all(items, carrying, capacity)
    result_population = life_cycle(init_population, items, carrying, capacity, 1)
    Enum.at(result_population, 0)
  end

  def life_cycle(population, items, carrying, capacity, generation_number) do
    new_pop = population
    |> selection_and_crossing(items, carrying, capacity)
    |> mutation(items, carrying, capacity)
    |> new_population
    if(check(new_pop, population) or generation_number == 100, do: new_pop, else: life_cycle(new_pop, items, carrying, capacity, generation_number + 1))
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

  def fitness_all(population, items, carrying, capacity) do
    population
    |> Enum.map(&fitness(&1,items))
    |> Enum.zip(population)
    |> Enum.map(&update_fitness(&1, items, carrying, capacity))
    |> Enum.sort_by(&(elem(&1, 0)), &>=/2)
  end

  def fitness(individual, items) do
    individual
    |> Enum.zip(items)
    |> Enum.reduce(0, fn(x, acc) -> elem(x, 0) * Enum.at(elem(x, 1), 2) + acc end)
  end

  def summary(individual, items) do
    elem(individual, 1)
    |> Enum.zip(items)
    |> Enum.reduce({0, 0}, fn(x, acc) -> {elem(x, 0) * Enum.at(elem(x, 1), 0) + elem(acc, 0), elem(x, 0) * Enum.at(elem(x, 1), 1) + elem(acc, 1)} end)
  end

  def is_valid?(individual, items, weight_limit, count_limit) do
    {carrying, capacity} = summary(individual, items)
    if(carrying <= weight_limit and capacity <= count_limit, do: true, else: false)
  end

  def update_fitness(individual, items, weight_limit, count_limit) do
    if(is_valid?(individual, items, weight_limit, count_limit), do: {elem(individual, 1) |> fitness(items), elem(individual, 1)}, else: {0.0, elem(individual, 1)})
  end

  def selection(population) do
    population
    |> Enum.take(round(@population_size * 0.2))
    |> Enum.chunk_every(2)
  end

  def crossing(individuals, items, carrying, capacity) do
    individuals
    |> Enum.map(&(List.duplicate(Enum.zip(elem(Enum.at(&1, 0), 1), elem(Enum.at(&1, 1), 1)), 2)))
    |> Enum.concat
    |> Enum.map(&Enum.map(&1, fn x -> if elem(x, 0) == elem(x, 1), do: elem(x, 0), else: :rand.uniform(1) - 1 end))
    |> fitness_all(items, carrying, capacity)
  end

  def selection_and_crossing(population, items, carrying, capacity) do
    population ++ (population |> selection |> crossing(items, carrying, capacity))
  end

  def mutation(population, items, weight_limit, count_limit) do
    index = :rand.uniform(Enum.count(population)) - 1
    population
    |> List.update_at(index, &({elem(&1, 0), Enum.map(elem(&1, 1), fn x -> rem(x + 1, 2) end)} |> update_fitness(items, weight_limit, count_limit)))
  end

  def new_population(population) do
    population |> Enum.slice(round(@population_size * 0.2)..round(@population_size * 1.2) - 1) |> Enum.sort_by(&elem(&1, 0), &>=/2)
  end

  def check(new_population, old_population) do
    if(abs(elem(Enum.at(new_population, 0), 0) / elem(Enum.at(old_population, 0), 0) - 1) < 0.1, do: true, else: false)
  end
end
