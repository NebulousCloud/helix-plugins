
local PLUGIN = PLUGIN

PLUGIN.name = "Perma Remove"
PLUGIN.author = "alexgrist"
PLUGIN.desc = "Allows staff to permanently remove map entities."
PLUGIN.license = [[
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
]]

do
	local COMMAND = {
		description = "Remove a map entity permanently.",
		superAdminOnly = true
	}

	function COMMAND:OnRun(client)
		local entity = client:GetEyeTraceNoCursor().Entity

		if (IsValid(entity) and entity:CreatedByMap()) then
			local entities = PLUGIN:GetData({})
				entities[#entities + 1] = entity:MapCreationID()
				entity:Remove()
			PLUGIN:SetData(entities)

			client:Notify("Map entity removed.")

			ix.log.Add(client, "mapEntRemoved", entity:MapCreationID(), entity:GetModel())
		else
			client:Notify("That is not a valid map entity!")
		end
	end

	ix.command.Add("MapEntRemove", COMMAND)
end

if (SERVER) then
	function PLUGIN:LoadData()
		for _, v in ipairs(self:GetData({})) do
			local entity = ents.GetMapCreatedEntity(v)

			if (IsValid(entity)) then
				entity:Remove()
			end
		end
	end

	ix.log.AddType("mapEntRemoved", function(client, index, model)
		return string.format("%s has removed map entity #%d (%s).", client:Name(), index, model)
	end)
end
