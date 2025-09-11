extends Control

const CONFIG_PATH := "res://addons/godot-firebase/firebase_config/firebase_config.json"

func _ready() -> void:
	print("\n=== FIREBASE CONFIG TEST START ===")

	# 1) file exists?
	if not FileAccess.file_exists(CONFIG_PATH):
		push_error("firebase_config.json NOT FOUND at: %s" % CONFIG_PATH)
		print("Make sure file is exactly at: " + CONFIG_PATH)
		print("Folder name must be 'firebase_config' and filename 'firebase_config.json'")
		print("Example path: res://addons/godot-firebase/firebase_config/firebase_config.json")
		print("=== TEST END ===\n")
		return

	# 2) dump raw contents
	var f := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var txt := f.get_as_text()
	f.close()
	print("RAW CONFIG CONTENTS:\n" + txt)

	# 3) parse JSON and check apiKey
	var parsed = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Failed to parse JSON. File is not valid JSON (maybe INI/.env format).")
		print("Make sure file is plain JSON, e.g.:")
		print('{"apiKey":"...","authDomain":"...","databaseURL":"...","projectId":"..."}')
	else:
		var api: String = str(parsed.get("apiKey", ""))
		if api == "" or api == "null":
			push_error("apiKey missing or empty in firebase_config.json")
		else:
			print("apiKey FOUND (first 8 chars): " + api.substr(0,8) + " ... (hidden)")
			print("authDomain:", parsed.get("authDomain","<missing>"))
			print("storageBucket:", parsed.get("storageBucket","<missing>"))

	# 4) check Firebase autoload node
	var fb := get_node_or_null("/root/Firebase")
	if fb:
		print("Firebase autoload FOUND at /root/Firebase (good).")
		# attempt to force reload if method exists
		if fb.has_method("load_config"):
			print("Calling /root/Firebase.load_config() to force config load.")
			fb.call("load_config")
		else:
			print("No load_config() method found on the Firebase autoload. Plugin likely loads config at startup.")
	else:
		push_error("Firebase autoload NOT FOUND at /root/Firebase.")
		print("Open Project -> Project Settings -> Autoload and ensure you added the firebase.tscn as 'Firebase'.")

	print("=== FIREBASE CONFIG TEST END ===\n")
