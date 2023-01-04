extends GutTest

class SmallRecord extends Record:
	var a := 9
	var b := "Uwa"
	var c := Resource.new()

	func _init():
		track_list = ["a", "b", "c"]

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
	assert_eq(rec.write("decoder", null), true)
	assert_eq(rec.read("decoder"), rec.decoder)
	assert_ne(rec.read("decoder"), null)
	assert_eq(rec.write("encoder", null), true)
	assert_eq(rec.read("encoder"), rec.encoder)
	assert_ne(rec.read("encoder"), null)

func test_basic_serialization():
	var rec := SmallRecord.new()
	var en := RecordPrimitiveEncoder.new()
	var de := RecordPrimitiveDecoder.new()

	var rec2 := SmallRecord.new()
	rec2.a = 0xFFFFFF
	rec2.b = "0xFFFFFF"
#	rec2.c = null

	rec.encoder = en
	rec2.decoder = de
	assert_eq(rec.encoder, en)
	assert_eq(rec2.decoder, de)

	var encoded = rec.encode()
	assert_eq(encoded is Dictionary, true)

	assert_eq(rec2.a, 0xFFFFFF)
	assert_eq(rec2.b, "0xFFFFFF")
#	assert_eq(rec2.c, null)
	assert_eq(rec2.decode(encoded), true)
	assert_eq(rec2.a, rec.a)
	assert_eq(rec2.b, rec.b)
	assert_ne(rec2.c, rec.c)
