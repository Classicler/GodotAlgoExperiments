# GodotAlgoExperiments
A repository for the experimentation of Algorithms in the Godot game engine

# Current Stable Version: 1.0.0
## About
Godot is a free, open source game engine, allowing for many opportunities for the community to help contribute to it. GodotAlgoExperiments uses the Godot game engine to test
various algorithms, like the Shunting Yard Algorithm for properly calculating a math expression from a String data type.

## Algorithms Added by Repository Version
### Version 1.0.0
**Shunting Yard** -- used to parse mathematical expressions using postfix notation:

2 * (8 + 9)^2 / 4 - 5 <- This is an expression written in infix notation where operands are placed *in between* the numbers they operate on. The Shunting Yard algorithm takes this in

2 8 9 + 2 ^ * 4 / 5 - <- This is the same expression written in postfix notation where operands are placed *after* the numbers they operate on. The Shunting Yard algorithm changes the first expression into the second one.

Both expressions, by the way, equal 139.5.

## How to Contribute
Just like the Godot game engine, GodotAlgoExperiments is protected under the MIT license. As a result, this repository is free and open source just like Godot. You can download the files in this repository, open them directly into the Godot game engine, and edit away!
