
PLUGIN.name = "Combine Technology Overlay"
PLUGIN.author = "Trudeau & Aspect™"
PLUGIN.description = "A Helix port of the modern overhaul of Combine technology designed with non-intrusiveness and responsiveness in mind."

ix.util.Include("cl_hooks.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("sh_configs.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")

PLUGIN.sociostatusColors = {
	GREEN = Color(0, 255, 0),
	BLUE = Color(0, 128, 255),
	YELLOW = Color(255, 255, 0),
	RED = Color(255, 0, 0),
	BLACK = Color(128, 128, 128)
}

-- Biosignal change enums, used for player/admin command language variations.
PLUGIN.ERROR_NONE = 0
PLUGIN.ERROR_NOT_COMBINE = 1
PLUGIN.ERROR_ALREADY_ENABLED = 2
PLUGIN.ERROR_ALREADY_DISABLED = 3

-- Movement violation enums, used when networking cameras.
PLUGIN.VIOLATION_RUNNING = 0
PLUGIN.VIOLATION_JUMPING = 1
PLUGIN.VIOLATION_CROUCHING = 2
PLUGIN.VIOLATION_FALLEN_OVER = 3

-- Camera controlling enums.
PLUGIN.CAMERA_VIEW = 0
PLUGIN.CAMERA_DISABLE = 1
PLUGIN.CAMERA_ENABLE = 2

function PLUGIN:isCameraEnabled(camera)
	return camera:GetSequenceName(camera:GetSequence()) == "idlealert"
end
