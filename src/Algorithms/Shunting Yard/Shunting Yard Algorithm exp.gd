extends Node2D # Version 1.4.0 (Friday, March 17, 2023)

# Refers to nodes in "Shunting Yard Algorithm.tscn"
onready var result_label = get_node("Result")
onready var type_expr = get_node("TypeExpr")

# Operators that are currently supported by this version of the algorithm
var operators = ["^", "*", "/", "+", "-"]
# Possible operators that are unaries that come before their operand
var possible_pre_unaries = ["-"]
# Possible operators that are unaries that come after their operand [MIGHT BE PRESENT IN FUTURE VERSION]
var possible_post_unaries = ["!"]

# Stores the parsed expression after the algorithm finishes
var output_queue = []
# Store operators in a certain way in accordance with the algorithm
var operator_stack = []
# Used to help evaluate expression after parsing (used with output_queue[])
var eval_vals = []

# Array that will be used to explain the process of solving the expression [MAYBE IN FUTURE VERSION?]
var operator_key = [["+", "add", "to"], ["-", "subtract", "from"], ["*", "multiply", "by"], ["/", "divide", "by"], ["^", "raise", "to the power of"]]
var explanations = []
var expressions = []

var original_expression:String
#Is the string provided just a number in a string?
func is_number(number : String):
	if float(number) == 0 or float(number) == -0:
		if number == "0":
			return true
		else:
			return false
	elif typeof(float(number)) == TYPE_REAL:
		return true
	else:
		return false

# Is the String provided a mathematical operator supported by this algorithm?
func is_operator(operator : String):
	for i in range(operators.size()):
		if operator == operators[i]:
			return true
	return false

# Determines precedence of an operator as defined by the Order of Operations
func precedence(operator : String):
	if operator == "^":
		return 3
	elif operator == "*" or operator == "/":
		return 2
	elif operator == "+" or operator == "-":
		return 1

# Compares operators. Useful to determine which operations should be done first
# in accordance with the Order of Operations
func check_association(operator : String):
	if !operator_stack.empty() and is_operator(operator_stack.back()):
		if operator_stack.back() == "(":
			return
		if precedence(operator) <= precedence(operator_stack.back()):
			return 1

# To help calculate two_operand operations
func calculate(a:float, b:float, operation:String):
	if operation == "^": return pow(a, b)
	if operation == "*": return a * b
	if operation == "/": return a / b
	if operation == "+": return a + b
	if operation == "-": return a - b

# Can the token be a unary operator?
func indentify_unary(token : String):
	for i in range(possible_pre_unaries.size()):
		if token == possible_pre_unaries[i]:
			return -1
	for i in range(possible_post_unaries.size()):
		if token == possible_post_unaries[i]:
			return 1
	return 0

#SHUNTING YARD ALGORITHM
#Three things needed:
#	Expression to parse, taken in to function shunting_yard() as an argument
#	Operator Stack, which is an array
#	Output queue, which is an array
func shunting_yard(expression : String):
	#Removing whitespace before parsing
	expression  = expression.replace(" ", "")
	original_expression = expression
	
	#Error checks:
	## Check is grouping elements () or [] come in their appropriate pairs
	if expression.count("(", 0, 0) != expression.count(")") or expression.count("[", 0, 0) != expression.count("]"):
		return "Expression Error: Missing complete pair(s) of parentheses or brackets"
#	assert(expression.count("(", 0, 0) == expression.count(")", 0, 0), "Missing complete pair of parentheses or brackets")
#	assert(expression.count("[", 0, 0) == expression.count("]", 0, 0), "Missing complete pair of parentheses or brackets")
	#For each token in expression:
	for i in range(expression.length()):
		#If the iterating token is a number,...
		if is_number(expression[i]):
			var total_token = expression[i]
			#...push token to output_queue[]
			if is_number(expression[i - 1]) and i - 1 >= 0:
				continue 
			var j = i + 1
			#Sometimes an expression will have a multi-digit number. This line interprets them as such before being pushed to output_queue[]
			if j < expression.length():
				if is_number(expression[j]):
					while is_number(expression[j]) and j < expression.length():
						total_token += expression[j]
						if j == expression.length() - 1:
							break
						else:
							j += 1
			# For preceding unary operator support
			if !operator_stack.empty() and operator_stack.back().find("?") > -1:
				if operator_stack.back().find("?") > 0:
					output_queue.append(operator_stack.back().replace("?", total_token))
					operator_stack.pop_back()
			else:
				output_queue.append(total_token)
			
		#When all above statements are false, iterate through operators[] to check for operators
		
		#If the iterating token has been confirmed to be a valid operator,...
		if is_operator(expression[i]):
			var j = i - 1
			while (!is_operator(expression[j]) and !is_number(expression[j]) and expression[j] != "(" and expression[j] != ")" and expression[j] != "[" and expression[j] != "]") and j > 0:
				j -= 1
			if j < 0:
				j = 0
			if (expression[j] == "(" or expression[j] == "[" or is_operator(expression[j])) or !is_number(expression[j]) and j >= 0 and indentify_unary(expression[j]) != 0:
				# Used to identify a unary operator that precedes its operand (as in -5)
				if indentify_unary(expression[i]) == -1:
					var k = i + 1
					while (!is_operator(expression[k]) or !is_number(expression[k]) or expression[k] != "(" or expression[k] != "[") and k < expression.length() - 1:
						k += 1
					if is_number(expression[k]) or expression == "(" or expression == "[":
						operator_stack.append(expression[i] + "?")
			else:
				#CHECKING FOR OPERATOR ASSOCIATION/PRECEDENCE
				#While the last element of operator_stack[] is an operation of higher precedence that the iterating token,...
				while check_association(expression[i]) == 1:
					#...transfer the last element of operator_stack[] to output_queue
					output_queue.append(operator_stack.pop_back())
				
				#Push the iterating token into operator_stacks[]
				operator_stack.append(expression[i])
				
					
		#If the token is whitespace,...
		if expression[i] == " ":
			continue
			
		#If the token is a left parenthesis,...
		if expression[i] == "(":
			if expression[i + 1] == ")":
				return "Expression Error: empty grouping element"
			else:
				#...push it into operator_stack[]
				operator_stack.append(expression[i])
		elif expression[i] == "[":
			if expression[i + 1] == "]":
				return "Expression Error: empty grouping element"
			else:
				#...push it into operator_stack[]
				operator_stack.append(expression[i])
		#If the token is a right parenthesis,...
		if expression[i] == ")":
			#...starting from the back, transfer operators into output_queue[] until the left parenthesis becomes the last element in operator_stack[], given that operator_stack[] is not empty
			while !operator_stack.empty() and operator_stack.back() != "(":
				output_queue.append(operator_stack.pop_back())
		elif expression[i] == "]":
			while !operator_stack.empty() and operator_stack.back() != "[":
				output_queue.append(operator_stack.pop_back())
			#Discard the left parenthesis when reached by while loop
			operator_stack.pop_back()
	#After expression iteration, transfer remaining elements of operator_stack[] to output_queue[], starting from the back
	while !operator_stack.empty():
		output_queue.append(operator_stack.pop_back())
	
	print(output_queue)	

func evaluate_expression():
	for i in range(output_queue.size()):
		# All numbers go into output_queue, starting from the 0th index
		if is_number(output_queue[i]):
			eval_vals.append(output_queue[i])
			
		# Upon meeting an operator in the output queue, the last two number of eval_vals[] are removed
		# and are applied to the two_operand operator in question.
		if is_operator(output_queue[i]):
			var val2 = float(eval_vals.pop_back())
			var val1 = float(eval_vals.pop_back())
			
			var result = calculate(val1, val2, output_queue[i])
			eval_vals.append(str(result))
	return eval_vals.pop_back()
			

# UPDATE ON THIS: This signal will be retained (it's not necessary to get rid of it)
func _on_LineEdit_text_entered(new_text):
	type_expr.text = "Your expression is:"
	operator_stack.clear()
	output_queue.clear()
	shunting_yard(new_text)
	if typeof(shunting_yard(new_text)) == TYPE_STRING:
		result_label.text = shunting_yard(new_text)
	else:
		result_label.text = "Value: " + evaluate_expression()
