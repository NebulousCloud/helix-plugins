local PLUGIN = PLUGIN;

ITEM.name = "Scavenging Kit";
ITEM.model = Model( "models/props_junk/cardboard_box004a.mdl" );
ITEM.width = 2;
ITEM.height = 2;
ITEM.description = "A kit containing multiple tools and alike to aid in scavenging.";

function ITEM:GetName()
	return self.name;
end

function ITEM:GetDescription()
	return self.description;
end