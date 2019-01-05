local PLUGIN = PLUGIN
PLUGIN.name = "Paper"
PLUGIN.author = "Niko & Wiz"
PLUGIN.desc = "Adds paper into the game that you can write on and edit."
PAPERLIMIT = 2000
WRITINGDATA = WRITINGDATA or {}

--include("derma/cl_vgui.lua")

if (CLIENT) then
	netstream.Hook("receivePaper", function(id, contents, write)
		local paper = vgui.Create("paperRead")
		paper:allowEdit(write)
		paper:setText(contents)
		paper.id = id
	end)
else
	function FindPaperByID(id)
		for k, v in ipairs(ents.GetAll()) do
			if (v:GetClass() == "ix_paper" and v.id == id) then
				return v
			end
		end
	end
	
	netstream.Hook("paperSendText", function(client, id, contents)
		if (string.len(contents) <= PAPERLIMIT) then
			local paper = FindPaperByID(id)
			if (paper:canWrite(client) == false) then
				client:nofity("You do not own this paper!")
			end

			WRITINGDATA[id] = contents
		end
	end)

	function PLUGIN:EntityRemoved(entity)
		if (!ix.shuttingDown and entity and IsValid(entity) and entity:GetClass() == "ix_paper" and entity.id) then
			if WRITINGDATA[entity.id] then
				WRITINGDATA[entity.id] = nil
			end
		end
	end

	function PLUGIN:OnPaperSpawned(paper, item, load)
		paper:SetModel(item.model)
		paper:PhysicsInit(SOLID_VPHYSICS)
		paper:SetMoveType(MOVETYPE_VPHYSICS)
		paper:SetUseType(SIMPLE_USE)

		local physicsObject = paper:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end

		if (item.player and IsValid(item.player)) then
			paper:SetNetVar("ownerCharPaper", item.player:GetChar().id)
		end

		if (load != true) then
			paper.id = os.time()
			WRITINGDATA[paper.id] = ""
		end
	end

	function PLUGIN:LoadData()
		local savedTable = self:GetData() or {}
		local paperItem = ix.item.list["paper"]
		WRITINGDATA = savedTable.paperData

		if (savedTable.paperEntities) then
			for k, v in ipairs(savedTable.paperEntities) do
				local paper = ents.Create("ix_paper")
				paper:SetPos(v.pos)
				paper:SetAngles(v.ang)
				paper:Spawn()
				paper:Activate()
				paper:SetNetVar("ownerCharPaper", v.owner)
				paper.id = v.id

				hook.Run("OnPaperSpawned", paper, paperItem, true)
			end
		end
	end
	
	function PLUGIN:SaveData()
		local saveTable = {}
		local validPapers = {}
		saveTable.paperEntities = {}

		for _, v in ipairs(ents.GetAll()) do
			if (v:GetClass() == "ix_paper") then
				table.insert(saveTable.paperEntities, {pos = v:GetPos(), ang = v:GetAngles(), id = v.id, owner = v:getOwner()})
				table.insert(validPapers, v.id)
			end
		end

		local validPaperData = {}
		for _, v in ipairs(validPapers) do
			validPaperData[v] = WRITINGDATA[v]
		end

		saveTable.paperData = validPaperData

		self:SetData(saveTable)
	end
	
end