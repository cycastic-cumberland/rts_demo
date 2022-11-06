extends GutTest


func test_basic_functionalities():
	var rec := Record.new()
	assert_ne(rec.encoder, null, "Unexpected value")
	assert_ne(rec.decoder, null, "Unexpected value")
	assert_eq(rec.mask, null, "Unexpected value")
	rec.track_list = ["encoder", "decoder", "mask"]
	var re := rec.get_all_tracks()
#	var a = str(re[2])
#	print(a)
	assert_ne(re[0], null, "Unexpected value")
	assert_ne(re[1], null, "Unexpected value")
	assert_eq(re[2], null, "Unexpected value")
	rec.mask = RecordMask.new()
	assert_eq(re[2], null, "Unexpected value")
	assert_ne(rec.mask, null, "Unexpected value")
	assert_eq(rec.encode(), null, "Unexpected value")
	assert_eq(rec.decode(rec), false, "Unexpected value")
	assert_eq(rec.read("encoder"), rec.encoder)
	assert_eq(rec.read("decoder"), rec.decoder)
	assert_eq(rec.read("mask"), rec.mask)
	
	# Encoder / Decoder can not be null
	assert_eq(rec.mask.builtin_write(rec, "decoder", null), true)
	assert_eq(rec.read("decoder"), rec.decoder)
	assert_ne(rec.read("decoder"), null)
	assert_eq(rec.mask.builtin_write(rec, "encoder", null), true)
	assert_eq(rec.read("encoder"), rec.encoder)
	assert_ne(rec.read("encoder"), null)
