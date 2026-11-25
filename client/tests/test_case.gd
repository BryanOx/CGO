class_name TestCase
extends RefCounted

var failures: Array[String] = []

func expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func run() -> void:
	assert(false, "Concrete tests must override run()")
