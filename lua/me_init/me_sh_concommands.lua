local ConVars = {}

// LEGION
ConVars["sk_legion_health"] = 250
ConVars["sk_legion_dmg_slash"] = 10
ConVars["sk_legion_dmg_bullet"] = 9

for cvar,val in pairs(ConVars) do
	CreateConVar(cvar,val,FCVAR_ARCHIVE)
end