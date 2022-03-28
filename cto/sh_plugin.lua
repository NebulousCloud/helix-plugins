
ixCTO = PLUGIN

PLUGIN.name = "Combine Technology Overlay"
PLUGIN.author = "Trudeau & Aspect™"
PLUGIN.description = "A Helix port of the modern overhaul of Combine technology designed with non-intrusiveness and responsiveness in mind."

ix.util.Include("cl_hooks.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("sh_configs.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")

ixCTO.sociostatusColors = {
	GREEN = Color(0, 255, 0),
	BLUE = Color(0, 128, 255),
	YELLOW = Color(255, 255, 0),
	RED = Color(255, 0, 0),
	BLACK = Color(128, 128, 128)
}

-- Biosignal change enums, used for player/admin command language variations.
ixCTO.ERROR_NONE = 0
ixCTO.ERROR_NOT_COMBINE = 1
ixCTO.ERROR_ALREADY_ENABLED = 2
ixCTO.ERROR_ALREADY_DISABLED = 3

-- Movement violation enums, used when networking cameras.
ixCTO.VIOLATION_RUNNING = 0
ixCTO.VIOLATION_JUMPING = 1
ixCTO.VIOLATION_CROUCHING = 2
ixCTO.VIOLATION_FALLEN_OVER = 3

-- Camera controlling enums.
ixCTO.CAMERA_VIEW = 0
ixCTO.CAMERA_DISABLE = 1
ixCTO.CAMERA_ENABLE = 2

function ixCTO:isCameraEnabled(camera)
	return camera:GetSequenceName(camera:GetSequence()) == "idlealert"
end
