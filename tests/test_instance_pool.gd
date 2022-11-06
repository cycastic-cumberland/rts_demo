extends GutTest

var is_ready := false
onready var tree := get_tree()

func _ready():
	is_ready = true

func result_extract(res: Future):
	return res.get_value().name

func result_wait(future: Future, expected: String):
	while not future.is_available(): yield(tree, "idle_frame")
	assert_eq(result_extract(future), expected, "Unexpected Future value")

func future_create(sname: String):
	var ser := Serializable.new()
	ser.name = sname
	return ser

func test_future_instance():
	assert_eq(Future.new().is_legit(), false, "Unexpected legibility")

func test_create_pool_auto_free():
	assert_eq(is_ready, true, "Node not yet initialized")
	var expected := "UnageBunga"
	var pool_name := "Creative_name_42069"
	var pool := InstancePool.create_work_pool(pool_name, true)
	assert_eq(pool.pool_name, pool_name, "Unexpected pool's name")
	var future1 := pool.queue_job(funcref(self, "future_create"), [expected])
	var future2 := pool.queue_job(funcref(self, "future_create"), [expected + "U"])
	var future3 := pool.queue_job(funcref(self, "future_create"), [expected + "UwU"])
	assert_eq(future1.is_legit(), true, "Future is not legit")
	assert_eq(future2.is_legit(), true, "Future is not legit")
	assert_eq(future3.is_legit(), true, "Future is not legit")
	assert_eq(pool.get_queued_count(), 3, "Mismatched pool size")
	result_wait(future1, expected)
	result_wait(future2, expected + "U")
	result_wait(future3, expected + "UwU")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	assert_eq(InstancePool.get_pool_size(), 0, "Unexpected pool's size")

func test_create_pool_no_free():
	assert_eq(is_ready, true, "Node not yet initialized")
	var expected := "UnageBunge"
	var pool_name := "CreativeName69420"
	var pool := InstancePool.create_work_pool(pool_name, false)
	assert_eq(pool.pool_name, pool_name, "Unexpected pool's name")
	var future1 := pool.queue_job(funcref(self, "future_create"), [expected])
	var future2 := pool.queue_job(funcref(self, "future_create"), [expected + "U"])
	assert_eq(future1.is_legit(), true, "Future is not legit")
	assert_eq(future2.is_legit(), true, "Future is not legit")
	assert_eq(pool.get_queued_count(), 2, "Mismatched pool size")
	result_wait(future1, expected)
	result_wait(future2, expected + "U")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	assert_eq(InstancePool.get_pool_size(), 1, "Unexpected pool's size")
	var future3 := pool.queue_job(funcref(self, "future_create"), [expected + "UwU"])
	assert_eq(future3.is_legit(), true, "Future is not legit")
	assert_eq(pool.get_queued_count(), 1, "Mismatched pool size")
	result_wait(future3, expected + "UwU")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	InstancePool.erase_work_pool(pool.get_instance_id())
	assert_eq(InstancePool.get_pool_size(), 0, "Unexpected pool's size")

func test_future_quick():
	assert_eq(is_ready, true, "Node not yet initialized")
	var expected := "UnageBungu"
	var future := InstancePool.queue_job(funcref(self, "future_create"), [expected])
	assert_eq(InstancePool.get_pool_size(), 1, "Unexpected pool's size")
	assert_eq(future.is_legit(), true, "Future is not legit")
	result_wait(future, expected)
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	assert_eq(InstancePool.get_pool_size(), 0, "Unexpected pool's size")

func test_multipools():
	assert_eq(is_ready, true, "Node not yet initialized")
	var pool1 := InstancePool.create_work_pool("Pool1", false)
	var pool2 := InstancePool.create_work_pool("Pool2", false)
	var pool3 := InstancePool.create_work_pool("Pool3", false)
	assert_eq(InstancePool.get_pool_size(), 3, "Unexpected pool's size")
	InstancePool.erase_work_pool(pool3.get_instance_id())
	assert_eq(InstancePool.get_pool_size(), 2, "Unexpected pool's size")
	InstancePool.erase_work_pool(pool2.get_instance_id())
	assert_eq(InstancePool.get_pool_size(), 1, "Unexpected pool's size")
	InstancePool.erase_work_pool(pool1.get_instance_id())
	assert_eq(InstancePool.get_pool_size(), 0, "Unexpected pool's size")
