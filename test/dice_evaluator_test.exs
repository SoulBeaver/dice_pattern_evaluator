defmodule DiceEvaluatorTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest Playground.DiceEvaluator

  alias Playground.DiceEvaluator

  property "Rolling a die is always within its expected bounds" do
    check all(
            times_to_roll <- positive_integer(),
            die_faces <- positive_integer()
          ) do
      dice_expression = "#{times_to_roll}d#{die_faces}"
      min_bound = times_to_roll
      max_bound = times_to_roll * die_faces

      dice_result = DiceEvaluator.evaluate(dice_expression) |> String.to_integer()

      # IO.inspect("Roll (#{dice_expression}) value must be between #{min_bound} and #{max_bound}, and was #{dice_result}")

      assert dice_result >= min_bound and dice_result <= max_bound,
             "Expected roll (#{dice_expression}) value between #{min_bound} and #{max_bound}, but got #{dice_result} instead"
    end
  end

  test "Evaluator can interpret 1d%" do
    result = DiceEvaluator.evaluate("d%") |> String.to_integer()

    assert result >= 1 and result <= 100
  end
end
