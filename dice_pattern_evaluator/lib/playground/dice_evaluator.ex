defmodule Playground.DiceEvaluator do
  @moduledoc """
  Evaluates all dice expressions in a random table entry.

  "You discover (5d6) gold pieces and (1d3) minor magical artifacts made of ebony and bone."
  => "You discover (21) gold pieces and (2) minor magical artifacts made of ebony and bone."
  """

  @type table_entry :: String.t()
  @type evaluated_table_entry :: String.t()

  @diceExpression ~r/(\d*)d(\d+|%)/i

  @doc """
  Evaluates all die expressions in a string with the following pattern:

  2               d             20
  ^               ^             ^
  times to roll   dice symbol   die faces

  The above example says to roll a 20-sided die two times.

  Examples:

    iex> Playground.DiceEvaluator.evaluate("d1")
    "1"

    iex> Playground.DiceEvaluator.evaluate("1d1")
    "1"

    iex> Playground.DiceEvaluator.evaluate("10d1")
    "10"

    iex> Playground.DiceEvaluator.evaluate("You discover (1d1) gold pieces.")
    "You discover (1) gold pieces."
  """
  @spec evaluate(table_entry()) :: evaluated_table_entry()
  def evaluate(table_entry) do
    @diceExpression
    |> Regex.scan(table_entry)
    |> Enum.map(&cast_dice_terms_to_int/1)
    |> Enum.map(&evaluate_dice/1)
    |> Enum.reduce(table_entry, &replace_dice_expression_with_result(&1, &2))
  end

  defp cast_dice_terms_to_int([dice_expression, "", die_faces]),
    do: cast_dice_terms_to_int([dice_expression, "1", die_faces])

  defp cast_dice_terms_to_int([dice_expression, times_to_roll, "%"]),
    do: cast_dice_terms_to_int([dice_expression, times_to_roll, "100"])

  defp cast_dice_terms_to_int([dice_expression, times_to_roll, die_faces]),
    do: [dice_expression, String.to_integer(times_to_roll), String.to_integer(die_faces)]

  defp evaluate_dice([dice_expression, 0, _die_faces]), do: {dice_expression, 0}
  defp evaluate_dice([dice_expression, _times_to_roll, 0]), do: {dice_expression, 0}

  defp evaluate_dice([dice_expression, times_to_roll, die_faces]) do
    dice_result =
      for _ <- 1..times_to_roll, reduce: 0 do
        acc -> acc + :rand.uniform(die_faces)
      end

    {dice_expression, dice_result}
  end

  @spec replace_dice_expression_with_result(tuple(), table_entry()) :: table_entry()
  defp replace_dice_expression_with_result({dice_expression, dice_result}, table_entry),
    do: String.replace(table_entry, dice_expression, to_string(dice_result))
end
