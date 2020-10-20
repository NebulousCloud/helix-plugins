if SERVER then
	AddCSLuaFile("ix_bird.lua")
end

if CLIENT then
	SWEP.Slot = 3
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Bird"
	SWEP.DrawCrosshair = true
end

SWEP.Author					= "Arny"
SWEP.Contact 				= ""

SWEP.Category				= "Bird"
SWEP.Slot					= 3
SWEP.SlotPos				= 5
SWEP.Weight					= 5
SWEP.Spawnable     			= true
SWEP.AdminSpawnable			= false

SWEP.WorldModel 			= ""
SWEP.HoldType 				= ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
end

function SWEP:PrimaryAttack()
    return false
end

function SWEP:SecondaryAttack()
	return false
end
