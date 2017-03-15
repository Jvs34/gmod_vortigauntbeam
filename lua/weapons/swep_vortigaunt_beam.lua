AddCSLuaFile()

if SERVER then
	--add the resources to download
	resource.AddFile( "models/weapons/v_vortbeamvm.mdl" )
end

DEFINE_BASECLASS( "weapon_base" )

game.AddParticles( "particles/vortigaunt_fx.pcf" )

PrecacheParticleSystem( "vortigaunt_beam" )
PrecacheParticleSystem( "vortigaunt_beam_charge" )
PrecacheParticleSystem( "vortigaunt_charge_token" )


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
	Automatic = false,
	ClipSize = -1,
	DefaultClip = -1,
	Ammo = "",	
}

SWEP.Secondary = {
	Automatic = false,
	ClipSize = -1,
	DefaultClip = -1,
	Ammo = "",
}

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/v_vortbeamvm.mdl"
SWEP.WorldModel = "models/dav0r/hoverball.mdl"

SWEP.Beam = {
	Damage = 75,
	DamageForce = 48000,
	Range = 2400,
	ChargeTime = 1.25,
	SplashRadius = 48,
	BeamHitbox = {
		Min = Vector( -16 , -16 , -16 ),
		Max = Vector( 16 , 16 , 16 ),
	},
	Sounds = {
		Attack = "",
		Charge = "",
		Heal = "",
	},
	Particles = {
		Attack = "",
		Idle = "",
		Heal = "",
	},
	--when both are false, healing is completely disabled
	HealHealth = true, --should we heal hp?
	HealArmor = true, --should we heal armor?
	HealHealthFirst = true, --if true, heal hp before armor, if false, do both
	HealAmount = 15,
	HealTime = 1, --seconds until the next heal
	MaxArmor = 100,	--once we have GetMaxArmor this will go away, eventually
}

if SERVER then

else
	AccessorFunc( SWEP , "_vchargeparticle" , "VortigauntChargeParticle" )
	AccessorFunc( SWEP , "_vhealparticle" , "VortigauntHealParticle" )
	AccessorFunc( SWEP , "_vidleparticle" , "VortigauntIdleParticle" )

end

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
		if IsValid( vm ) and vm:ViewModelIndex() == 0 then
			--draw particles such as the idle, charge attack and healing ones
			self:CheckVortigauntParticles()
			self:DrawVortigauntParticles( false , vm )
		end
	end
	
	function SWEP:DrawWorldModel()
		--self:DrawVortigauntParticles( true , self:GetOwner() )
		--self:DrawModel()
		
		if IsValid( self:GetOwner() ) then
			--self:DrawVortigauntParticles( true , self:GetOwner() )
		end
		
	end
	
	function SWEP:DrawWorldModelTranslucent()
		self:CheckVortigauntParticles()
		self:DrawVortigauntParticles( true , self:GetOwner() )
	end
	
	function SWEP:DrawVortigauntParticles( isthirdperson , ent )
		
		--this means that we're drawing the entity on its own, likely someone duped it and spawned it on the ground
		--which is fine, most if not all weapons should support this behaviour
		if isthirdperson and not IsValid( ent ) then
			self:DrawVortigauntParticlesStandalone()
			return
		end
		
		--what? just in case though, we're police
		if not isthirdperson and not IsValid( ent ) then
			return
		end
		
		if isthirdperson then
			
		else
		
		end
	end
	
	function SWEP:DrawVortigauntParticlesStandalone()
		if IsValid( self:GetVortigauntChargeParticle() ) then
			self:GetVortigauntChargeParticle():SetIsViewModelEffect( false )

			if self:GetVortigauntChargeParticle():IsFinished() then
				self:GetVortigauntChargeParticle():StartEmission()
			end

			self:GetVortigauntChargeParticle():SetSortOrigin( self:GetPos() )
			self:GetVortigauntChargeParticle():SetControlPoint( 0 , self:GetPos() )
			self:GetVortigauntChargeParticle():Render()
		end
	end

	
	
	function SWEP:CheckVortigauntParticles()
		if not IsValid( self:GetVortigauntChargeParticle() ) then
			local particle = CreateParticleSystem( self , "vortigaunt_charge_token" , 0 )
			particle:SetShouldDraw( false )
			self:SetVortigauntChargeParticle( particle )
		end
	end
	
	function SWEP:DestroyVortigauntParticles()
		if IsValid( self:GetVortigauntChargeParticle() ) then
			self:GetVortigauntChargeParticle():StopEmissionAndDestroyImmediately()
			self:SetVortigauntChargeParticle( nil )
		end
	end
end

function SWEP:SetupDataTables()
	
	self:NetworkVar( "Float" , 0 , "NextChargeAttack" )
	self:NetworkVar( "Float" , 1 , "NextIdle" )
	self:NetworkVar( "Float" , 2 , "NextHeal" )
	
end

function SWEP:Initialize()
	if SERVER then
		self:SetHoldType( "slam" )
		self:ResetVariables()
	end
end

function SWEP:ResetVariables()
	self:SetNextChargeAttack( -1 )
	self:SetNextIdle( -1 )
	self:SetNextHeal( -1 )
end

function SWEP:CheckVortigauntSounds()

end

function SWEP:DestroyVortigauntSounds()

end

function SWEP:Deploy()
	self:ResetVariables()
	self:CheckVortigauntSounds()
	return true
end

function SWEP:Holster()
	self:ResetVariables()
	self:DestroyVortigauntSounds()
	return true
end

function SWEP:Think()
	self:CheckVortigauntSounds()
	
	if self:GetNextChargeAttack() ~= -1 and self:GetNextChargeAttack() < CurTime() then
		self:BeamAttack()
		self:SetNextChargeAttack( -1 )
	end
	
	
end

function SWEP:CanAttack()
	return self:GetNextChargeAttack() == -1
end

function SWEP:PrimaryAttack()
	if not self:CanAttack() then
		return
	end
	
	--initiate the delayed attack
end

function SWEP:SecondaryAttack()
	if not self:CanAttack() then
		return
	end
	--initiate the healing
end

function SWEP:Reload()

end

function SWEP:BeamAttack()
	local owner = self:GetOwner()
	
	if not IsValid( owner ) then
		return
	end
	
	if owner:IsPlayer() then
		owner:LagCompensation( true )
	end
	
	local tr = {
		
		
	}
	
	local trres = util.TraceHull( tr )
	
	if owner:IsPlayer() then
		owner:LagCompensation( false )
	end
end

--remove even when we've been dropped to the ground
function SWEP:OnDrop()
	self:DestroyVortigauntSounds()
	--self:Remove()
end

--shut down sounds, particles and whatever is left
function SWEP:OnRemove()
	self:DestroyVortigauntSounds()
	if CLIENT then
		self:DestroyVortigauntParticles()
	end
end