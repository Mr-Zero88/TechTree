@tool # Needed so it runs in editor.
extends EditorScenePostImport

var path := "res://Meshes/" # <- tres is Text RESource

# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	for child in scene.get_children():
		print(child.name)
		print(child.get_class())
		save(child.mesh, child.name.left(-4))
		
	return scene # Remember to return the imported scene

func save(data, name) -> void:
	
	var error := ResourceSaver.save(data, path + name + ".tres")
	if error:
		print("An error happened while saving data: ", error)
