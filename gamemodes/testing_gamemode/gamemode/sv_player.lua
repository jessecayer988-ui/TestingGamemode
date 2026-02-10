local SLOT_COMMAND = "testing_select_slot"
local INTRO_CONTINUE_COMMAND = "testing_intro_continue"
local INTRO_PENDING_KEY = "TestingIntroPending"
local SELECTED_SLOT_KEY = "TestingSelectedSlot"

local CHARACTER_CREATE_NET = "testing_character_create"
local CHARACTER_FEEDBACK_NET = "testing_character_feedback"
local HAS_CHARACTER_KEY = "TestingHasCharacter"
local CHARACTER_NAME_KEY = "TestingCharacterName"
local CHARACTER_OCCUPATION_KEY = "TestingCharacterOccupation"
local CHARACTER_SKILL_KEY = "TestingCharacterSkill"
local CHARACTER_GENDER_KEY = "TestingCharacterGender"
local CHARACTER_MODEL_KEY = "TestingCharacterModel"
local CHARACTER_SKIN_KEY = "TestingCharacterSkin"

util.AddNetworkString(CHARACTER_CREATE_NET)
util.AddNetworkString(CHARACTER_FEEDBACK_NET)

local occupations = {
    ["Scientist"] = {
        skills = {
            ["Weapons Research"] = true,
            ["Physics Research"] = true,
            ["Biology Research"] = true,
        },
    },
    ["Security"] = {
        skills = {
            ["Brawler"] = true,
            ["Accurate"] = true,
            ["Brave"] = true,
        },
    },
    ["Engineer"] = {
        skills = {
            ["Fast"] = true,
            ["Efficient"] = true,
            ["Skilled"] = true,
        },
    },
}


local genderModels = {
    ["Male"] = {
        ["models/ug/humans/male_01.mdl"] = true,
        ["models/ug/humans/male_02.mdl"] = true,
        ["models/ug/humans/male_03.mdl"] = true,
        ["models/ug/humans/male_04.mdl"] = true,
        ["models/ug/humans/male_05.mdl"] = true,
        ["models/ug/humans/male_06.mdl"] = true,
        ["models/ug/humans/male_07.mdl"] = true,
        ["models/ug/humans/male_08.mdl"] = true,
        ["models/ug/humans/male_09.mdl"] = true,
    },
    ["Female"] = {
        ["models/ug/humans/female_01.mdl"] = true,
        ["models/ug/humans/female_02.mdl"] = true,
        ["models/ug/humans/female_03.mdl"] = true,
        ["models/ug/humans/female_04.mdl"] = true,
        ["models/ug/humans/female_06.mdl"] = true,
        ["models/ug/humans/female_07.mdl"] = true,
    },
}

local allowedFirstNames = {
    ["Albert"] = true,
    ["Gordon"] = true,
    ["Walter"] = true,
    ["Richard"] = true,
    ["Alan"] = true,
    ["Luther"] = true,
    ["Barney"] = true,
    ["John"] = true,
    ["Wallace"] = true,
    ["Isaac"] = true,
    ["Charles"] = true,
    ["Stephen"] = true,
}

local allowedLastNames = {
    ["Hawking"] = true,
    ["Heisenberg"] = true,
    ["Darwin"] = true,
    ["Einstein"] = true,
    ["Slick"] = true,
    ["Pauling"] = true,
    ["Kelper"] = true,
    ["Herschel"] = true,
    ["Freeman"] = true,
    ["Schrödinger"] = true,
    ["Fischer"] = true,
    ["Callahan"] = true,
    ["Sinclair"] = true,
    ["Madrigal"] = true,
}

local blockedNamePairs = {
    ["Stephen"] = {
        ["Hawking"] = true,
    },
    ["Charles"] = {
        ["Darwin"] = true,
    },
    ["Albert"] = {
        ["Einstein"] = true,
    },
    ["Gordon"] = {
        ["Freeman"] = true,
    },
}

local function SendCharacterFeedback(ply, success, message)
    net.Start(CHARACTER_FEEDBACK_NET)
    net.WriteBool(success)
    net.WriteString(message or "")
    net.Send(ply)
end

local function SetIntroPending(ply, isPending)
    ply:SetNWBool(INTRO_PENDING_KEY, isPending)

    if isPending then
        ply:StripWeapons()
        ply:StripAmmo()
        ply:Spectate(OBS_MODE_ROAMING)
    else
        ply:UnSpectate()
    end
end

local function GetClampedSlot(slot)
    local slotNumber = math.floor(tonumber(slot) or 1)

    return math.Clamp(slotNumber, 1, GAMEMODE.TaskbarSlotCount or 8)
end

local function EquipSlotWeapon(ply, slot)
    local weaponClass = GAMEMODE:GetTaskbarWeaponForSlot(slot)

    ply:StripWeapons()

    if weaponClass then
        ply:Give(weaponClass)
        ply:SelectWeapon(weaponClass)
    end

    ply:SetNWInt(SELECTED_SLOT_KEY, slot)
end

function GM:LoadCharacterData(ply)
    local hasCharacter = ply:GetPData("testing_char_created", "0") == "1"

    ply:SetNWBool(HAS_CHARACTER_KEY, hasCharacter)

    if not hasCharacter then
        ply:SetNWString(CHARACTER_NAME_KEY, "")
        ply:SetNWString(CHARACTER_OCCUPATION_KEY, "")
        ply:SetNWString(CHARACTER_SKILL_KEY, "")
        ply:SetNWString(CHARACTER_GENDER_KEY, "")
        ply:SetNWString(CHARACTER_MODEL_KEY, "")
        ply:SetNWInt(CHARACTER_SKIN_KEY, 0)

        return false
    end

    ply:SetNWString(CHARACTER_NAME_KEY, ply:GetPData("testing_char_name", ""))
    ply:SetNWString(CHARACTER_OCCUPATION_KEY, ply:GetPData("testing_char_occupation", ""))
    ply:SetNWString(CHARACTER_SKILL_KEY, ply:GetPData("testing_char_skill", ""))
    ply:SetNWString(CHARACTER_GENDER_KEY, ply:GetPData("testing_char_gender", ""))
    ply:SetNWString(CHARACTER_MODEL_KEY, ply:GetPData("testing_char_model", ""))
    ply:SetNWInt(CHARACTER_SKIN_KEY, tonumber(ply:GetPData("testing_char_skin", "0")) or 0)

    return true
end

function GM:ApplyCharacterModel(ply)
    local gender = ply:GetNWString(CHARACTER_GENDER_KEY, "")
    local modelPath = ply:GetNWString(CHARACTER_MODEL_KEY, "")
    local skin = math.max(0, ply:GetNWInt(CHARACTER_SKIN_KEY, 0))

    if genderModels[gender] and genderModels[gender][modelPath] then
        ply:SetModel(modelPath)
        ply:SetSkin(skin)

        return
    end

    local occupation = ply:GetNWString(CHARACTER_OCCUPATION_KEY, "")

    if occupation == "Security" then
        ply:SetModel("models/vj_hlr/hl1/barney.mdl")
    else
        ply:SetModel("models/vj_hlr/hl1/scientist.mdl")
    end
end

function GM:SetPlayerIntroState(ply, isPending)
    if not IsValid(ply) then
        return
    end

    SetIntroPending(ply, isPending)
end

function GM:PlayerLoadout(ply)
    ply:StripWeapons()

    return true
end

function GM:PlayerSpawn(ply)
    player_manager.SetPlayerClass(ply, "player_testing")

    self.BaseClass.PlayerSpawn(self, ply)

    player_manager.RunClass(ply, "SetModel")
    player_manager.RunClass(ply, "Spawn")

    if ply:GetNWBool(INTRO_PENDING_KEY, false) then
        SetIntroPending(ply, true)

        return
    end

    self:ApplyCharacterModel(ply)
    EquipSlotWeapon(ply, 1)
end

concommand.Add(SLOT_COMMAND, function(ply, _, args)
    if not IsValid(ply) or ply:GetNWBool(INTRO_PENDING_KEY, false) then
        return
    end

    local slot = GetClampedSlot(args[1])

    EquipSlotWeapon(ply, slot)
end)

concommand.Add(INTRO_CONTINUE_COMMAND, function(ply)
    if not IsValid(ply) or not ply:GetNWBool(INTRO_PENDING_KEY, false) then
        return
    end

    if not ply:GetNWBool(HAS_CHARACTER_KEY, false) then
        SendCharacterFeedback(ply, false, "Create a character first.")

        return
    end

    SetIntroPending(ply, false)
    ply:Spawn()
end)

net.Receive(CHARACTER_CREATE_NET, function(_, ply)
    if not IsValid(ply) or not ply:GetNWBool(INTRO_PENDING_KEY, false) then
        return
    end

    local firstName = string.Trim(net.ReadString() or "")
    local lastName = string.Trim(net.ReadString() or "")
    local gender = string.Trim(net.ReadString() or "")
    local occupation = string.Trim(net.ReadString() or "")
    local skill = string.Trim(net.ReadString() or "")
    local modelPath = string.Trim(net.ReadString() or "")
    local skin = math.max(0, net.ReadUInt(8) or 0)
    local characterName = firstName .. " " .. lastName

    local occupationData = occupations[occupation]

    if not allowedFirstNames[firstName] or not allowedLastNames[lastName] then
        SendCharacterFeedback(ply, false, "Select valid first and last names.")

        return
    end

    if blockedNamePairs[firstName] and blockedNamePairs[firstName][lastName] then
        SendCharacterFeedback(ply, false, "That first and last name combination is not allowed.")

        return
    end


    if not genderModels[gender] then
        SendCharacterFeedback(ply, false, "Invalid gender selected.")

        return
    end

    if not genderModels[gender][modelPath] then
        SendCharacterFeedback(ply, false, "Invalid model selected for gender.")

        return
    end

    if not occupationData then
        SendCharacterFeedback(ply, false, "Invalid occupation selected.")

        return
    end

    if not occupationData.skills[skill] then
        SendCharacterFeedback(ply, false, "Invalid skill selected for occupation.")

        return
    end

    ply:SetPData("testing_char_created", "1")
    ply:SetPData("testing_char_name", characterName)
    ply:SetPData("testing_char_occupation", occupation)
    ply:SetPData("testing_char_skill", skill)
    ply:SetPData("testing_char_gender", gender)
    ply:SetPData("testing_char_model", modelPath)
    ply:SetPData("testing_char_skin", tostring(skin))

    ply:SetNWBool(HAS_CHARACTER_KEY, true)
    ply:SetNWString(CHARACTER_NAME_KEY, characterName)
    ply:SetNWString(CHARACTER_OCCUPATION_KEY, occupation)
    ply:SetNWString(CHARACTER_SKILL_KEY, skill)
    ply:SetNWString(CHARACTER_GENDER_KEY, gender)
    ply:SetNWString(CHARACTER_MODEL_KEY, modelPath)
    ply:SetNWInt(CHARACTER_SKIN_KEY, skin)

    SendCharacterFeedback(ply, true, "Character created.")

    SetIntroPending(ply, false)
    ply:Spawn()
end)
