extends GutTest

var a = 0

func __test_dispatch_reciever(val):
#	OS.delay_msec(50)
	a = val
#	print("~~~~~~~~Value set: " + str(val))

func test_dispatch_caller():
	a = 0
	var el := ExecutionLoop.new()
	if true:
		el.assign_instance(self)
		var a = "__test_dispatch_reciever"
		var b = 3
		el.call_dispatched(a, b)
	el.sync()
	assert_eq(a, 3)
	a = 0

func test_dispatch():
	a = 0
	var el := ExecutionLoop.new()
	el.assign_instance(self)
	el.call_dispatched("__test_dispatch_reciever", 5)
	el.sync()
	assert_eq(a, 5)
	a = 0

func test_sync():
	a = 0
	var el := ExecutionLoop.new()
	el.assign_instance(self)
	el.call_return("__test_dispatch_reciever", 7)
	el.sync()
	assert_eq(a, 7)
	a = 0
	el.call_sync("__test_dispatch_reciever", 11)
	el.sync()
	assert_eq(a, 11)
	a = 0
