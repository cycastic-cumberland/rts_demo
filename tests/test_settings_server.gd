extends GutTest

func test_preset_res():
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_CUSTOM)		== Vector2(0.0, 0.0), true, "Unexpected resolution")
#	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_DEFAULT)		== Vector2(0.0, 0.0), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_FULLSCREEN)	== OS.get_screen_size(), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_1024_600)	== Vector2(1024, 600), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_1280_720)	== Vector2(1280, 720), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_1366_768)	== Vector2(1366, 768), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_1400_1050)	== Vector2(1400, 1050), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_1300_900)	== Vector2(1300, 900), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_1600_900)	== Vector2(1600, 900), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_1680_1050)	== Vector2(1680, 1050), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_1920_1080)	== Vector2(1920, 1080), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_2048_1080)	== Vector2(2048, 1080), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_2560_1440)	== Vector2(2560, 1440), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_3840_2160)	== Vector2(3840, 2160), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_4096_2160)	== Vector2(4096, 2160), true, "Unexpected resolution")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_69420_69420)	== Vector2(69420, 69420), true, "Unexpected resolution")

func test_settings_server():
#	SettingsServer.set_main_viewport(get_viewport())
	var ssaa := 1.5
	var screen_count := OS.get_screen_count()
	var curr_screen := OS.current_screen
	var default_res := Vector2()
	default_res.x = ProjectSettings.get_setting("display/window/size/width")
	default_res.y = ProjectSettings.get_setting("display/window/size/height")
	assert_eq(SettingsServer.current_screen == curr_screen, true, "Unexpected screen index")
	assert_eq(SettingsServer.rs_to_vec2(SettingsServer.RES_DEFAULT), default_res, "Unexpected resolution")
	SettingsServer.set_graphics_setting(SettingsServer.SSAA_LEVEL, ssaa)
	assert_eq(SettingsServer.get_graphics_setting(SettingsServer.SSAA_LEVEL), ssaa, "Unexpected SSAA level")
	SettingsServer.set_graphics_setting(SettingsServer.SSAA_LEVEL, 0.3)
	assert_eq(SettingsServer.get_graphics_setting(SettingsServer.SSAA_LEVEL), ssaa, "Unexpected SSAA level")
	SettingsServer.set_graphics_setting(SettingsServer.SSAA_LEVEL, 15.7)
	assert_eq(SettingsServer.get_graphics_setting(SettingsServer.SSAA_LEVEL), ssaa, "Unexpected SSAA level")
	SettingsServer.current_display_preset = SettingsServer.WINDOWED
	var curr_res := SettingsServer.rs_to_vec2(SettingsServer.current_resolution_preset)
	assert_eq(curr_res, OS.window_size, "Unexpected window size")
	assert_eq(curr_res * ssaa, get_viewport().size, "Unexpected Viewport size")
	curr_res = SettingsServer.rs_to_vec2(SettingsServer.RES_1024_600)
	SettingsServer.current_resolution_preset = SettingsServer.RES_1024_600
	assert_eq(curr_res, OS.window_size, "Unexpected window size")
	assert_eq(curr_res * ssaa, get_viewport().size, "Unexpected Viewport size")
	curr_res = SettingsServer.rs_to_vec2(SettingsServer.RES_1920_1080)
	SettingsServer.current_resolution_preset = SettingsServer.RES_1920_1080
	SettingsServer.current_display_preset = SettingsServer.FULLSCREEN
	assert_eq(SettingsServer.current_display_preset, SettingsServer.FULLSCREEN)
	assert_eq(curr_res, OS.window_size, "Unexpected window size")
	assert_eq(curr_res * ssaa, get_viewport().size, "Unexpected Viewport size")
	assert_eq(OS.window_fullscreen, true)
	assert_eq(OS.window_borderless, false)
#	assert_eq(OS.window_maximized, true)
	SettingsServer.current_display_preset = SettingsServer.BORDERLESS_FULLSCREEN
	assert_eq(SettingsServer.current_display_preset, SettingsServer.BORDERLESS_FULLSCREEN)
	assert_eq(curr_res, OS.window_size, "Unexpected window size")
	assert_eq(curr_res * ssaa, get_viewport().size, "Unexpected Viewport size")
	assert_eq(OS.window_fullscreen, false)
	assert_eq(OS.window_borderless, true)
	assert_eq(OS.window_maximized, true)
