
local PLUGIN = PLUGIN

net.Receive("ixEditMyNotes", function(length)
	if (PLUGIN.notesPanel and IsValid(PLUGIN.notesPanel)) then
		PLUGIN.notesPanel:Close()
	end

	local text = net.ReadString()

	if (isstring(text)) then
		PLUGIN.notesPanel = vgui.Create("ixMyNotes")
		PLUGIN.notesPanel:Populate(text)
	end
end)

net.Receive("ixCloseMyNotes", function(length)
	local status = net.ReadUInt(6)

	if (isnumber(status) and status > 0) then
		ix.util.NotifyLocalized("mynotesCooldown", status)
	elseif (IsValid(PLUGIN.panel)) then
		PLUGIN.panel:Close()
	end
end)
