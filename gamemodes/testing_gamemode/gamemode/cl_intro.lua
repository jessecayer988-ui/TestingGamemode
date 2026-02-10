TestingIntro = TestingIntro or {}
local Intro = TestingIntro

Intro.INTRO_PENDING_KEY = "TestingIntroPending"
Intro.INTRO_CONTINUE_COMMAND = "testing_intro_continue"
Intro.HAS_CHARACTER_KEY = "TestingHasCharacter"
Intro.CHARACTER_CREATE_NET = "testing_character_create"
Intro.CHARACTER_FEEDBACK_NET = "testing_character_feedback"

Intro.MENU_MUSIC_PATH = "music/hl1_song3.mp3"
Intro.MENU_MUSIC_VOLUME = 0.45
Intro.MENU_MUSIC_FADE_SECONDS = 2
Intro.BUTTON_ROLLOVER_SOUND = "ui/buttonrollover.wav"
Intro.BUTTON_CLICK_SOUND = "ui/buttonclick.wav"
Intro.COMMUNITY_LINK_URL = "https://discord.gg/WhA3cJWDMV"
Intro.VIEW_FADE_DURATION = 0.12
Intro.TYPE_CHARACTER_INTERVAL = 0.018

Intro.panel = nil
Intro.controls = {}
Intro.currentView = "main"
Intro.textAnimationStart = 0
Intro.isViewTransitioning = false
Intro.transitionStartTime = 0
Intro.transitionMidTime = 0
Intro.transitionEndTime = 0
Intro.transitionSwapped = false
Intro.transitionTargetView = nil
Intro.transitionBuildFunc = nil
Intro.menuMusic = nil
Intro.menuMusicPlaying = false

surface.CreateFont("TestingIntro_Title", {
    font = "Trebuchet24",
    size = 84,
    weight = 950,
    antialias = true,
})

surface.CreateFont("TestingIntro_Button", {
    font = "Trebuchet24",
    size = 34,
    weight = 800,
    antialias = true,
})

surface.CreateFont("TestingIntro_Label", {
    font = "Trebuchet24",
    size = 28,
    weight = 700,
    antialias = true,
})

function Intro.ClearControls()
    for _, control in ipairs(Intro.controls) do
        if IsValid(control) then
            control:Remove()
        end
    end

    Intro.controls = {}
end

function Intro.AddControl(control)
    table.insert(Intro.controls, control)

    return control
end

function Intro.PlayUISound(soundPath)
    if soundPath then
        surface.PlaySound(soundPath)
    end
end

function Intro.BeginTextAnimation()
    Intro.textAnimationStart = CurTime()
end

function Intro.GetTypedText(text, delay)
    if not text then
        return ""
    end

    local elapsed = CurTime() - Intro.textAnimationStart - (delay or 0)

    if elapsed <= 0 then
        return ""
    end

    local visibleCharacters = math.floor(elapsed / Intro.TYPE_CHARACTER_INTERVAL)

    return string.sub(text, 1, math.Clamp(visibleCharacters, 0, #text))
end

function Intro.GetTransitionAlpha()
    if not Intro.isViewTransitioning then
        return 255
    end

    local now = CurTime()

    if now < Intro.transitionMidTime then
        local progress = math.TimeFraction(Intro.transitionStartTime, Intro.transitionMidTime, now)

        return math.Clamp(255 * (1 - progress), 0, 255)
    end

    local progress = math.TimeFraction(Intro.transitionMidTime, Intro.transitionEndTime, now)

    return math.Clamp(255 * progress, 0, 255)
end

function Intro.StartViewTransition(targetView, buildFunc)
    if Intro.isViewTransitioning or Intro.currentView == targetView then
        return
    end

    Intro.isViewTransitioning = true
    Intro.transitionStartTime = CurTime()
    Intro.transitionMidTime = Intro.transitionStartTime + Intro.VIEW_FADE_DURATION
    Intro.transitionEndTime = Intro.transitionMidTime + Intro.VIEW_FADE_DURATION
    Intro.transitionSwapped = false
    Intro.transitionTargetView = targetView
    Intro.transitionBuildFunc = buildFunc
end

function Intro.UpdateViewTransition()
    if not Intro.isViewTransitioning then
        return
    end

    local now = CurTime()

    if not Intro.transitionSwapped and now >= Intro.transitionMidTime then
        Intro.transitionSwapped = true
        Intro.currentView = Intro.transitionTargetView or Intro.currentView

        Intro.ClearControls()

        if Intro.transitionBuildFunc then
            Intro.transitionBuildFunc()
        end

        Intro.BeginTextAnimation()
    end

    if now >= Intro.transitionEndTime then
        Intro.isViewTransitioning = false
        Intro.transitionTargetView = nil
        Intro.transitionBuildFunc = nil
    end
end

function Intro.StartMenuMusic()
    if Intro.menuMusicPlaying then
        return
    end

    local ply = LocalPlayer()

    if not IsValid(ply) then
        return
    end

    Intro.menuMusic = Intro.menuMusic or CreateSound(ply, Intro.MENU_MUSIC_PATH)

    if not Intro.menuMusic then
        return
    end

    Intro.menuMusic:PlayEx(Intro.MENU_MUSIC_VOLUME, 100)
    Intro.menuMusicPlaying = true
end

function Intro.FadeOutMenuMusic(immediate)
    if not Intro.menuMusic then
        Intro.menuMusicPlaying = false

        return
    end

    if immediate then
        Intro.menuMusic:Stop()
    else
        Intro.menuMusic:FadeOut(Intro.MENU_MUSIC_FADE_SECONDS)
    end

    Intro.menuMusicPlaying = false
end

include("cl_intro_menu.lua")

function Intro.BuildIntroPanel()
    if IsValid(Intro.panel) then
        return
    end

    Intro.panel = vgui.Create("DPanel")
    Intro.panel:SetSize(ScrW(), ScrH())
    Intro.panel:SetPos(0, 0)
    Intro.panel:SetKeyboardInputEnabled(true)
    Intro.panel:SetMouseInputEnabled(true)
    Intro.panel:MakePopup()

    Intro.panel.Paint = function(_, w, h)
        local textAlpha = Intro.GetTransitionAlpha()

        draw.RoundedBox(0, 0, 0, w, h, Color(8, 10, 12, 255))
        draw.SimpleText(Intro.GetTypedText("A R T I S A N   C O R P."), "TestingIntro_Title", w * 0.06, h * 0.39, Color(238, 238, 238, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if Intro.currentView == "character_create" then
            draw.SimpleText(Intro.GetTypedText("Character Creation", 0.06), "TestingIntro_Label", w * 0.06, h * 0.41, Color(220, 220, 220, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    Intro.BeginTextAnimation()
    Intro.BuildMainMenu()
end

function Intro.RemoveIntroPanel()
    Intro.FadeOutMenuMusic()
    Intro.ClearControls()

    if IsValid(Intro.panel) then
        Intro.panel:Remove()
        Intro.panel = nil
    end
end

net.Receive(Intro.CHARACTER_FEEDBACK_NET, function()
    local success = net.ReadBool()
    local message = net.ReadString()

    if message ~= "" then
        notification.AddLegacy(message, success and NOTIFY_HINT or NOTIFY_ERROR, 3)
    end
end)

hook.Add("Think", "TestingGamemode_IntroMenuThink", function()
    local ply = LocalPlayer()

    if not IsValid(ply) then
        Intro.FadeOutMenuMusic(true)
        Intro.RemoveIntroPanel()

        return
    end

    if ply:GetNWBool(Intro.INTRO_PENDING_KEY, false) then
        Intro.BuildIntroPanel()
        Intro.UpdateViewTransition()
        Intro.StartMenuMusic()
    else
        Intro.RemoveIntroPanel()
    end
end)

hook.Add("ShutDown", "TestingGamemode_IntroMenuMusicShutdown", function()
    Intro.FadeOutMenuMusic(true)
end)
