extends Node2D

onready var result_label = get_node("Result")
onready var type_expr = get_node("TypeExpr")

var invalid_tokens = RegEx.new().compile("[^0-9 \\/\\*\\-\\+!]")
var operators = ["^", "*", "/", "+", "-",]
var possible_pre_unaries = ["-"]
var possible_post_unaries = ["!"]
var output_queue = []
var operator_stack = []

var eval_vals = []

var operator_key = [["+", "add", "to"], ["-", "subtract", "from"], ["*", "multiply", "by"], ["/", "divide", "by"], ["^", "raise", "to the power of"]]

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

func is_operator(operator : String):
	for i in range(operators.size()):
		if operator == operators[i]:
			return true
	return false

func precedence(operator : String):
	if operator == "^":
		return 3
	elif operator == "*" or operator == "/":
		return 2
	elif operator == "+" or operator == "-":
		return 1

func check_association(operator : String):
	if !operator_stack.empty() and is_operator(operator_stack.back()):
		if operator_stack.back() == "(":
			return
		if precedence(operator) <= precedence(operator_stack.back()):
			return 1

func calculate(a : float, b : float, operation : String):
	if operation == "^": return pow(a, b)
	if operation == "*": return a * b
	if operation == "/": return a / b
	if operation == "+": return a + b
	if operation == "-": return a - b

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
			if !operator_stack.empty() and operator_stack.back().find("x") > -1:
				output_queue.append(operator_stack.back()[0] + expression[i])
				operator_stack.pop_back()
			else:
				output_queue.append(total_token)
			
		#When all above statements are false, iterate through operators[] to check for operators
		
		#If the iterating token has been confirmed to be a valid operator,...
		if is_operator(expression[i]):
			var j = i - 1
			while (!is_operator(expression[j]) and !is_number(expression[j]) and expression[j] != "(") and j >= 0:
				j -= 1
			if (expression[j] == "(" or is_operator(expression[j])) and j >= 0 and indentify_unary(expression[i]) == -1:
				var k = i + 1
				while (!is_operator(expression[k]) or !is_number(expression[k]) or expression[k] != "(") and k < expression.length() - 1:
					k += 1
					
				if is_number(expression[k]) or expression == "(":
					operator_stack.append(expression[i] + "x")
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
			#...push it into operator_stack[]
			operator_stack.append(expression[i])
			
		#If the token is a right parenthesis,...
		if expression[i] == ")":
			#...starting from the back, transfer operators into output_queue[] until the left parenthesis becomes the last element in operator_stack[], given that operator_stack[] is not empty
			while !operator_stack.empty() and operator_stack.back() != "(":
				output_queue.append(operator_stack.pop_back())
			
			#Discard the left parenthesis when reached by while loop
			operator_stack.pop_back()
		
#		print(operator_stack)
	#After expression iteration, transfer remaining elements of operator_stack[] to output_queue[], starting from the back
	while !operator_stack.empty():
		output_queue.append(operator_stack.pop_back())
		

func evaluate_expression():
	for i in range(output_queue.size()):
		if is_number(output_queue[i]):
			eval_vals.append(output_queue[i])
			
		if is_operator(output_queue[i]):
			var val2 = float(eval_vals.pop_back())
			var val1 = float(eval_vals.pop_back())
			
			var result = calculate(val1, val2, output_queue[i])
			eval_vals.append(str(result))
		print(eval_vals)
	return eval_vals.pop_back()
			
func _ready():
#	print(output_queue)
	var a : int
	if a * a == 81:
		print(a)
	
#1.  While there are tokens to be read:
#2.        Read a token
#3.        If it's a number add it to queue
#4.        If it's an operator
#5.               While there's an operator on the top of the stack with greater precedence:
#6.                       Pop operators from the stack onto the output queue
#7.               Push the current operator onto the stack
#8.        If it's a left bracket push it onto the stack
#9.        If it's a right bracket 
#10.            While there's not a left bracket at the top of the stack:
#11.                     Pop operators from the stack onto the output queue.
#12.             Pop the left bracket from the stack and discard it
#13. While there are operators on the stack, pop them to the queue

func _on_LineEdit_text_entered(new_text):
	type_expr.text = "Your expression is:"
	operator_stack.clear()
	output_queue.clear()
	shunting_yard(new_text)
	result_label.text = "Value: " + evaluate_expression()
	print(output_queue)
	
