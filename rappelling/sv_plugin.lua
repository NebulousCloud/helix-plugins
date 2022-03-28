
local PLUGIN = PLUGIN

function PLUGIN:CreateRope(client)
	local attachmentIndex

	if (client.ixAnimModelClass == "metrocop") then
		attachmentIndex = client:LookupAttachment("anim_attachment_LH")
	else
		attachmentIndex = client:LookupAttachment("hips")
	end

	local attachment = client:GetAttachment(attachmentIndex)

	if (attachmentIndex == 0 or attachmentIndex == -1) then
		attachment = {Pos = client:GetBonePosition(client:LookupBone("ValveBiped.Bip01_Pelvis"))}
		attachmentIndex = client:LookupAttachment("forward")
	end

	local rappelRope = ents.Create("keyframe_rope")
		rappelRope:SetParent(client, attachmentIndex)
		rappelRope:SetPos(attachment and attachment.Pos or client:GetPos())
		rappelRope:SetColor(Color(150, 150, 150))
		rappelRope:SetEntity("StartEntity", rappelRope)
		rappelRope:SetEntity("EndEntity", Entity(0))
		rappelRope:SetKeyValue("Width", 2)
		rappelRope:SetKeyValue("Collide", 1)
		rappelRope:SetKeyValue("RopeMaterial", "cable/cable")
		rappelRope:SetKeyValue("EndOffset", tostring(client.rappelPos or client:GetPos()))
		rappelRope:SetKeyValue("EndBone", 0)
	client.rappelRope = rappelRope

	client:DeleteOnRemove(rappelRope)
	client:EmitSound("npc/combine_soldier/zipline_clip" .. math.random(2) .. ".wav")

end

function PLUGIN:RemoveRope(client)
	if (IsValid(client.rappelRope)) then
		client.rappelRope:Remove()
	end

	client.rappelRope = nil
	client.oneTimeRappelSound = nil

	local sequence = client:LookupSequence("rappelloop")

	if (sequence != 1 and client:GetNetVar("forcedSequence") == sequence) then
		client:SetNetVar("forcedSequence", nil)
	end
end
