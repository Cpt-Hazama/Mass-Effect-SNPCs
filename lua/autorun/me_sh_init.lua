if(!SLVBase_Fixed) then
	include("slvbase/slvbase.lua")
	if(!SLVBase_Fixed) then return end
end
local addon = "Mass Effect"
if(SLVBase_Fixed.AddonInitialized(addon)) then return end
if(SERVER) then
	AddCSLuaFile("autorun/me_sh_init.lua")
	AddCSLuaFile("me_init/me_sh_concommands.lua")
	AddCSLuaFile("autorun/slvbase/slvbase.lua")
end
SLVBase_Fixed.AddDerivedAddon(addon,{tag = "Mass Effect"})
if(SERVER) then
	Add_NPC_Class("CLASS_GETH")
	Add_NPC_Class("CLASS_MECH")
	Add_NPC_Class("CLASS_THRESHERMAW")
	Add_NPC_Class("CLASS_VARREN")
end
SLVBase_Fixed.InitLua("me_init")

local Category = "Mass Effect"
SLVBase_Fixed.AddNPC(Category,"Legion","npc_legion")
SLVBase_Fixed.AddNPC(Category,"Threshermaw","npc_threshermaw")
SLVBase_Fixed.AddNPC(Category,"Varren","npc_varren")
SLVBase_Fixed.AddNPC(Category,"YMIR Mech","npc_ymir")