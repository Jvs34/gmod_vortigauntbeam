AddCSLuaFile()

if SERVER then
	--add the resources to download
	resource.AddFile( "models/weapons/v_vortbeamvm.mdl" )
end

DEFINE_BASECLASS( "weapon_base" )

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Vortigaunt Beam"
SWEP.Author = "Jvs"
SWEP.Purpose		= "Zap everything! Vortigaunt Style"
SWEP.Instructions	= "Primary: Vortigaunt zap.\nSecondary: Self battery healing."
	
SWEP.ViewModelFOV = 54
SWEP.RenderGroup = RENDERGROUP_BOTH
SWEP.Slot = 1

SWEP.Primary = {
	Automatic = true,
	ClipSize = -1,
	DefaultClip = -1,
	Ammo = "",	
}

SWEP.Secondary = {
	Automatic = true,
	ClipSize = -1,
	DefaultClip = -1,
	Ammo = "",
}

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/v_vortbeamvm.mdl"
SWEP.WorldModel = ""


if CLIENT then
	--we mostly use this to make the viewmodel invisible so we can still bonemerge the c_hands onto it
	function SWEP:PreDrawViewModel( vm , weapon , ply )
		if IsValid( vm ) and vm:ViewModelIndex() == 0 then
			vm:SetSubMaterial( 0 , "engine/occlusionproxy" )
		end
	end
	
	function SWEP:PostDrawViewModel( vm , weapon , ply )
		if IsValid( vm ) and vm:ViewModelIndex() == 0 then
			vm:SetSubMaterial( 0 , nil )
		end
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

--remove even when we could've dropped to the ground
function SWEP:OnDrop()
	self:Remove()
end

--shut down sounds, particles and whatever is left
function SWEP:OnRemove()

end