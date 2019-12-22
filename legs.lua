
PLUGIN.name = "Legs"
PLUGIN.author = "Valkyrie & blackops7799"
PLUGIN.description = "Renders the characters legs to the local player."
PLUGIN.license = [[
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any and all copyright interest in the software to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
]]

ix.lang.AddTable("english", {
	legs = "Legs",

	optLegsEnabled = "Enable legs",
	optLegsInVehicle = "Enable legs in vehicles"
})

if (CLIENT) then
	ix.option.Add("legsEnabled", ix.type.bool, true, {
		category = "legs"
	})

	ix.option.Add("legsInVehicle", ix.type.bool, true, {
		category = "legs"
	})

	local Legs = {}
	Legs.LegEnt = nil

	function Legs:CheckDrawVehicle()
		if (LocalPlayer():InVehicle()) then
			if (ix.option.Get("legsEnabled", true) and !ix.option.Get("legsInVehicle", true)) then
				return true
			end

			return false
		end
	end

	local function ShouldDrawLegs()
		if (hook.Run("ShouldDisableLegs") == true) then
			return false
		end

		if (ix.option.Get("legsEnabled", true)) then
			local client = LocalPlayer()
			return  IsValid(Legs.LegEnt) and
					(client:Alive() or (client.IsGhosted and client:IsGhosted())) and
					!Legs:CheckDrawVehicle() and GetViewEntity() == client and
					!client:ShouldDrawLocalPlayer() and !IsValid(client:GetObserverTarget()) and
					!client:GetNoDraw() and !client.ShouldDisableLegs
		end
	end

	function Legs:Setup(model)
		model = model or LocalPlayer():GetModel()

		if (!IsValid(self.LegEnt)) then
			self.LegEnt = ClientsideModel(model, RENDER_GROUP_OPAQUE_ENTITY)
		else
			self.LegEnt:SetModel(model)
		end

		self.LegEnt:SetNoDraw(true)

		for _, v in pairs(LocalPlayer():GetBodyGroups()) do
			local current = LocalPlayer():GetBodygroup(v.id)
			self.LegEnt:SetBodygroup(v.id,  current)
		end

		for k, _ in ipairs(LocalPlayer():GetMaterials()) do
			self.LegEnt:SetSubMaterial(k - 1, LocalPlayer():GetSubMaterial(k - 1))
		end

		self.LegEnt:SetSkin(LocalPlayer():GetSkin())
		self.LegEnt:SetMaterial(LocalPlayer():GetMaterial())
		self.LegEnt:SetColor(LocalPlayer():GetColor())
		self.LegEnt.GetPlayerColor = function()
			return LocalPlayer():GetPlayerColor()
		end

		self.LegEnt.Anim = nil
		self.PlaybackRate = 1
		self.Sequence = nil
		self.Velocity = 0
		self.BonesToRemove = {}
		self.LegEnt.LastTick = 0

		self:Update(0)
	end

	Legs.PlaybackRate = 1
	Legs.Sequence = nil
	Legs.Velocity = 0
	Legs.BonesToRemove = {}
	Legs.BreathScale = 0.5
	Legs.NextBreath = 0

	function Legs:Think(maxSeqGroundSpeed)
		if (!LocalPlayer():Alive()) then
			Legs:Setup()
			return
		end

		self:Update(maxSeqGroundSpeed)
	end

	function Legs:Update(maxSeqGroundSpeed)
		if (IsValid(self.LegEnt)) then
			self.Velocity = LocalPlayer():GetVelocity():Length2D()

			self.PlaybackRate = 1

			if (self.Velocity > 0.5) then
				if (maxSeqGroundSpeed < 0.001) then
					self.PlaybackRate = 0.01
				else
					self.PlaybackRate = self.Velocity / maxSeqGroundSpeed
					self.PlaybackRate = math.Clamp(self.PlaybackRate, 0.01, 10)
				end
			end

			self.LegEnt:SetPlaybackRate(self.PlaybackRate)

			self.Sequence = LocalPlayer():GetSequence()

			if (self.LegEnt.Anim != self.Sequence) then
				self.LegEnt.Anim = self.Sequence
				self.LegEnt:ResetSequence(self.Sequence)
			end

			self.LegEnt:FrameAdvance(CurTime() - self.LegEnt.LastTick)
			self.LegEnt.LastTick = CurTime()

			Legs.BreathScale = sharpeye and sharpeye.GetStamina and math.Clamp(math.floor(sharpeye.GetStamina() * 5 * 10) / 10, 0.5, 5) or 0.5

			if (Legs.NextBreath <= CurTime()) then
				Legs.NextBreath = CurTime() + 1.95 / Legs.BreathScale
				self.LegEnt:SetPoseParameter("breathing", Legs.BreathScale)
			end

			self.LegEnt:SetPoseParameter("move_x", (LocalPlayer():GetPoseParameter("move_x") * 2) - 1) -- Translate the walk x direction
			self.LegEnt:SetPoseParameter("move_y", (LocalPlayer():GetPoseParameter("move_y") * 2) - 1) -- Translate the walk y direction
			self.LegEnt:SetPoseParameter("move_yaw", (LocalPlayer():GetPoseParameter("move_yaw") * 360) - 180) -- Translate the walk direction
			self.LegEnt:SetPoseParameter("body_yaw", (LocalPlayer():GetPoseParameter("body_yaw") * 180) - 90) -- Translate the body yaw
			self.LegEnt:SetPoseParameter("spine_yaw",(LocalPlayer():GetPoseParameter("spine_yaw") * 180) - 90) -- Translate the spine yaw

			if (LocalPlayer():InVehicle()) then
				self.LegEnt:SetPoseParameter("vehicle_steer", (LocalPlayer():GetVehicle():GetPoseParameter("vehicle_steer") * 2) - 1) -- Translate the vehicle steering
			end
		end
	end

	Legs.RenderAngle = nil
	Legs.BiaisAngle = nil
	Legs.RadAngle = nil
	Legs.RenderPos = nil
	Legs.RenderColor = {}
	Legs.ClipVector = vector_up * -1
	Legs.ForwardOffset = -24

	function Legs:DoFinalRender()
	   cam.Start3D(EyePos(), EyeAngles())
			if (ShouldDrawLegs()) then
				self.RenderPos = LocalPlayer():GetPos()

				if (LocalPlayer():InVehicle()) then
					self.RenderAngle = LocalPlayer():GetVehicle():GetAngles()
					self.RenderAngle:RotateAroundAxis(self.RenderAngle:Up(), 90)
				else
					self.BiaisAngles = sharpeye_focus and sharpeye_focus.GetBiaisViewAngles and sharpeye_focus:GetBiaisViewAngles() or LocalPlayer():EyeAngles()
					self.RenderAngle = Angle(0, self.BiaisAngles.y, 0)
					self.RadAngle = math.rad(self.BiaisAngles.y)
					self.ForwardOffset = -22
					self.RenderPos.x = self.RenderPos.x + math.cos(self.RadAngle) * self.ForwardOffset
					self.RenderPos.y = self.RenderPos.y + math.sin(self.RadAngle) * self.ForwardOffset

					if (LocalPlayer():GetGroundEntity() == NULL) then
						self.RenderPos.z = self.RenderPos.z + 8

						if (LocalPlayer():KeyDown(IN_DUCK)) then
							self.RenderPos.z = self.RenderPos.z - 28
						end
					end
				end

				self.RenderColor = LocalPlayer():GetColor()

				local bEnabled = render.EnableClipping(true)
					render.PushCustomClipPlane(self.ClipVector, self.ClipVector:Dot(EyePos()))
						render.SetColorModulation(self.RenderColor.r / 255, self.RenderColor.g / 255, self.RenderColor.b / 255)
							render.SetBlend(self.RenderColor.a / 255)
									self.LegEnt:SetRenderOrigin(self.RenderPos)
									self.LegEnt:SetRenderAngles(self.RenderAngle)
									self.LegEnt:SetupBones()
									self.LegEnt:DrawModel()
									self.LegEnt:SetRenderOrigin()
									self.LegEnt:SetRenderAngles()
							render.SetBlend(1)
						render.SetColorModulation(1, 1, 1)
					render.PopCustomClipPlane()
				render.EnableClipping(bEnabled)
			end
		cam.End3D()
	end

	function Legs:FixBones()
		for i = 0, self.LegEnt:GetBoneCount() do
			self.LegEnt:ManipulateBoneScale(i, Vector(1, 1, 1))
			self.LegEnt:ManipulateBonePosition(i, vector_origin)
		end

		self.BonesToRemove =
		{
			"ValveBiped.Bip01_Head1",
			"ValveBiped.Bip01_L_Hand",
			"ValveBiped.Bip01_L_Forearm",
			"ValveBiped.Bip01_L_Upperarm",
			"ValveBiped.Bip01_L_Clavicle",
			"ValveBiped.Bip01_R_Hand",
			"ValveBiped.Bip01_R_Forearm",
			"ValveBiped.Bip01_R_Upperarm",
			"ValveBiped.Bip01_R_Clavicle",
			"ValveBiped.Bip01_L_Finger4",
			"ValveBiped.Bip01_L_Finger41",
			"ValveBiped.Bip01_L_Finger42",
			"ValveBiped.Bip01_L_Finger3",
			"ValveBiped.Bip01_L_Finger31",
			"ValveBiped.Bip01_L_Finger32",
			"ValveBiped.Bip01_L_Finger2",
			"ValveBiped.Bip01_L_Finger21",
			"ValveBiped.Bip01_L_Finger22",
			"ValveBiped.Bip01_L_Finger1",
			"ValveBiped.Bip01_L_Finger11",
			"ValveBiped.Bip01_L_Finger12",
			"ValveBiped.Bip01_L_Finger0",
			"ValveBiped.Bip01_L_Finger01",
			"ValveBiped.Bip01_L_Finger02",
			"ValveBiped.Bip01_R_Finger4",
			"ValveBiped.Bip01_R_Finger41",
			"ValveBiped.Bip01_R_Finger42",
			"ValveBiped.Bip01_R_Finger3",
			"ValveBiped.Bip01_R_Finger31",
			"ValveBiped.Bip01_R_Finger32",
			"ValveBiped.Bip01_R_Finger2",
			"ValveBiped.Bip01_R_Finger21",
			"ValveBiped.Bip01_R_Finger22",
			"ValveBiped.Bip01_R_Finger1",
			"ValveBiped.Bip01_R_Finger11",
			"ValveBiped.Bip01_R_Finger12",
			"ValveBiped.Bip01_R_Finger0",
			"ValveBiped.Bip01_R_Finger01",
			"ValveBiped.Bip01_R_Finger02",
			"ValveBiped.Bip01_Spine4",
			"ValveBiped.Bip01_Spine2",
		}

		if (LocalPlayer():InVehicle()) then
			self.BonesToRemove =
			{
				"ValveBiped.Bip01_Head1",
			}
		end

		for _, v in pairs(self.BonesToRemove) do
			local bone = self.LegEnt:LookupBone(v)
			if (bone) then
				self.LegEnt:ManipulateBoneScale(bone, vector_origin)
				if (!LocalPlayer():InVehicle()) then
					self.LegEnt:ManipulateBonePosition(bone, Vector(0, -100, 0))
					self.LegEnt:ManipulateBoneAngles(bone, angle_zero)
				end
			end
		end
	end

	function PLUGIN:PlayerWeaponChanged(client, weapon)
		if (client == LocalPlayer() and IsValid(Legs.LegEnt)) then
			Legs:FixBones()
		end
	end

	function PLUGIN:UpdateAnimation(client, velocity, maxSeqGroundSpeed)
		if (client == LocalPlayer()) then
			if (IsValid(Legs.LegEnt)) then
				Legs:Think(maxSeqGroundSpeed)
			else
				Legs:Setup()
			end
		end
	end

	function PLUGIN:PlayerModelChanged(client, model)
		if (client == LocalPlayer()) then
			Legs:Setup(model)
			Legs:FixBones()
		end
	end

	function PLUGIN:PostDrawTranslucentRenderables()
		 if (LocalPlayer() and !LocalPlayer():InVehicle()) then
			Legs:DoFinalRender()
		end
	end

	function PLUGIN:RenderScreenspaceEffects()
		 if (LocalPlayer():InVehicle()) then
			Legs:DoFinalRender()
		end
	end
end
