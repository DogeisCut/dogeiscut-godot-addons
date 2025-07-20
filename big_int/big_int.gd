extends RefCounted
class_name BigInt

#TODO: comparisons, power, negatives, subtraction, other math ops, notation (scientific, AA, etc)

var data: PackedInt64Array
var sign = 1
const BASE = 1e7

func _init(value = 0):
	data = PackedInt64Array()
	if typeof(value) == TYPE_INT:
		data = _from_int(value)
	#elif typeof(value) == TYPE_STRING:
	#	_from_string(value)
	else:
		push_error("Unsupported type for BigInt initialization")

func _from_int(n: int):
	if (n < int(1e7)):
		return [n];
	if (n < int(1e14)):
		@warning_ignore("integer_division")
		return [n % int(1e7), floor(n / int(1e7))];
	@warning_ignore("integer_division")
	return [n % int(1e7), floor(n / int(1e7)) % int(1e7), floor(n / int(1e14))]

func trim() -> BigInt:
	var i = len(self.data) - 1
	while i > 0 and self.data[i] == 0:
		i -= 1
	self.data.resize(i + 1)
	return self

func duplicate() -> BigInt:
	var new_data = self.data.duplicate()
	var result = BigInt.new()
	result.data = new_data
	return result

static func add(a: BigInt, b: BigInt) -> BigInt:
	var length_a = len(a.data)
	var length_b = len(b.data)
	if length_b>length_a:
		var temp = length_a
		length_a = length_b
		length_b = temp
		temp = a
		a = b
		b = temp
	var result = BigInt.new()
	result.data.resize(length_a)
	var carry = 0
	var sum = 0
	for i in range(0, length_b, 1):
		sum = a.data[i] + b.data[i] + carry;
		carry = 1 if (sum >= BASE) else 0
		result.data[i] = sum - (carry * BASE);
	var i = length_b
	while(i < length_a):
		sum = a.data[i] + carry;
		carry = 1 if (sum == BASE) else 0;
		result.data[i] = sum - (carry * BASE);
		i+=1
	if (carry > 0): result.data.append(carry);
	return result

func plus(b: BigInt) -> BigInt:
	self.data = add(self, b).data
	return self

static func subtract(a: BigInt, b: BigInt) -> BigInt:
	var result = BigInt.new()
	result.data.resize(len(a.data))
	var borrow = 0
	for i in range(len(a.data)):
		var diff = a.data[i] - (b.data[i] if i < len(b.data) else 0) - borrow
		if diff < 0:
			diff += BASE
			borrow = 1
		else:
			borrow = 0
		result.data[i] = diff
	return result.trim()

func minus(b: BigInt) -> BigInt:
	self.data = subtract(self, b).data
	return self

static func multiply(a: BigInt, b: BigInt) -> BigInt:
	var length_a = len(a.data)
	var length_b = len(b.data)
	var length = length_a + length_b
	var result = BigInt.new()
	result.data.resize(length)
	var product = 0
	var carry = 0
	var a_i = 0;
	var b_j = 0;
	for i in range(0, length_a, 1):
		a_i = a.data[i];
		for j in range(0, length_b, 1):
			b_j = b.data[j];
			product = a_i * b_j + result.data[i + j];
			carry = floor(product / BASE);
			result.data[i + j] = product - (carry * BASE);
			result.data[i + j + 1] += carry;
	result.trim()
	return result

func times(b: BigInt) -> BigInt:
	self.data = multiply(self, b).data
	return self

static func divide(a: BigInt, b: BigInt) -> BigInt:
	if b.data == PackedInt64Array() or (len(b.data) == 1 and b.data[0] == 0):
		push_error("Division by zero")
		return BigInt.new()
	var result = BigInt.new()
	var remainder = BigInt.new()
	for i in range(len(a.data) - 1, -1, -1):
		remainder.data.insert(0, a.data[i])
		remainder.trim()
		var quotient = 0
		while compare_greater(remainder, b) or compare_equal(remainder, b):
			remainder = subtract(remainder, b)
			quotient += 1
		result.data.insert(0, quotient)
	return result.trim()

func divided_by(b: BigInt) -> BigInt:
	self.data = divide(self, b).data
	return self

static func exponentiate(a: BigInt, b: BigInt) -> BigInt:
	var result = BigInt.new(1)
	var base = a
	var exponent = b
	while len(exponent.data) > 0 and exponent.data[0] > 0:
		if exponent.data[0] % 2 == 1:
			result = multiply(result, base)
		base = multiply(base, base)
		exponent = divide(exponent, BigInt.new(2))
	return result

func to_the_power_of(b: BigInt) -> BigInt:
	self.data = exponentiate(self, b).data
	return self

static func compare_greater(a: BigInt, b: BigInt) -> bool:
	if len(a.data) != len(b.data):
		return len(a.data) > len(b.data)
	for i in range(len(a.data) - 1, -1, -1):
		if a.data[i] != b.data[i]:
			return a.data[i] > b.data[i]
	return false

func is_greater_than(b: BigInt) -> bool:
	return compare_greater(self, b)

static func compare_lesser(a: BigInt, b: BigInt) -> bool:
	if len(a.data) != len(b.data):
		return len(a.data) < len(b.data)
	for i in range(len(a.data) - 1, -1, -1):
		if a.data[i] != b.data[i]:
			return a.data[i] < b.data[i]
	return false

func lesser_than(b: BigInt) -> bool:
	return compare_lesser(self, b)

static func compare_equal(a: BigInt, b: BigInt) -> bool:
	if len(a.data) != len(b.data):
		return false
	for i in range(len(a.data)):
		if a.data[i] != b.data[i]:
			return false
	return true

func equal_to(b: BigInt) -> bool:
	return compare_equal(self, b)

func _to_string() -> String:
	var v = self.data
	var l = len(self.data)
	var str = str(v[l-1])
	var zeros = "0000000"
	var digit = ""
	var i = l-2
	
	while (i >= 0):
		digit = str(v[i])
		str += zeros.substr(len(digit)) + digit;
		i -= 1
	#var sign
	return str;
