AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:SetupSLVFactions()
	self:SetNPCFaction(NPC_FACTION_PLAYER,CLASS_PLAYER_ALLY)
end

ENT.sModel = "models/masseffect/legion.mdl"

ENT.HasMeleeAttack = false
ENT.fMeleeDistance = 40
ENT.fRangeDistance = 900
ENT.WeaponLists = {"weapon_shuriken"}
ENT.WeaponEquip = ACT_ARM
ENT.WeaponUnequip = ACT_DISARM
ENT.WeaponRun = ACT_RUN_AIM
ENT.WeaponWalk = ACT_WALK_AIM
ENT.WeaponMuzzle = "muzzleA"
ENT.WeaponFire = "cb_firestart"
ENT.WeaponReload = "cb_reload"

ENT.bFlinchOnDamage = true
ENT.m_bForceDeathAnim = true
ENT.UseActivityTranslator = false
ENT.BoneRagdollMain = "NPC Root [Root]"
ENT.skName = "legion"
ENT.CollisionBounds = Vector(20,20,80)
ENT.iBloodType = "impact_metal"

ENT.HasMeleeAttack = true

ENT.DamageScales = {
	[DMG_PARALYZE] = 0,
	[DMG_NERVEGAS] = 0,
	[DMG_POISON] = 0
}

ENT.sSoundDir = "npc/legion/"

ENT.m_tbSounds = {
	["Death"] = "legion_death0[1-6].mp3",
	["Pain"] = "legion_injured0[1-9].mp3",
	["NormalToCombat"] = "legion_alert0[1-9].mp3",
	["CombatToNormal"] = "legion_areaclear0[1-9].mp3",
	["Foot"] = "legion_foot0[1-3].wav"
}

ENT.tblFlinchActivities = {
	[HITBOX_GENERIC] = ACT_FLINCH_STOMACH,
	[HITBOX_HEAD] = ACT_FLINCH_CHEST,
	[HITBOX_LEFTARM] = ACT_FLINCH_LEFTARM,
	[HITBOX_RIGHTARM] = ACT_FLINCH_RIGHTARM,
	[HITBOX_LEFTLEG] = ACT_BIG_FLINCH,
	[HITBOX_RIGHTLEG] = ACT_BIG_FLINCH
}

ENT.bPlayDeathSequence = true
ENT.tblDeathActivities = {
	[HITBOX_GENERIC] = ACT_DIE_GUTSHOT,
	[HITBOX_HEAD] = ACT_FLINCH_CHEST,
	[HITBOX_LEFTARM] = ACT_DIE_FRONTSIDE,
	[HITBOX_RIGHTARM] = ACT_DIE_BACKSIDE,
	[HITBOX_LEFTLEG] = ACT_DIE_LEFTSIDE,
	[HITBOX_RIGHTLEG] = ACT_DIE_RIGHTSIDE
}

function ENT:_init()
	local eyeglow = ents.Create("env_sprite")
	eyeglow:SetKeyValue("model","vj_base/sprites/vj_glow1.vmt")
	eyeglow:SetKeyValue("scale","0.1")
	eyeglow:SetKeyValue("rendermode","5")
	eyeglow:SetKeyValue("rendercolor","0 208 225 255")
	eyeglow:SetKeyValue("spawnflags","1") -- If animated
	eyeglow:SetParent(self)
	eyeglow:Fire("SetParentAttachment","light",0)
	eyeglow:Spawn()
	eyeglow:Activate()
	self:DeleteOnRemove(eyeglow)
	self.spotlightpoint = ents.Create("env_projectedtexture")
	self.spotlightpoint:SetPos( self:GetPos() + Vector(0,0,0) )
	self.spotlightpoint:SetAngles( self:GetAngles() + Angle(0,0,0) )
	self.spotlightpoint:SetKeyValue('lightcolor', "0 208 225 255")
	self.spotlightpoint:SetKeyValue('lightfov', '40')
	self.spotlightpoint:SetKeyValue('farz', '612')
	self.spotlightpoint:SetKeyValue('nearz', '0.1')
	self.spotlightpoint:SetKeyValue('shadowquality', '0')
	self.spotlightpoint:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
	self.spotlightpoint:SetOwner( self.Owner )
	self.spotlightpoint:SetParent(self)
	self.spotlightpoint:Spawn()
	self.spotlightpoint:Activate()
	self.spotlightpoint:Fire("setparentattachment", "light")
	self.spotlightpoint:DeleteOnRemove(self)
	self.spotlight = ents.Create("point_spotlight")
	self.spotlight:SetPos( self:GetPos() + Vector(0,0,0) )
	self.spotlight:SetAngles( self.spotlightpoint:GetAngles() + Angle(0,0,0) )
	self.spotlight:SetKeyValue( "spawnflags", "3" )
	self.spotlight:SetKeyValue( "spotlightlength", "20" )
	self.spotlight:SetKeyValue( "spotlightwidth", "20" )
	self.spotlight:SetColor(Color(0,208,225,255))
	self.spotlight:SetOwner( self.Owner )
	self.spotlight:SetParent(self)
	self.spotlight:Spawn()
	self.spotlight:Activate()
	self.spotlight:Fire("SetParentAttachment", "light")
	self.spotlight:DeleteOnRemove(self)
end

function ENT:Removed()
	if IsValid(self.spotlight) then
		self.spotlight:SetParent()
		self.spotlight:Fire("lightoff")
		self.spotlight:Fire("kill",self.spotlight, 0.5)
	end
end

local pos = Vector(0,0,0)
local speed = 10
local parameters = {"aim_pitch","aim_yaw","head_pitch","head_yaw"}
function ENT:OnThink()
	self:UpdateLastEnemyPositions()
	if self:GetEnemy() != nil && !bPossessed then
		pos = self:GetEnemy():GetCenter()
		speed = 10
		parameters = {"aim_pitch","aim_yaw","head_pitch","head_yaw"}
	elseif bPossessed then
		pos = self:GetPossessor():GetPossessionEyeTrace().HitPos
		speed = 10
		parameters = {"aim_pitch","aim_yaw","head_pitch","head_yaw"}
	elseif self:GetEnemy() == nil && !bPossessed then
		for _,o in ipairs(ents.FindInSphere(self:GetPos(),300)) do
			if ((o:IsNPC() && o != self) or o:IsPlayer()) && o:Visible(self) && !bPossessed then
				pos = o:GetCenter()
				speed = 2
				parameters = {"head_pitch","head_yaw"}
			end
		end
	end
	if pos != Vector(0,0,0) or pos != nil then
		local selfpos = self:GetPos() +self:OBBCenter()
		local selfang = self:GetAngles()
		local targetang = (pos - selfpos):Angle()
		local pitch = math.AngleDifference(targetang.p,selfang.p)
		local yaw = math.AngleDifference(targetang.y,selfang.y)
		for _,v in ipairs(parameters) do
			if string.find(v,"pitch") then
				self:SetPoseParameter(v,math.ApproachAngle(self:GetPoseParameter(v),pitch,speed))
			end
			if string.find(v,"yaw") then
				self:SetPoseParameter(v,math.ApproachAngle(self:GetPoseParameter(v),yaw,speed))
			end
		end
	end
	self:NextThink(CurTime())
	return true
end

function ENT:EventHandle(...)
	local event = select(1,...)
	if(event == "mattack") then
		local dist = self.fMeleeDistance
		local skDmg = GetConVarNumber("sk_" .. self.skName .. "_dmg_slash")
		local force = Vector(50,0,0)
		local ang = Angle(50,0,0)
		self:DealMeleeDamage(dist,skDmg,ang,force,DMG_SLASH,nil,true,nil,fcHit)
		return true
	end
	if(event == "rattack") then
		if self:GetActiveWeapon() != nil && IsValid(self:GetActiveWeapon()) then
			self:GetActiveWeapon():DoPrimaryAttack(ShootPos,ShootDir)
		end
		return true
	end
	if(event == "reload") then
		return true
	end
	if(event == "idlearmed") then
		return true
	end
	if(event == "disarm") then
		return true
	end
end