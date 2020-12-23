# Shunting Yard Algorithm Most Recent Version: 1.3.0

## How to use the Shunting Yard Algorithm in the scene:

When running the scene `Shunting Yard Algorithm.tscn` in the Godot Editor, there is a LineEdit field where you can type in the expression you want the algorithm to parse. An
additional function `evaluate_expression()`in the script `Shunting Yard Algorithm.gd` is used to evaluate the expression after it has been parsed by `shunting_yard(expression)`.

**The following are not supported by the algorithm at the moment:**
* Unary operators
* Functions
* Implicit Multiplication (`A(B)`)
