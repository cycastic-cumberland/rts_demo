extends GutTest

func test_advanced_curve_general():
	var new_ac: AdvancedCurve = preload("res://tests/test_resources/test_ac.tres").duplicate()
	var bake_res_a := new_ac.get_area(0.0, 17.0)
	var bake_res_b := new_ac.get_area_no_bake(0.0, 17.0, AdvancedCurve.AC_TRAPEZOID)
	# Expect 0.0
	new_ac.bake_method = AdvancedCurve.AC_NO_METHOD
	var bake_res_x1 := new_ac.get_area(0.0, 17.0)
	# Expect old result
	new_ac.bake_method = AdvancedCurve.AC_SIMPSON
	var bake_res_x2 := new_ac.get_area(0.0, 17.0)
	# Expect old result
	var bake_res_y2 := new_ac.get_area_no_bake(0.0, 17.0, AdvancedCurve.AC_SIMPSON)
	var general_result := 107.6
	assert_eq(abs(bake_res_a - general_result) < 0.1, true, "Bake test A failed")
	assert_eq(abs(bake_res_b - general_result) < 0.1, true, "Bake test B failed")
	assert_eq(bake_res_x1, 0.0, "Bake test X1 failed")
#	assert_eq(abs(bake_res_x2 - general_result) < 0.1, true, "Bake test X2 failed")
#	assert_eq(abs(bake_res_y2 - general_result) < 0.1, true, "Bake test Y2 failed")
	assert_eq(new_ac.get_area(-70.0, 0.0), 0.0,"Bake test C failed")
	assert_eq(new_ac.get_area(18.0, 0.0), 0.0,"Bake test E failed")
	assert_eq(new_ac.get_area(18.0, 20.0), 2.0,"Bake test F failed")
