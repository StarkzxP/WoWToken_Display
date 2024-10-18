local addonName = ...

WoWTokenDisplay_DB = {
    isShown = false,
    minimap = {
        hide = false
    }
}

local tokenPriceFrame = CreateFrame("Frame", "ExpandedFrame", UIParent, "BackdropTemplate")
tokenPriceFrame:SetSize(76, 24)
tokenPriceFrame:SetFrameStrata("MEDIUM")
tokenPriceFrame:SetFrameLevel(0)
tokenPriceFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 5,
        right = 5,
        top = 5,
        bottom = 5
    }
})

local tokePriceText = tokenPriceFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal") -- 199426
tokePriceText:SetPoint("CENTER", tokenPriceFrame, "CENTER")

local fadeInAnimGroup = tokenPriceFrame:CreateAnimationGroup()
local fadeInAnim = fadeInAnimGroup:CreateAnimation("Alpha")
fadeInAnim:SetDuration(0.2)
fadeInAnim:SetFromAlpha(0)
fadeInAnim:SetToAlpha(1)

local fadeOutAnimGroup = tokenPriceFrame:CreateAnimationGroup()
local fadeOutAnim = fadeOutAnimGroup:CreateAnimation("Alpha")
fadeOutAnim:SetDuration(0.2)
fadeOutAnim:SetFromAlpha(1)
fadeOutAnim:SetToAlpha(0)

local function showTokenPriceFrame()
    tokenPriceFrame:Show()
    if WoWTokenDisplay_DB.isShown == false then
        fadeInAnimGroup:Play()
    end
end

local function hideTokenPriceFrame()
    fadeOutAnimGroup:Play()
    fadeOutAnimGroup:SetScript("OnFinished", function()
        tokenPriceFrame:Hide()
    end)
end

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("WoWTokenDisplay", {
    type = "data source",
    text = "WoWTokenDisplay",
    icon = "Interface\\AddOns\\WoWToken_Display\\Media\\Icon",
    OnClick = function(self, button)
        -- print("Shown:", WoWTokenDisplay_DB.isShown)
        -- for clave, valor in pairs(WoWTokenDisplay_DB.minimap) do
        --     print("Minimap Position:", clave, valor)
        -- end
        if button == "LeftButton" then
            if WoWTokenDisplay_DB.isShown then
                WoWTokenDisplay_DB.isShown = false
            else
                WoWTokenDisplay_DB.isShown = true
            end
        end
    end,
    OnEnter = function(self)
        showTokenPriceFrame()
    end,
    OnLeave = function(self)
        if WoWTokenDisplay_DB.isShown == false then
            hideTokenPriceFrame()
        end
    end
})

local function UpdatePrice()
    local currentPrice = C_WowTokenPublic.GetCurrentMarketPrice()
    if currentPrice ~= nil then
        local currentPriceFormatted = GetMoneyString(currentPrice)
        -- LDB.OnTooltipShow = function(tooltip)
        --     tooltip:SetText(currentPriceFormatted)
        -- end
        tokePriceText:SetText(currentPriceFormatted)
    end
end

local function UpdatePriceReschedule()
    C_WowTokenPublic.UpdateMarketPrice()
    C_Timer.After(2, UpdatePrice)
    C_Timer.After(58, UpdatePriceReschedule)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and addonName == ... then
        -- print(addonName .. " ha sido cargado")
        if WoWTokenDisplay_DB.isShown then
            showTokenPriceFrame()
        else
            hideTokenPriceFrame()
        end

        local LibDBIcon = LibStub("LibDBIcon-1.0")
        LibDBIcon:Register("WoWTokenDisplayLDB", LDB, WoWTokenDisplay_DB.minimap)

        local wowTokenButton = LibDBIcon:GetMinimapButton("WoWTokenDisplayLDB")
        tokenPriceFrame:SetPoint("RIGHT", wowTokenButton, "LEFT", 3, 0)

        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        UpdatePriceReschedule()
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)
