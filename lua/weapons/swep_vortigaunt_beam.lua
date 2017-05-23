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
	DamageForce = 48000, --remove one zero if it's too much
	Range = 2400,
	ChargeTime = 1.25,
	SplashRadius = 48, --increase to crowbar range (75) if too low
	BeamHitbox = {
		Min = Vector( -16 , -16 , -16 ),
		Max = Vector( 16 , 16 , 16 ),
	},
	Sounds = {
		Attack = "swep_vortigaunt_beam.attack",
		Charge = "swep_vortigaunt_beam.charge",
		HealLoop = "swep_vortigaunt_beam.healloop",
		HealHealth = "swep_vortigaunt_beam.healhealth",
		HealArmor = "swep_vortigaunt_beam.healarmor",
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

sound.Add({
	name = SWEP.Beam.Sounds.Attack,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 75,
	pitch = { 130 , 160 },
	sound = "npc/vort/attack_shoot.wav"
})

sound.Add({
	name = SWEP.Beam.Sounds.Charge,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 75,
	pitch = 100,
	sound = "npc/vort/attack_charge.wav"
})

sound.Add({
	name = SWEP.Beam.Sounds.HealLoop,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 75,
	pitch = 100,
	sound = "npc/vort/health_charge.wav"
})

sound.Add({
	name = SWEP.Beam.Sounds.HealArmor,
	channel = CHAN_ITEM,
	volume = 0.85,
	level = 75,
	pitch = 100,
	sound = "items/suitchargeok1.wav"
})

sound.Add({
	name = SWEP.Beam.Sounds.HealHealth,
	channel = CHAN_ITEM,
	volume = 0.85,
	level = 75,
	pitch = 100,
	sound = "items/smallmedkit1.wav"
})


if SERVER then

else
	--worldmodel particles when not equipped, attaches to weapon
	AccessorFunc( SWEP , "_vchargeparticle_sa" , "VortigauntChargeParticleSA" )
	
	--worldmodel particles when equipped on a player, attaches to player
	AccessorFunc( SWEP , "_vchargeparticle_wm" , "VortigauntChargeParticleWM" )
	AccessorFunc( SWEP , "_vhealparticle_wm" , "VortigauntHealParticleWM" )
	AccessorFunc( SWEP , "_vidleparticle_wm" , "VortigauntIdleParticleWM" )

	--viewmodel particles when equipped on a player, attaches to viewmodel
	AccessorFunc( SWEP , "_vchargeparticle_vm" , "VortigauntChargeParticleVM" )
	AccessorFunc( SWEP , "_vhealparticle_vm" , "VortigauntHealParticleVM" )
	AccessorFunc( SWEP , "_vidleparticle_vm" , "VortigauntIdleParticleVM" )
	
	
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
		self:DrawWorldModelTranslucent()
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
			self:DrawVortigauntParticlesWorldModel( ent )
		else
			self:DrawVortigauntParticlesFirstPerson( ent )
		end
	end
	
	function SWEP:DrawVortigauntParticlesStandalone()
		if IsValid( self:GetVortigauntChargeParticleSA() ) then
			
			if self:GetVortigauntChargeParticleSA():IsFinished() then
				self:GetVortigauntChargeParticleSA():StartEmission()
			end

			self:GetVortigauntChargeParticleSA():Render()
		end
	end
	
	local wireframe = Material( "models/wireframe" )
	
	function SWEP:DrawVortigauntParticlesFirstPerson( vm )
	
		local attachment = "muzzle"
		local pos = vector_origin
		local ang = angle_zero
		local attachtab = vm:GetAttachment( vm:LookupAttachment( attachment ) )
		
		if attachtab then
			pos = attachtab.Pos
			ang = attachtab.Ang
			local boneid = vm:LookupBone( "ValveBiped.Bip01_R_Hand" )
			
			if boneid then
				local bm = vm:GetBoneMatrix( boneid )
				
				pos = bm:GetTranslation()
				ang = bm:GetAngles()
			end
		end
		
		if IsValid( self:GetVortigauntChargeParticleVM() ) then
			
			if self:GetVortigauntChargeParticleVM():IsFinished() then
				self:GetVortigauntChargeParticleVM():StartEmission()
			end
			
			--[[			
			
			self:GetVortigauntChargeParticle():SetSortOrigin( pos )
			self:GetVortigauntChargeParticle():SetControlPoint( 0 , pos )
			]]
			self:GetVortigauntChargeParticleVM():SetControlPointEntity( 0 , vm )
			self:GetVortigauntChargeParticleVM():SetSortOrigin( pos )
			self:GetVortigauntChargeParticleVM():SetControlPoint( 0 , pos )
			
			self:GetVortigauntChargeParticleVM():Render()
			render.SetMaterial( wireframe )
			render.DrawSphere( pos , 2 , 16 , 16 , color_white )
		end
	end
	
	function SWEP:DrawVortigauntParticlesWorldModel( ply )
	
	end
	
	function SWEP:CheckVortigauntParticles()
		--standalone particle
		if not IsValid( self:GetVortigauntChargeParticleSA() ) then
			local particle = CreateParticleSystem( self , "vortigaunt_charge_token" , PATTACH_ABSORIGIN_FOLLOW )
			particle:SetShouldDraw( false )
			self:SetVortigauntChargeParticleSA( particle )
		end
		
		--worldmodel particles
		
		--viewmodel particles
		
		
		if not IsValid( self:GetVortigauntChargeParticleVM() ) then
			--try to get the viewmodel, fail otherwise
			local ent = nil
			
			if IsValid( self:GetOwner() ) and self:GetOwner():IsPlayer() and IsValid( self:GetOwner():GetViewModel( 0 ) ) then
				ent = self:GetOwner():GetViewModel( 0 )
			end
			
			if IsValid( ent ) then
				local particle = CreateParticleSystem( self , "vortigaunt_charge_token" , PATTACH_CUSTOMORIGIN )
				--local particle = CreateParticleSystem( ent , "vortigaunt_charge_token" , PATTACH_POINT_FOLLOW , ent:LookupAttachment( "muzzle" ) )
				particle:SetShouldDraw( false )
				particle:SetIsViewModelEffect( true )
				self:SetVortigauntChargeParticleVM( particle )
			end
		end
		
	end
	
	function SWEP:DestroyVortigauntParticles()
		--standalone
		if IsValid( self:GetVortigauntChargeParticleSA() ) then
			self:GetVortigauntChargeParticleSA():StopEmissionAndDestroyImmediately()
			self:SetVortigauntChargeParticleSA( nil )
		end
		
		--worldmodel
		
		if IsValid( self:GetVortigauntChargeParticleWM() ) then
			self:GetVortigauntChargeParticleWM():StopEmissionAndDestroyImmediately()
			self:SetVortigauntChargeParticleWM( nil )
		end
		
		if IsValid( self:GetVortigauntIdleParticleWM() ) then
			self:GetVortigauntIdleParticleWM():StopEmissionAndDestroyImmediately()
			self:SetVortigauntIdleParticleWM( nil )
		end
		
		if IsValid( self:GetVortigauntHealParticleWM() ) then
			self:GetVortigauntHealParticleWM():StopEmissionAndDestroyImmediately()
			self:SetVortigauntHealParticleWM( nil )
		end
		
		--viewmodel
		
		if IsValid( self:GetVortigauntChargeParticleVM() ) then
			self:GetVortigauntChargeParticleVM():StopEmissionAndDestroyImmediately()
			self:SetVortigauntChargeParticleVM( nil )
		end
		
		if IsValid( self:GetVortigauntIdleParticleVM() ) then
			self:GetVortigauntIdleParticleVM():StopEmissionAndDestroyImmediately()
			self:SetVortigauntIdleParticleVM( nil )
		end
		
		if IsValid( self:GetVortigauntHealParticleVM() ) then
			self:GetVortigauntHealParticleVM():StopEmissionAndDestroyImmediately()
			self:SetVortigauntHealParticleVM( nil )
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