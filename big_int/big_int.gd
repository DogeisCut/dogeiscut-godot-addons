extends RefCounted
class_name BigInt

## A custom class for handling arbitrarily large integers, overcoming Godot's 64-bit integer limits.
##
## This class stores large numbers as an array of smaller integers, where each element represents a 'digit'
## in a custom base ([constant BASE]). This allows for calculations beyond the standard [code]int[/code] type.
##
## [b]Note:[/b] This implementation currently supports positive integers only for most operations.
## Comparisons, power, negatives, subtraction, and other math operations are planned for future development.
##
## @experimental

#TODO: comparisons, power, negatives, subtraction, other math ops, notation (scientific, AA, etc)

## The internal representation of the large integer as a [PackedInt64Array].
## Each element in the array is a 'digit' in base [constant BASE].
var _data: PackedInt64Array
## The sign of the BigInt. 1 for positive, -1 for negative.
## Currently, most operations assume positive numbers.
var _sign = 1
## The base used for storing digits in the [member _data] array.
## This value is set to `10^7` (10,000,000) to efficiently store large numbers.
const BASE = 1e7

## Initializes a new [BigInt] instance.
##
## The BigInt can be initialized from an integer value.
## String initialization is currently commented out but planned.
##
## [param value]: The initial value for the BigInt. Can be an [int].
func _init(value = 0):
	_data = PackedInt64Array()
	if typeof(value) == TYPE_INT:
		_data = _from_int(value)
	#elif typeof(value) == TYPE_STRING:
	#	_from_string(value)
	else:
		push_error("Unsupported type for BigInt initialization")

## Converts a standard Godot [int] into the [BigInt] internal [member _data] format.
##
## This function breaks down the integer into segments based on [constant BASE].
##
## [param n]: The integer to convert.
## Returns a [PackedInt64Array] representing the integer.
func _from_int(n: int):
	if (n < int(1e7)):
		return [n];
	if (n < int(1e14)):
		@warning_ignore("integer_division")
		return [n % int(1e7), floor(n / int(1e7))];
	@warning_ignore("integer_division")
	return [n % int(1e7), floor(n / int(1e7)) % int(1e7), floor(n / int(1e14))]

## Removes leading zeros from the [member _data] array.
##
## This ensures the [BigInt] representation is as compact as possible.
## For example, [code][0, 0, 123][/code] would become [code][123][/code].
##
## Returns the trimmed [BigInt] instance (self).
func trim() -> BigInt:
	var i = len(self._data) - 1
	while i > 0 and self._data[i] == 0:
		i -= 1
	self._data.resize(i + 1)
	return self

## Creates a duplicate of the current [BigInt] instance.
##
## This performs a deep copy of the [member _data] array.
##
## Returns a new [BigInt] instance with the same value as the original.
func duplicate() -> BigInt:
	var new_data = self._data.duplicate()
	var result = BigInt.new()
	result._data = new_data
	return result

## Statically adds two [BigInt] numbers.
##
## This function takes two [BigInt] instances and returns a new [BigInt] instance
## representing their sum. It handles carries between 'digits' based on [constant BASE].
##
## [param a]: The first [BigInt] operand.
## [param b]: The second [BigInt] operand.
## Returns a new [BigInt] representing the sum of [param a] and [param b].
static func add(a: BigInt, b: BigInt) -> BigInt:
	var length_a = len(a._data)
	var length_b = len(b._data)
	# Ensure 'a' is the longer number for simpler iteration
	if length_b > length_a:
		var temp = length_a
		length_a = length_b
		length_b = temp
		temp = a
		a = b
		b = temp
	var result = BigInt.new()
	result._data.resize(length_a)
	var carry = 0
	var sum = 0
	for i in range(0, length_b, 1):
		sum = a._data[i] + b._data[i] + carry;
		carry = 1 if (sum >= BASE) else 0
		result._data[i] = sum - (carry * BASE);
	var i = length_b
	while(i < length_a):
		sum = a._data[i] + carry;
		carry = 1 if (sum == BASE) else 0;
		result._data[i] = sum - (carry * BASE);
		i+=1
	if (carry > 0): result._data.append(carry);
	return result

## Adds another [BigInt] to the current instance, modifying itself.
##
## This is an instance method that calls the static [method add] and updates
## the current instance's [member _data] with the result.
##
## [param b]: The [BigInt] to add to this instance.
## Returns the current [BigInt] instance after the addition.
func plus(b: BigInt) -> BigInt:
	self._data = add(self, b)._data
	return self

## Statically subtracts one [BigInt] from another.
##
## This function takes two [BigInt] instances and returns a new [BigInt] instance
## representing their difference. It handles borrows between 'digits' based on [constant BASE].
##
## [param a]: The [BigInt] from which to subtract.
## [param b]: The [BigInt] to subtract.
## Returns a new [BigInt] representing the difference (`a - b`).
static func subtract(a: BigInt, b: BigInt) -> BigInt:
	var result = BigInt.new()
	result._data.resize(len(a._data))
	var borrow = 0
	for i in range(len(a._data)):
		var diff = a._data[i] - (b._data[i] if i < len(b._data) else 0) - borrow
		if diff < 0:
			diff += BASE
			borrow = 1
		else:
			borrow = 0
		result._data[i] = diff
	return result.trim()

## Subtracts another [BigInt] from the current instance, modifying itself.
##
## This is an instance method that calls the static [method subtract] and updates
## the current instance's [member _data] with the result.
##
## [param b]: The [BigInt] to subtract from this instance.
## Returns the current [BigInt] instance after the subtraction.
func minus(b: BigInt) -> BigInt:
	self._data = subtract(self, b)._data
	return self

## Statically multiplies two [BigInt] numbers.
##
## This function takes two [BigInt] instances and returns a new [BigInt] instance
## representing their product. It implements a basic long multiplication algorithm.
##
## [param a]: The first [BigInt] operand.
## [param b]: The second [BigInt] operand.
## Returns a new [BigInt] representing the product of [param a] and [param b].
static func multiply(a: BigInt, b: BigInt) -> BigInt:
	var length_a = len(a._data)
	var length_b = len(b._data)
	var length = length_a + length_b
	var result = BigInt.new()
	result._data.resize(length)
	var product = 0
	var carry = 0
	var a_i = 0;
	var b_j = 0;
	for i in range(0, length_a, 1):
		a_i = a._data[i];
		for j in range(0, length_b, 1):
			b_j = b._data[j];
			product = a_i * b_j + result._data[i + j];
			carry = floor(product / BASE);
			result._data[i + j] = product - (carry * BASE);
			result._data[i + j + 1] += carry;
	result.trim()
	return result

## Multiplies the current [BigInt] instance by another [BigInt], modifying itself.
##
## This is an instance method that calls the static [method multiply] and updates
## the current instance's [member _data] with the result.
##
## [param b]: The [BigInt] to multiply this instance by.
## Returns the current [BigInt] instance after the multiplication.
func times(b: BigInt) -> BigInt:
	self._data = multiply(self, b)._data
	return self

## Statically divides one [BigInt] by another.
##
## This function performs integer division of [param a] by [param b] and returns
## a new [BigInt] instance representing the quotient.
##
## [param a]: The dividend [BigInt].
## [param b]: The divisor [BigInt].
## Returns a new [BigInt] representing the quotient (`a / b`).
static func divide(a: BigInt, b: BigInt) -> BigInt:
	if b._data == PackedInt64Array() or (len(b._data) == 1 and b._data[0] == 0):
		push_error("Division by zero")
		return BigInt.new()
	var result = BigInt.new()
	var remainder = BigInt.new()
	# Iterate from the most significant digit to the least significant
	for i in range(len(a._data) - 1, -1, -1):
		# Prepend the current digit to the remainder
		remainder._data.insert(0, a._data[i])
		remainder.trim() # Remove any leading zeros that might appear
		var quotient = 0
		# Repeatedly subtract the divisor from the remainder
		while compare_greater(remainder, b) or compare_equal(remainder, b):
			remainder = subtract(remainder, b)
			quotient += 1
		# Insert the calculated quotient digit at the beginning of the result
		result._data.insert(0, quotient)
	return result.trim()

## Divides the current [BigInt] instance by another [BigInt], modifying itself.
##
## This is an instance method that calls the static [method divide] and updates
## the current instance's [member _data] with the result.
##
## [param b]: The [BigInt] to divide this instance by.
## Returns the current [BigInt] instance after the division.
func divided_by(b: BigInt) -> BigInt:
	self._data = divide(self, b)._data
	return self

## Statically calculates the exponentiation of a [BigInt] base to a [BigInt] exponent.
##
## This function computes `a^b` using exponentiation by squaring (binary exponentiation).
##
## [param a]: The base [BigInt].
## [param b]: The exponent [BigInt].
## Returns a new [BigInt] representing the result of `a^b`.
static func exponentiate(a: BigInt, b: BigInt) -> BigInt:
	var result = BigInt.new(1)
	var base = a.duplicate() # Duplicate to avoid modifying the original base
	var exponent = b.duplicate() # Duplicate to avoid modifying the original exponent
	while len(exponent._data) > 0 and exponent._data[0] > 0: # Check if exponent is greater than 0
		if exponent._data[0] % 2 == 1: # If exponent is odd
			result = multiply(result, base)
		base = multiply(base, base)
		exponent = divide(exponent, BigInt.new(2))
	return result

## Raises the current [BigInt] instance to the power of another [BigInt], modifying itself.
##
## This is an instance method that calls the static [method exponentiate] and updates
## the current instance's [member _data] with the result.
##
## [param b]: The [BigInt] exponent.
## Returns the current [BigInt] instance after the exponentiation.
func to_the_power_of(b: BigInt) -> BigInt:
	self._data = exponentiate(self, b)._data
	return self

## Statically compares if the first [BigInt] is strictly greater than the second.
##
## [param a]: The first [BigInt] for comparison.
## [param b]: The second [BigInt] for comparison.
## Returns [code]true[/code] if [param a] > [param b], [code]false[/code] otherwise.
static func compare_greater(a: BigInt, b: BigInt) -> bool:
	if len(a._data) != len(b._data):
		return len(a._data) > len(b._data)
	for i in range(len(a._data) - 1, -1, -1):
		if a._data[i] != b._data[i]:
			return a._data[i] > b._data[i]
	return false

## Checks if the current [BigInt] instance is strictly greater than another [BigInt].
##
## [param b]: The [BigInt] to compare against.
## Returns [code]true[/code] if this instance > [param b], [code]false[/code] otherwise.
func is_greater_than(b: BigInt) -> bool:
	return compare_greater(self, b)

## Statically compares if the first [BigInt] is strictly less than the second.
##
## [param a]: The first [BigInt] for comparison.
## [param b]: The second [BigInt] for comparison.
## Returns [code]true[/code] if [param a] < [param b], [code]false[/code] otherwise.
static func compare_lesser(a: BigInt, b: BigInt) -> bool:
	if len(a._data) != len(b._data):
		return len(a._data) < len(b._data)
	for i in range(len(a._data) - 1, -1, -1):
		if a._data[i] != b._data[i]:
			return a._data[i] < b._data[i]
	return false

## Checks if the current [BigInt] instance is strictly less than another [BigInt].
##
## [param b]: The [BigInt] to compare against.
## Returns [code]true[/code] if this instance < [param b], [code]false[/code] otherwise.
func lesser_than(b: BigInt) -> bool:
	return compare_lesser(self, b)

## Statically compares if two [BigInt] numbers are equal.
##
## [param a]: The first [BigInt] for comparison.
## [param b]: The second [BigInt] for comparison.
## Returns [code]true[/code] if [param a] == [param b], [code]false[/code] otherwise.
static func compare_equal(a: BigInt, b: BigInt) -> bool:
	if len(a._data) != len(b._data):
		return false
	for i in range(len(a._data)):
		if a._data[i] != b._data[i]:
			return false
	return true

## Checks if the current [BigInt] instance is equal to another [BigInt].
##
## [param b]: The [BigInt] to compare against.
## Returns [code]true[/code] if this instance == [param b], [code]false[/code] otherwise.
func equal_to(b: BigInt) -> bool:
	return compare_equal(self, b)

## Converts the [BigInt] to its [String] representation.
##
## This method reconstructs the full number string from the internal [member _data] array,
## ensuring correct padding with leading zeros for each 'digit' segment.
##
## Returns a [String] representing the BigInt.
func _to_string() -> String:
	var v = self._data
	var l = len(self._data)
	if l == 0: # Handle empty data (e.g., from division by zero)
		return "0"
	var str_val = str(v[l-1])
	var zeros = "0000000" # 7 zeros for BASE 1e7
	var digit = ""
	var i = l-2
	
	while (i >= 0):
		digit = str(v[i])
		str_val += zeros.substr(len(digit)) + digit;
		i -= 1
	#var sign # Sign handling needs to be implemented for negative numbers
	return str_val;
