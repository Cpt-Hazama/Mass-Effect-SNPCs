SWEP.Author = "Cpt. Hazama"
SWEP.Contact = "Silverlan@gmx.de"
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.HoldType = "pistol"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"
SWEP.AnimPrefix		= "python"

SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.AmmoPickup	= 32
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoSize = -1
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.AmmoPickup	= 0

SWEP.Type = "pistol"
SWEP.Base = "ai_translator"
SWEP.DelayEquip = 0
SWEP.PrimaryClip = 0

function SWEP:Initialize()
	-- self:SetNoDraw(true)
	-- self:DrawShadow(false)
	self.Type = self.HoldType
	if(SERVER) then self:InitSounds() end
end

function SWEP:InitSounds() end

function SWEP:Undeploy()
	self.Weapon:SetNextSecondaryFire(CurTime() +999)
	self.Weapon:SetNextPrimaryFire(CurTime() +999)
	if(SERVER) then self:UndeploySounds() end
end

function SWEP:UndeploySounds() end

function SWEP:Equip(owner)
	self:SetNoDraw(true)
	self:DrawShadow(false)
	local fnext = CurTime() +self.DelayEquip
	self:SetNextPrimaryFire(fnext)
	self:SetNextSecondaryFire(fnext)
end

local acts = {
	["pistol"] = {
		[ACT_IDLE] = ACT_IDLE_AIM_RELAXED,
		[ACT_WALK] = ACT_WALK_AIM,
		[ACT_RUN] = ACT_RUN_AIM,
		[ACT_MELEE_ATTACK1] = ACT_MELEE_ATTACK1,
		[ACT_ARM] = ACT_ARM,
		[ACT_DISARM] = ACT_DISARM
	}
}

function SWEP:TranslateActivity(act)
	local holdType = self.HoldType
	if(holdType && acts[holdType] && acts[holdType][act]) then act = acts[holdType][act] end
	local owner = self:GetOwner()
	return IsValid(owner) && owner:TranslateActivity(act) || act
end

local gestures = {
	["pistol"] = {
		[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK1,
		[ACT_RELOAD] = ACT_RELOAD
	}
}

function SWEP:TranslateGesture(act)
	local holdType = self.HoldType
	if(holdType && gestures[holdType] && gestures[holdType][act]) then act = gestures[holdType][act] end
	local owner = self:GetOwner()
	return IsValid(owner) && owner:TranslateGesture(act) || act
end

function SWEP:PrimaryAttack(pos,dir)
	if self.PrimaryClip <= 0 then return self:DoReload() end
	if(CurTime() < self:GetNextPrimaryFire()) then return end
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:DoPrimaryAttack(pos,dir)
end

function SWEP:DoPrimaryAttack(ShootPos,ShootDir)
	if self.PrimaryClip <= 0 then return self:DoReload() end
	if(CurTime() < self:GetNextPrimaryFire()) then return end
	self.Weapon:SetNextSecondaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	self.Weapon:Attack(self.Primary.Cone,ShootPos,ShootDir)
	timer.Simple(0.12,function() if self:IsValid() && self.Owner:IsValid() then self.Weapon:Attack(self.Primary.Cone,ShootPos,ShootDir) end end)
	timer.Simple(0.25,function() if self:IsValid() && self.Owner:IsValid() then self.Weapon:Attack(self.Primary.Cone,ShootPos,ShootDir) end end)
	if self.Weapon.OnPrimaryAttack then self.Weapon:OnPrimaryAttack() end
end

function SWEP:Attack(flCone, ShootPos, ShootDir)
	if self.Owner:GunTraceBlocked() then return end
	if SERVER then
		self:slvPlaySound("Primary")
		self.PrimaryClip = self.PrimaryClip -1
	end
	local iDmg = self.Weapon.Primary.Damage
	if type(iDmg) == "string" then iDmg = GetConVarNumber(iDmg) end
	self.Owner:PlayLayeredGesture("cb_firestart",2,1)
	self.Weapon:ShootBullet(iDmg, self.Weapon.Primary.NumShots, flCone, 1, self.Weapon.Primary.Force, ShootPos, ShootDir)
end

function SWEP:ShootBullet(damage, num_bullets, aimcone, tracer, force, ShootPos, ShootDir, bSecondary)
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector(aimcone, aimcone, 0)
	bullet.Tracer	= tracer || 1
	bullet.TracerName = "AR2Tracer"
	bullet.Force	= force || 1
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"
	
	self.Owner:FireBullets(bullet)
	
	self.Weapon:ShootEffects(bSecondary)
end

function SWEP:OnPrimaryAttack() end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
end