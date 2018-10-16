--  SimpleCast Addon (by Marko)
--

local _, SimpleCast = ...
local SURVEY_SPELL_ID = 80451
local SURVEY_BUTTON
local FISHING_SPELL_ID = 131474
local FISH_BUTTON
local FISHING_POLE_ITEM_TYPE_NAME = "Fishing Poles"
local clear_override = nil
local override_on = nil

SimpleCast = LibStub("AceAddon-3.0"):NewAddon(
    SimpleCast, "SimpleCast", "AceConsole-3.0",
    "AceEvent-3.0"
)

function SimpleCast:OnInitialize()
    SimpleCast:RegisterEvent("PLAYER_REGEN_ENABLED")
    SimpleCast:RegisterChatCommand('sc', 'ParseCommand')
    SimpleCast:RegisterChatCommand('simplecast', 'ParseCommand')
    SimpleCast:RegisterChatCommand('rl', 'ReloadUI') -- elvui provides this, but I load only this addon while developing and its nice to have

    do
        local surveyButtonName =  "SC_EasySurveyButton"
        SURVEY_BUTTON = createButton(surveyButtonName, SURVEY_SPELL_ID)

        local fishButtonName =  "SC_EasyFishButton"
        FISH_BUTTON = createButton(fishButtonName, FISHING_SPELL_ID)

        local DOUBLECLICK_MAX_SECONDS = 0.2
        local DOUBLECLICK_MIN_SECONDS = 0.04

        local previousClickTime

        _G.WorldFrame:HookScript("OnMouseDown", function(frame, button, down)

            if button == "RightButton" and not IsTaintable() then 

                -- Ensure the LootFrame contains no items; we don't care if it's simply visible.
                if _G.GetNumLootItems() == 0 and previousClickTime then
                    local doubleClickTime = _G.GetTime() - previousClickTime

                    if doubleClickTime < DOUBLECLICK_MAX_SECONDS and doubleClickTime > DOUBLECLICK_MIN_SECONDS then
                        previousClickTime = nil

                        -- printToChat('DOUBLE CLICK!')

                        if _G.IsEquippedItemType(FISHING_POLE_ITEM_TYPE_NAME) then
                            _G.SetOverrideBindingClick(FISH_BUTTON, true, "BUTTON2", fishButtonName)
                            override_on = true
                        else 
                            if _G.CanScanResearchSite() and _G.GetSpellCooldown(SURVEY_SPELL_ID) == 0 then
                                _G.SetOverrideBindingClick(SURVEY_BUTTON, true, "BUTTON2", surveyButtonName)
                                override_on = true
                            end
                        end
                    end
                end

                previousClickTime = _G.GetTime()
            end
        end)
    end
end

function SimpleCast:OnDisable()
end

function SimpleCast:ReloadUI()
    ReloadUI()
end

function SimpleCast:ParseCommand(args)
    local command, commandArg1 = self:GetArgs(args, 2)
    if not command then
        SimpleCast:PrintUsage()
    else 
        if command == "" then
        end 
    end
end

function SimpleCast:PrintUsage()
    SimpleCast:Print("USAGE:")
end

function SimpleCast:PLAYER_REGEN_ENABLED()
    if clear_override then
        _G.ClearOverrideBindings(SURVEY_BUTTON)
        _G.ClearOverrideBindings(FISH_BUTTON)
        override_on = nil
        clear_override = nil
    end 
end

function printToChat(msg)
  DEFAULT_CHAT_FRAME:AddMessage(GREEN_FONT_COLOR_CODE.."SC: |r"..tostring(msg))
end 

function IsTaintable()
    return (_G.InCombatLockdown() or (_G.UnitAffectingCombat("player") or _G.UnitAffectingCombat("pet")))
end

function createButton(buttonName, spellID)
    local aButton = _G.CreateFrame("Button", buttonName, _G.UIParent, "SecureActionButtonTemplate")
    aButton:SetPoint("TOP", _G.UIParent, "RIGHT", 0, 400)
    aButton:SetFrameStrata("LOW")
    aButton:EnableMouse(true)
    aButton:RegisterForClicks("RightButtonDown")
    aButton:SetAttribute("type", "spell")
    aButton:SetAttribute("spell", spellID)
    aButton:SetAttribute("action", nil)

    aButton:SetScript("PostClick", function(self, mouse_button, is_down)
        if override_on and not IsTaintable() then
            _G.ClearOverrideBindings(self)
            override_on = nil
        else
            clear_override = true
        end
    end)

    return aButton
end 