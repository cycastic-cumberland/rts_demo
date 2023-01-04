extends GutTest

#class DaemonClass extends Daemon:
#
#	var a := 1
#	var mutex := Mutex.new()
#
#	func _job_callback(alloc_no, batch_no, termination):
#		mutex.lock()
#		a = a + 1
#		mutex.unlock()
#
#func test_daemon_general():
#	var a := DaemonClass.new()
#	a.create_batch_job(3, DaemonManager.DAEMON_ONESHOT)
#	yield(get_tree(), "idle_frame")
#	yield(get_tree(), "idle_frame")
#	yield(get_tree(), "idle_frame")
#	yield(get_tree(), "idle_frame")
#	yield(get_tree(), "idle_frame")
#	yield(get_tree(), "idle_frame")
#	yield(get_tree(), "idle_frame")
#	assert_eq(a.a, 3)
