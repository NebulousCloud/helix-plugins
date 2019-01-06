local PLUGIN = PLUGIN
PLUGIN.name = "Enhanced Description"
PLUGIN.author = "Subleader"
PLUGIN.desc = "Better description."
DESCRIPTIONLIMIT = 2000

if (CLIENT) then
	netstream.Hook("ixReceiveDescription", function(client, contents, url)
		local description = vgui.Create("ixDescriptionEn")
		local character = client:GetCharacter()
		local content = character:GetData("DetailDesc", contents)
		local url = character:GetData("UrlDesc", url)
		description:setText(content, url)
	end)
	
	netstream.Hook("ixReceiveViewDescription", function(target, contents, url)
		local description = vgui.Create("ixDescriptionEnView")
		local character = target:GetCharacter()
		local content = character:GetData("DetailDesc", contents)
		local url = character:GetData("UrlDesc", url)
		description:setText(content, url)
	end)
else	
	netstream.Hook("ixDescriptionSendText", function(client, contents, url)
		if (string.len(contents) <= DESCRIPTIONLIMIT) then
			local character = client:GetCharacter()
			character:SetData("DetailDesc", contents)
			character:SetData("UrlDesc", url)
		end
	end)
end

function PLUGIN:PlayerUse(client, entity)
	if (entity:IsPlayer()) then
	local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + (client:GetAimVector() * 400)
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer()) then
			client:ConCommand( "say /viewdesc" )
		end
	end
end

do
	local COMMAND = {}
	COMMAND.description = "Edit your own description"
	COMMAND.adminOnly = false

	function COMMAND:OnRun(client)
			if (IsValid(client)) then
			local character = client:GetCharacter()
				netstream.Start(client, "ixReceiveDescription",client, character:GetData("DetailDesc", contents), character:GetData("UrlDesc", url))
			else
				return "Not a valid player"
			end
	end

	ix.command.Add("Selfdesc", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "See the description of the person you are looking at"
	COMMAND.adminOnly = false

	function COMMAND:OnRun(client)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + (client:GetAimVector() * 400)
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer()) then
			local character = target:GetCharacter()
				netstream.Start(client, "ixReceiveViewDescription", target, character:GetData("DetailDesc", contents), character:GetData("UrlDesc", url))
			else
				return "Not a valid player"
			end
	end

	ix.command.Add("Viewdesc", COMMAND)
end