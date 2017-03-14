AddCSLuaFile()

if SERVER then
	--add the resources to download

end

DEFINE_BASECLASS( "weapon_base" )

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Vortigaunt Beam"
SWEP.Author = "Jvs"
SWEP.ViewModelFOV = 54
SWEP.RenderGroup = RENDERGROUP_BOTH
SWEP.Slot = 1

SWEP.Primary = {
	Automatic = true,
	ClipSize = 100,
}

SWEP.Secondary = {
	Automatic = true,
}

SWEP.UseHands = true,

if CLIENT then
	--we mostly use this to make the viewmodel invisible so we can still bonemerge the c_hands onto it
	function SWEP:PreDrawViewModel( vm , weapon , ply )
	
	end
	
	function SWEP:PostDrawViewModel( vm , weapon , ply )
	
	end
	
	function SWEP:ViewModelDrawn( vm )
	
	end
	
	function SWEP:DrawWorldModel()

	end
	
end

function SWEP:SetupDataTable()

end

function SWEP:Initialize()
	if SERVER then
		self:SetHoldType( "slam" )
	end
end

function SWEP:Think()

end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:Reload()

end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:OnRemove()

end