DEFINE_BASECLASS("player_sandbox")

local PLAYER = {}

PLAYER.DisplayName = "Tester"
PLAYER.WalkSpeed = 200
PLAYER.RunSpeed = 350
PLAYER.JumpPower = 200

function PLAYER:Loadout()
    -- Loadout is controlled explicitly by server slot logic in sv_player.lua.
end

player_manager.RegisterClass("player_testing", PLAYER, "player_sandbox")
