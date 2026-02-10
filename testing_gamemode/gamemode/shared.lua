GM.Name = "Testing Gamemode"
GM.Author = "TestingGamemode"
GM.Email = ""
GM.Website = ""

DeriveGamemode("sandbox")

GM.TeamBased = false

GM.TaskbarSlots = {
    [1] = "weapon_crowbar",
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
    [6] = nil,
    [7] = nil,
    [8] = nil,
}

GM.TaskbarSlotCount = 8

function GM:GetTaskbarWeaponForSlot(slot)
    return self.TaskbarSlots[slot]
end

function GM:Initialize()
    self.BaseClass.Initialize(self)
    print("[Testing Gamemode] Shared initialization complete")
end