local SLOT_COMMAND = "testing_select_slot"
local SELECTED_SLOT_KEY = "TestingSelectedSlot"
local INTRO_PENDING_KEY = "TestingIntroPending"

local hiddenElements = {
    ["CHudHealth"] = false,
    ["CHudBattery"] = false,
    ["CHudAmmo"] = false,
    ["CHudSecondaryAmmo"] = false,
    ["CHudWeaponSelection"] = false,
}

surface.CreateFont("TestingHUD_Headline", {
    font = "Trebuchet24",
    size = 34,
    weight = 900,
    antialias = true,
})

surface.CreateFont("TestingHUD_Text", {
    font = "Trebuchet24",
    size = 28,
    weight = 700,
    antialias = true,
})

surface.CreateFont("TestingHUD_Small", {
    font = "Trebuchet24",
    size = 22,
    weight = 700,
    antialias = true,
})

surface.CreateFont("TestingHUD_Micro", {
    font = "Trebuchet24",
    size = 18,
    weight = 500,
    antialias = true,
})

local vignetteMaterial = Material("vgui/gradient-d")

local function DrawVignetteOverlay(screenW, screenH)
    local size = math.floor(math.max(screenW, screenH) * 0.6)
    local edge = math.floor(math.min(screenW, screenH) * 0.08)

    surface.SetMaterial(vignetteMaterial)

    surface.SetDrawColor(0, 0, 0, 22)
    surface.DrawTexturedRectRotated(screenW * 0.5, edge * 0.5, screenW, edge, 0)
    surface.DrawTexturedRectRotated(screenW * 0.5, screenH - (edge * 0.5), screenW, edge, 180)
    surface.DrawTexturedRectRotated(edge * 0.5, screenH * 0.5, screenH, edge, 90)
    surface.DrawTexturedRectRotated(screenW - (edge * 0.5), screenH * 0.5, screenH, edge, -90)

    surface.SetDrawColor(0, 0, 0, 78)
    surface.DrawTexturedRectRotated(-size * 0.2, -size * 0.2, size, size, 45)
    surface.DrawTexturedRectRotated(screenW + (size * 0.2), -size * 0.2, size, size, 135)
    surface.DrawTexturedRectRotated(-size * 0.2, screenH + (size * 0.2), size, size, -45)
    surface.DrawTexturedRectRotated(screenW + (size * 0.2), screenH + (size * 0.2), size, size, -135)
end

local function DrawLeftStatusColumn(screenH)
    local baseY = screenH * 0.58
    local iconSize = 58
    local gap = 10

    local iconColors = {
        Color(240, 219, 132, 220),
        Color(215, 165, 122, 220),
        Color(156, 240, 201, 220),
        Color(145, 232, 188, 220),
        Color(180, 248, 209, 220),
    }

    for index, iconColor in ipairs(iconColors) do
        local y = baseY + ((index - 1) * (iconSize + gap))
        draw.RoundedBox(iconSize / 2, 18, y, iconSize, iconSize, Color(6, 20, 42, 180))
        draw.RoundedBox(iconSize / 2, 21, y + 3, iconSize - 6, iconSize - 6, iconColor)
        draw.SimpleText(index, "TestingHUD_Micro", 47, y + 28, Color(25, 35, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local function GetDisplayWeaponName(ply)
    local activeWeapon = ply:GetActiveWeapon()

    if not IsValid(activeWeapon) then
        return "Unarmed"
    end

    local printed = activeWeapon:GetPrintName()

    if printed and printed ~= "" and printed ~= "#HL2_Crowbar" then
        return printed
    end

    if activeWeapon:GetClass() == "weapon_crowbar" then
        return "Crowbar"
    end

    return activeWeapon:GetClass()
end

local function DrawWeaponStrip(ply, screenW, screenH)
    local slotCount = GAMEMODE.TaskbarSlotCount or 8
    local stripW = 460
    local stripH = 90
    local x = (screenW - stripW) * 0.5
    local y = screenH - 105
    local selectedSlot = ply:GetNWInt(SELECTED_SLOT_KEY, 1)

    draw.RoundedBox(10, x, y, stripW, stripH, Color(7, 20, 36, 190))

    local slotW = 52
    local slotGap = 4

    for index = 1, slotCount do
        local slotX = x + 10 + ((index - 1) * (slotW + slotGap))
        local selected = selectedSlot == index
        local weaponClass = GAMEMODE:GetTaskbarWeaponForSlot(index)
        local isEmpty = weaponClass == nil

        draw.RoundedBox(6, slotX, y + 18, slotW, 60, selected and Color(108, 255, 206, 190) or Color(110, 214, 219, 100))
        draw.SimpleText(index, "TestingHUD_Micro", slotX + 6, y + 8, Color(135, 227, 255), TEXT_ALIGN_LEFT)
        draw.SimpleText(isEmpty and "-" or "W", "TestingHUD_Text", slotX + (slotW * 0.5), y + 47, Color(12, 30, 45, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    draw.SimpleText(GetDisplayWeaponName(ply), "TestingHUD_Small", x, y - 24, Color(150, 235, 255), TEXT_ALIGN_LEFT)
end

local function DrawAmmoAndHints(ply, screenW, screenH)
    local weapon = ply:GetActiveWeapon()
    local clip = "--"
    local reserve = "--"

    if IsValid(weapon) then
        if weapon:Clip1() >= 0 then
            clip = tostring(weapon:Clip1())
        end

        local reserveAmmo = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())

        if reserveAmmo >= 0 then
            reserve = tostring(reserveAmmo)
        end
    end

    draw.SimpleText(clip .. "|" .. reserve, "TestingHUD_Headline", screenW - 200, screenH - 70, Color(154, 236, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    local controls = {
        "Slot 1-8  [1-8]",
        "Reload  [R]",
        "Zoom  [Mouse2]",
        "Holster  [H]",
        "Light  [V]",
    }

    local controlsY = screenH * 0.74

    for index, label in ipairs(controls) do
        draw.SimpleText(label, "TestingHUD_Text", screenW - 270, controlsY + ((index - 1) * 42), Color(164, 238, 255), TEXT_ALIGN_LEFT)
    end
end

function GM:HUDShouldDraw(name)
    if hiddenElements[name] ~= nil then
        return hiddenElements[name]
    end

    return self.BaseClass.HUDShouldDraw(self, name)
end

function GM:PlayerBindPress(_, bind, pressed)
    if not pressed then
        return
    end

    local focusPanel = vgui.GetKeyboardFocus()

    if IsValid(focusPanel) and focusPanel:IsA("DTextEntry") then
        return true
    end

    local slot = bind:match("^slot(%d+)$")

    if slot then
        RunConsoleCommand(SLOT_COMMAND, slot)

        return true
    end
end

function GM:RenderScreenspaceEffects()
    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 0.8,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0,
    })
end

function GM:HUDPaint()
    local ply = LocalPlayer()

    if not IsValid(ply) then
        return
    end

    local screenW, screenH = ScrW(), ScrH()

    if ply:GetNWBool(INTRO_PENDING_KEY, false) then
        DrawVignetteOverlay(screenW, screenH)

        return
    end

    DrawLeftStatusColumn(screenH)
    DrawWeaponStrip(ply, screenW, screenH)
    DrawAmmoAndHints(ply, screenW, screenH)
    DrawVignetteOverlay(screenW, screenH)
end