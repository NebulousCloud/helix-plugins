
local PLUGIN = PLUGIN

PLUGIN.field = "personal_notes"
PLUGIN.cooldown = 2

ix.db.AddToSchema("ix_characters", PLUGIN.field, ix.type.text)

util.AddNetworkString("ixEditMyNotes")
util.AddNetworkString("ixCloseMyNotes")

function PLUGIN:SendNotes(client)
	local time = CurTime()
	local character = client:GetCharacter()

	if (!character or (client.ixNextNotes or 0) > time) then
		return math.ceil(client.ixNextNotes - time)
	end

	local query = mysql:Select("ix_characters")
		query:Select(self.field)
		query:Where("id", character:GetID())
		query:Callback(function(data)
			if (istable(data) and #data > 0) then
				local text = tostring(data[1][self.field] or "")
				text = text == "NULL" and "" or text

				net.Start("ixEditMyNotes")
					net.WriteString(text)
				net.Send(client)
			end
		end)
	query:Execute()

	client.ixNextNotes = time + self.cooldown
	return true
end

function PLUGIN:UpdateNotes(client, text)
	local time = CurTime()
	local character = client:GetCharacter()

	if (!character or (client.ixNextNotes or 0) > time) then
		return math.ceil(client.ixNextNotes - time)
	end

	text = text:sub(1, self.maxLength)

	local query = mysql:Update("ix_characters")
		query:Update(self.field, text)
		query:Where("id", character:GetID())
	query:Execute()

	client.ixNextNotes = time + self.cooldown
	return true
end
