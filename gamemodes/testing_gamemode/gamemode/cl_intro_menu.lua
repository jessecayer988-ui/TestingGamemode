local Intro = TestingIntro

Intro.occupationSkills = {
    ["Scientist"] = {
        "Weapons Research",
        "Physics Research",
        "Biology Research",
    },
    ["Security"] = {
        "Brawler",
        "Accurate",
        "Brave",
    },
    ["Engineer"] = {
        "Fast",
        "Efficient",
        "Skilled",
    },
}

Intro.occupationVoiceLines = {
    ["Scientist"] = {
        "vj_hlr/gsrc/npc/scientist/hello.wav",
        "vj_hlr/gsrc/npc/scientist/hellothere.wav",
        "vj_hlr/gsrc/npc/scientist/greetings2.wav",
    },
    ["Security"] = {
        "vj_hlr/gsrc/npc/barney/howyoudoing.wav",
        "vj_hlr/gsrc/npc/barney/hellonicesuit.wav",
        "vj_hlr/gsrc/npc/barney/heyfella.wav",
    },
}

Intro.genderModelOptions = {
    ["Male"] = {
        "models/ug/humans/male_01.mdl",
        "models/ug/humans/male_02.mdl",
        "models/ug/humans/male_03.mdl",
        "models/ug/humans/male_04.mdl",
        "models/ug/humans/male_05.mdl",
        "models/ug/humans/male_06.mdl",
        "models/ug/humans/male_07.mdl",
        "models/ug/humans/male_08.mdl",
        "models/ug/humans/male_09.mdl",
    },
    ["Female"] = {
        "models/ug/humans/female_01.mdl",
        "models/ug/humans/female_02.mdl",
        "models/ug/humans/female_03.mdl",
        "models/ug/humans/female_04.mdl",
        "models/ug/humans/female_06.mdl",
        "models/ug/humans/female_07.mdl",
    },
}

Intro.firstNameOptions = {
    "Albert",
    "Gordon",
    "Walter",
    "Richard",
    "Alan",
    "Luther",
    "Barney",
    "John",
    "Wallace",
    "Isaac",
    "Charles",
    "Stephen",
}

Intro.lastNameOptions = {
    "Hawking",
    "Heisenberg",
    "Darwin",
    "Einstein",
    "Slick",
    "Pauling",
    "Kelper",
    "Herschel",
    "Freeman",
    "Schrödinger",
    "Fischer",
    "Callahan",
    "Sinclair",
    "Madrigal",
}

Intro.blockedNamePairs = {
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

function Intro.PlayOccupationVoiceLine(occupation)
    local voiceLines = Intro.occupationVoiceLines[occupation]

    if voiceLines and #voiceLines > 0 then
        Intro.PlayUISound(voiceLines[math.random(#voiceLines)])
    end
end

function Intro.MakeMenuButton(label, index, onClick, options)
    options = options or {}

    local buttonW = options.width or (ScrW() * 0.30)
    local buttonH = options.height or 52
    local buttonX = options.x or (ScrW() * 0.06)
    local buttonY = options.y or ((ScrH() * 0.52) + (index * 62))

    local button = Intro.AddControl(vgui.Create("DButton", Intro.panel))

    button:SetText("")
    button:SetSize(buttonW, buttonH)
    button:SetPos(buttonX, buttonY)
    button:SetCursor("hand")

    button.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local alpha = Intro.GetTransitionAlpha()
        local displayedLabel = Intro.GetTypedText(label, 0.12)
        local fillColor = hovered and Color(255, 255, 255, math.min(24, alpha)) or Color(255, 255, 255, math.min(8, alpha))
        local textColor = hovered and Color(255, 255, 255, alpha) or Color(230, 230, 230, alpha)

        draw.RoundedBox(0, 0, 0, w, h, fillColor)
        draw.SimpleText(displayedLabel, "TestingIntro_Button", 12, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    button.OnCursorEntered = function()
        Intro.PlayUISound(Intro.BUTTON_ROLLOVER_SOUND)
    end

    button.DoClick = function(...)
        Intro.PlayUISound(Intro.BUTTON_CLICK_SOUND)

        if onClick then
            onClick(...)
        end
    end
end

function Intro.BuildMainMenu()
    Intro.currentView = "main"
    Intro.ClearControls()

    local hasCharacter = LocalPlayer():GetNWBool(Intro.HAS_CHARACTER_KEY, false)

    if hasCharacter then
        Intro.MakeMenuButton("LOAD CHARACTER", 0, function()
            RunConsoleCommand(Intro.INTRO_CONTINUE_COMMAND)
        end)
    else
        Intro.MakeMenuButton("NEW CHARACTER", 0, function()
            Intro.StartViewTransition("character_create", Intro.BuildCharacterCreationMenu)
        end)
    end

    Intro.MakeMenuButton("COMMUNITY", 1, function()
        gui.OpenURL(Intro.COMMUNITY_LINK_URL)
    end)

    Intro.MakeMenuButton("OPTIONS", 2, function()
        -- Reserved for future behavior.
    end)

    Intro.MakeMenuButton("DISCONNECT", 3, function()
        RunConsoleCommand("disconnect")
    end)
end

function Intro.BuildCharacterCreationMenu()
    Intro.currentView = "character_create"
    Intro.ClearControls()

    local panelW, panelH = ScrW(), ScrH()
    local formX = panelW * 0.06
    local formY = panelH * 0.44
    local fieldW = panelW * 0.34
    local rowGap = 72
    local labelHeight = 30
    local inputHeight = 40
    local inputOffsetY = 32

    local nameY = formY
    local genderY = nameY + rowGap
    local occupationY = genderY + rowGap
    local skillY = occupationY + rowGap
    local modelY = skillY + rowGap
    local buttonsY = modelY + rowGap + 14

    local previewW = panelW * 0.30
    local previewH = panelH * 0.50
    local previewX = panelW - previewW - (panelW * 0.06)
    local previewY = panelH * 0.22
    local previewOffset = 74
    local previewWalkDuration = 1.05

    local skinSlider = Intro.AddControl(vgui.Create("DNumSlider", Intro.panel))
    skinSlider:SetPos(previewX, previewY + previewH + 12)
    skinSlider:SetSize(previewW, 34)
    skinSlider:SetText("Skin")
    skinSlider:SetMin(0)
    skinSlider:SetMax(0)
    skinSlider:SetDecimals(0)
    skinSlider:SetValue(0)
    skinSlider:SetVisible(false)

    local activePreview
    local incomingPreview
    local activeModelPath
    local isUpdatingSkinSlider = false

    local function ConfigurePreviewPanel(panel)
        panel:SetPos(previewX, previewY)
        panel:SetSize(previewW, previewH)
        panel:SetFOV(32)
        panel:SetCamPos(Vector(72, 0, 44))
        panel:SetLookAt(Vector(0, 0, 34))
        panel:SetMouseInputEnabled(false)
        panel:SetVisible(false)

        panel.LayoutEntity = function(self, entity)
            if not IsValid(entity) then
                return
            end

            if self.walking then
                local progress = math.TimeFraction(self.walkStart, self.walkEnd, CurTime())

                if progress >= 1 then
                    progress = 1
                    self.walking = false
                end

                self.offsetY = Lerp(progress, self.fromOffsetY, self.toOffsetY)

                if not self.walking then
                    self.offsetY = self.toOffsetY

                    if self.hideWhenDone then
                        self:SetVisible(false)
                    end

                    if self.endSequenceName then
                        self.sequenceName = self.endSequenceName
                        self.sequenceApplied = false
                    end
                end
            end

            if self.sequenceName and not self.sequenceApplied then
                local sequenceId = entity:LookupSequence(self.sequenceName)

                if sequenceId and sequenceId >= 0 then
                    entity:ResetSequence(sequenceId)
                end

                entity:SetCycle(0)
                entity:SetPlaybackRate(1)
                self.sequenceApplied = true
            end

            local walkYaw = 28

            if self.walking then
                if (self.walkDirectionY or 0) < 0 then
                    walkYaw = -40
                elseif (self.walkDirectionY or 0) > 0 then
                    walkYaw = 140
                end
            end

            entity:SetAngles(Angle(0, walkYaw, 0))
            entity:SetPos(Vector(0, self.offsetY or 0, 0))

            if self.RunAnimation then
                self:RunAnimation()
            end
        end
    end

    local function BeginPanelWalk(panel, fromOffsetY, toOffsetY, endSequenceName, hideWhenDone)
        panel.fromOffsetY = fromOffsetY
        panel.toOffsetY = toOffsetY
        panel.offsetY = fromOffsetY
        panel.walkDirectionY = toOffsetY - fromOffsetY
        panel.walkStart = CurTime()
        panel.walkEnd = panel.walkStart + previewWalkDuration
        panel.walking = true
        panel.hideWhenDone = hideWhenDone or false
        panel.sequenceName = "Walk"
        panel.sequenceApplied = false
        panel.endSequenceName = endSequenceName
        panel:SetVisible(true)
    end

    local function ApplySkinToPanel(panel, skin)
        if not IsValid(panel) or not IsValid(panel.Entity) then
            return
        end

        local maxSkin = math.max((panel.Entity:SkinCount() or 1) - 1, 0)
        local safeSkin = math.Clamp(math.floor(tonumber(skin) or 0), 0, maxSkin)
        panel.Entity:SetSkin(safeSkin)
    end

    local function UpdateSkinSliderForPanel(panel, skin)
        if not IsValid(panel) or not IsValid(panel.Entity) then
            skinSlider:SetVisible(false)
            return
        end

        local maxSkin = math.max((panel.Entity:SkinCount() or 1) - 1, 0)
        local safeSkin = math.Clamp(math.floor(tonumber(skin) or 0), 0, maxSkin)

        isUpdatingSkinSlider = true
        skinSlider:SetMin(0)
        skinSlider:SetMax(maxSkin)
        skinSlider:SetDecimals(0)
        skinSlider:SetValue(safeSkin)
        skinSlider:SetVisible(true)
        isUpdatingSkinSlider = false
    end

    local function SetPanelModel(panel, modelPath, skin)
        panel:SetModel(modelPath or "models/error.mdl")
        panel.modelPath = modelPath

        timer.Simple(0, function()
            if not IsValid(panel) then
                return
            end

            ApplySkinToPanel(panel, skin)
            UpdateSkinSliderForPanel(panel, skin)
        end)
    end

    local function TransitionPreviewModel(modelPath, skin)
        if modelPath == activeModelPath then
            ApplySkinToPanel(activePreview, skin)
            UpdateSkinSliderForPanel(activePreview, skin)
            return
        end

        if not activeModelPath then
            SetPanelModel(activePreview, modelPath, skin)
            BeginPanelWalk(activePreview, previewOffset, 0, "Idle1", false)
            activeModelPath = modelPath
            return
        end

        local outgoingPreview = activePreview
        local nextPreview = incomingPreview

        SetPanelModel(nextPreview, modelPath, skin)
        BeginPanelWalk(nextPreview, previewOffset, 0, "Idle1", false)
        BeginPanelWalk(outgoingPreview, 0, -previewOffset, nil, true)

        activePreview = nextPreview
        incomingPreview = outgoingPreview
        activeModelPath = modelPath
    end

    activePreview = Intro.AddControl(vgui.Create("DModelPanel", Intro.panel))
    incomingPreview = Intro.AddControl(vgui.Create("DModelPanel", Intro.panel))

    ConfigurePreviewPanel(activePreview)
    ConfigurePreviewPanel(incomingPreview)

    local firstNameLabel = Intro.AddControl(vgui.Create("DLabel", Intro.panel))
    firstNameLabel:SetPos(formX, nameY)
    firstNameLabel:SetSize(240, 30)
    firstNameLabel:SetText("First Name")
    firstNameLabel:SetFont("TestingIntro_Label")
    firstNameLabel:SetTextColor(Color(230, 230, 230))

    local firstNameCombo = Intro.AddControl(vgui.Create("DComboBox", Intro.panel))
    firstNameCombo:SetPos(formX, nameY + inputOffsetY)
    firstNameCombo:SetSize((fieldW * 0.5) - 8, inputHeight)
    firstNameCombo:SetValue("Select first name")

    for _, firstName in ipairs(Intro.firstNameOptions) do
        firstNameCombo:AddChoice(firstName)
    end

    local lastNameLabel = Intro.AddControl(vgui.Create("DLabel", Intro.panel))
    lastNameLabel:SetPos(formX + (fieldW * 0.5) + 8, nameY)
    lastNameLabel:SetSize(240, 30)
    lastNameLabel:SetText("Last Name")
    lastNameLabel:SetFont("TestingIntro_Label")
    lastNameLabel:SetTextColor(Color(230, 230, 230))

    local lastNameCombo = Intro.AddControl(vgui.Create("DComboBox", Intro.panel))
    lastNameCombo:SetPos(formX + (fieldW * 0.5) + 8, nameY + inputOffsetY)
    lastNameCombo:SetSize((fieldW * 0.5) - 8, inputHeight)
    lastNameCombo:SetValue("Select last name")

    for _, lastName in ipairs(Intro.lastNameOptions) do
        lastNameCombo:AddChoice(lastName)
    end

    local genderLabel = Intro.AddControl(vgui.Create("DLabel", Intro.panel))
    genderLabel:SetPos(formX, genderY)
    genderLabel:SetSize(240, 30)
    genderLabel:SetText("Gender")
    genderLabel:SetFont("TestingIntro_Label")
    genderLabel:SetTextColor(Color(230, 230, 230))

    local genderCombo = Intro.AddControl(vgui.Create("DComboBox", Intro.panel))
    genderCombo:SetPos(formX, genderY + inputOffsetY)
    genderCombo:SetSize(fieldW, inputHeight)
    genderCombo:SetValue("Select gender")
    genderCombo:AddChoice("Male")
    genderCombo:AddChoice("Female")

    local occupationLabel = Intro.AddControl(vgui.Create("DLabel", Intro.panel))
    occupationLabel:SetPos(formX, occupationY)
    occupationLabel:SetSize(240, 30)
    occupationLabel:SetText("Occupation")
    occupationLabel:SetFont("TestingIntro_Label")
    occupationLabel:SetTextColor(Color(230, 230, 230))

    local occupationCombo = Intro.AddControl(vgui.Create("DComboBox", Intro.panel))
    occupationCombo:SetPos(formX, occupationY + inputOffsetY)
    occupationCombo:SetSize(fieldW, inputHeight)
    occupationCombo:SetValue("Select occupation")
    occupationCombo:AddChoice("Scientist")
    occupationCombo:AddChoice("Security")
    occupationCombo:AddChoice("Engineer")

    local skillLabel = Intro.AddControl(vgui.Create("DLabel", Intro.panel))
    skillLabel:SetPos(formX, skillY)
    skillLabel:SetSize(240, 30)
    skillLabel:SetText("Skill")
    skillLabel:SetFont("TestingIntro_Label")
    skillLabel:SetTextColor(Color(230, 230, 230))

    local skillCombo = Intro.AddControl(vgui.Create("DComboBox", Intro.panel))
    skillCombo:SetPos(formX, skillY + inputOffsetY)
    skillCombo:SetSize(fieldW, inputHeight)
    skillCombo:SetValue("Select skill")

    local modelLabel = Intro.AddControl(vgui.Create("DLabel", Intro.panel))
    modelLabel:SetPos(formX, modelY)
    modelLabel:SetSize(240, 30)
    modelLabel:SetText("Model")
    modelLabel:SetFont("TestingIntro_Label")
    modelLabel:SetTextColor(Color(230, 230, 230))

    local modelCombo = Intro.AddControl(vgui.Create("DComboBox", Intro.panel))
    modelCombo:SetPos(formX, modelY + inputOffsetY)
    modelCombo:SetSize(fieldW, inputHeight)
    modelCombo:SetValue("Select model")

    firstNameLabel:SetTall(labelHeight)
    lastNameLabel:SetTall(labelHeight)
    genderLabel:SetTall(labelHeight)
    occupationLabel:SetTall(labelHeight)
    skillLabel:SetTall(labelHeight)
    modelLabel:SetTall(labelHeight)

    local selectedFirstName
    local selectedLastName
    local selectedGender
    local selectedOccupation
    local selectedSkill
    local selectedModel
    local selectedSkin = 0

    local function RebuildModelChoices()
        modelCombo:Clear()
        selectedModel = nil
        selectedSkin = 0
        modelCombo:SetValue("Select model")
        skinSlider:SetVisible(false)

        for _, modelPath in ipairs(Intro.genderModelOptions[selectedGender] or {}) do
            modelCombo:AddChoice(modelPath)
        end
    end

    firstNameCombo.OnSelect = function(_, _, selected)
        Intro.PlayUISound(Intro.BUTTON_CLICK_SOUND)
        selectedFirstName = selected
    end

    lastNameCombo.OnSelect = function(_, _, selected)
        Intro.PlayUISound(Intro.BUTTON_CLICK_SOUND)
        selectedLastName = selected
    end

    genderCombo.OnSelect = function(_, _, selected)
        Intro.PlayUISound(Intro.BUTTON_CLICK_SOUND)
        selectedGender = selected
        RebuildModelChoices()
    end

    occupationCombo.OnSelect = function(_, _, selected)
        Intro.PlayUISound(Intro.BUTTON_CLICK_SOUND)
        Intro.PlayOccupationVoiceLine(selected)
        selectedOccupation = selected
        selectedSkill = nil

        skillCombo:Clear()
        skillCombo:SetValue("Select skill")

        for _, skill in ipairs(Intro.occupationSkills[selected] or {}) do
            skillCombo:AddChoice(skill)
        end
    end

    skillCombo.OnSelect = function(_, _, selected)
        Intro.PlayUISound(Intro.BUTTON_CLICK_SOUND)
        selectedSkill = selected
    end

    modelCombo.OnSelect = function(_, _, selected)
        Intro.PlayUISound(Intro.BUTTON_CLICK_SOUND)
        selectedModel = selected
        selectedSkin = 0
        TransitionPreviewModel(selectedModel, selectedSkin)
    end

    skinSlider.OnValueChanged = function(_, value)
        if isUpdatingSkinSlider then
            return
        end

        local safeValue = math.max(0, math.floor(tonumber(value) or 0))
        selectedSkin = safeValue

        if selectedModel then
            TransitionPreviewModel(selectedModel, selectedSkin)
        end
    end

    Intro.MakeMenuButton("CREATE CHARACTER", 0, function()
        if not selectedFirstName or not selectedLastName then
            notification.AddLegacy("Select both first and last names.", NOTIFY_ERROR, 3)
            return
        end

        if Intro.blockedNamePairs[selectedFirstName] and Intro.blockedNamePairs[selectedFirstName][selectedLastName] then
            notification.AddLegacy("That first and last name combination is not allowed.", NOTIFY_ERROR, 3)
            return
        end

        if not Intro.genderModelOptions[selectedGender] then
            notification.AddLegacy("Select a gender.", NOTIFY_ERROR, 3)
            return
        end

        local hasSelectedModel = false

        for _, modelPath in ipairs(Intro.genderModelOptions[selectedGender]) do
            if modelPath == selectedModel then
                hasSelectedModel = true
                break
            end
        end

        if not hasSelectedModel then
            notification.AddLegacy("Select a valid model.", NOTIFY_ERROR, 3)
            return
        end

        if not Intro.occupationSkills[selectedOccupation] then
            notification.AddLegacy("Select an occupation.", NOTIFY_ERROR, 3)
            return
        end

        local validSkill = false

        for _, skill in ipairs(Intro.occupationSkills[selectedOccupation]) do
            if selectedSkill == skill then
                validSkill = true
                break
            end
        end

        if not validSkill then
            notification.AddLegacy("Select a valid skill.", NOTIFY_ERROR, 3)
            return
        end

        net.Start(Intro.CHARACTER_CREATE_NET)
        net.WriteString(selectedFirstName)
        net.WriteString(selectedLastName)
        net.WriteString(selectedGender)
        net.WriteString(selectedOccupation)
        net.WriteString(selectedSkill)
        net.WriteString(selectedModel)
        net.WriteUInt(math.max(0, math.floor(selectedSkin or 0)), 8)
        net.SendToServer()
    end, {
        x = formX,
        y = buttonsY,
        width = fieldW,
    })

    Intro.MakeMenuButton("BACK", 1, function()
        Intro.StartViewTransition("main", Intro.BuildMainMenu)
    end, {
        x = formX,
        y = buttonsY + 62,
        width = fieldW,
    })
end
