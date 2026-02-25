AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("init_loader.lua")

function GM:InitPostEntity()
    print("[Testing Gamemode] Server initialized")
end

function GM:PlayerInitialSpawn(ply)
    ply:ChatPrint("Welcome to Testing Gamemode!")
    self:LoadCharacterData(ply)
    self:SetPlayerIntroState(ply, true)
end
