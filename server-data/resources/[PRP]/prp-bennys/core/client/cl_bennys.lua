--[[
cl_bennys.lua
Functionality that handles the player for Benny's.
Handles applying mods, etc.
]]

--#[Global Variables]#--
isPlyInBennys = false

--#[Local Variables]#--
local plyFirstJoin = false


-- local nearDefault = false

local nearTuner = false
local nearHayes = false
local nearAutoExotics = false
local nearHarmony = false

local bennyLocationTuner = vector3(938.37, -970.82, 39.76)
local harmonyautos = vector3(-31.566396713257, -1065.1439208984, 27.535711288452)
local AutoExoticsPlace = vector3(546.57568359375, -189.33773803711, 54.493179321289)
local hayesautos = vector3(450.27642822266, -975.96057128906, 25.379083633423)

local civrepairbennys = vector3(-211.6117401123, -1323.6309814453, 30.479585647583) -- Repair shop for civs in bennys

 

local bennyHeading = 319.73135375977

local originalCategory = nil
local originalMod = nil
local originalPrimaryColour = nil
local originalSecondaryColour = nil
local originalPearlescentColour = nil
local originalWheelColour = nil
local originalDashColour = nil
local originalInterColour = nil
local originalWindowTint = nil
local originalWheelCategory = nil
local originalWheel = nil
local originalWheelType = nil
local originalCustomWheels = nil
local originalNeonLightState = nil
local originalNeonLightSide = nil
local originalNeonColourR = nil
local originalNeonColourG = nil
local originalNeonColourB = nil
local originalXenonColour = nil
local originalOldLivery = nil
local originalPlateIndex = nil

local attemptingPurchase = false
local isPurchaseSuccessful = false

--#[Local Functions]#--
local function isNear(pos1, pos2, distMustBe)
    local diff = pos2 - pos1
	local dist = (diff.x * diff.x) + (diff.y * diff.y)

	return (dist < (distMustBe * distMustBe))
end

local function saveVehicle()
    local plyPed = PlayerPedId()
    local veh = GetVehiclePedIsIn(plyPed, false)
    local vehicleMods = {
        neon = {},
        colors = {},
        extracolors = {},
        dashColour = -1,
        interColour = -1,
        lights = {},
        tint = GetVehicleWindowTint(veh),
        wheeltype = GetVehicleWheelType(veh),
        platestyle = GetVehicleNumberPlateTextIndex(veh),
        mods = {},
        smokecolor = {},
        xenonColor = -1,
        oldLiveries = 24,
        extras = {},
        plateIndex = 0,
    }

    vehicleMods.xenonColor = GetCurrentXenonColour(veh)
    vehicleMods.lights[1], vehicleMods.lights[2], vehicleMods.lights[3] = GetVehicleNeonLightsColour(veh)
    vehicleMods.colors[1], vehicleMods.colors[2] = GetVehicleColours(veh)
    vehicleMods.extracolors[1], vehicleMods.extracolors[2] = GetVehicleExtraColours(veh)
    vehicleMods.smokecolor[1], vehicleMods.smokecolor[2], vehicleMods.smokecolor[3] = GetVehicleTyreSmokeColor(veh)
    vehicleMods.dashColour = GetVehicleInteriorColour(veh)
    vehicleMods.interColour = GetVehicleDashboardColour(veh)
    vehicleMods.oldLiveries = GetVehicleLivery(veh)
    vehicleMods.plateIndex = GetVehicleNumberPlateTextIndex(veh)

    for i = 0, 3 do
        vehicleMods.neon[i] = IsVehicleNeonLightEnabled(veh, i)
    end

    for i = 0,16 do
        vehicleMods.mods[i] = GetVehicleMod(veh,i)
    end

    for i = 17, 22 do
        vehicleMods.mods[i] = IsToggleModOn(veh, i)
    end

    for i = 23, 48 do
        vehicleMods.mods[i] = GetVehicleMod(veh,i)
    end

    for i = 1, 12 do
        local ison = IsVehicleExtraTurnedOn(veh, i)
        if 1 == tonumber(ison) then
            vehicleMods.extras[i] = 1
        else
            vehicleMods.extras[i] = 0
        end
    end
    TriggerServerEvent('updateVehicle',vehicleMods,GetVehicleNumberPlateText(veh))  
end

--#[Global Functions]#--
function AttemptPurchase(type, upgradeLevel)
    local cheap = false

    if nearTuner or nearAutoExotics or nearHayes or nearHarmony then
        cheap = true
    end

    if upgradeLevel ~= nil then
        upgradeLevel = upgradeLevel + 2
    end
    TriggerServerEvent("prp-bennys:attemptPurchase",cheap, type, upgradeLevel)

    attemptingPurchase = true

    while attemptingPurchase do
        Citizen.Wait(1)
    end

    if not isPurchaseSuccessful then
        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    end

    return isPurchaseSuccessful
end

function RepairVehicle()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    SetVehicleFixed(plyVeh)
    SetVehicleDirtLevel(plyVeh, 0.0)
    SetVehiclePetrolTankHealth(plyVeh, 4000.0)
    TriggerEvent('veh.randomDegredation',10,plyVeh,3)
end

function GetCurrentMod(id)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local mod = GetVehicleMod(plyVeh, id)
    local modName = GetLabelText(GetModTextLabel(plyVeh, id, mod))

    return mod, modName
end

function GetCurrentWheel()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local wheel = GetVehicleMod(plyVeh, 23)
    local wheelName = GetLabelText(GetModTextLabel(plyVeh, 23, wheel))
    local wheelType = GetVehicleWheelType(plyVeh)

    return wheel, wheelName, wheelType
end

function GetCurrentCustomWheelState()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local state = GetVehicleModVariation(plyVeh, 23)

    if state then
        return 1
    else
        return 0
    end
end

function GetOriginalWheel()
    return originalWheel
end

function GetOriginalCustomWheel()
    return originalCustomWheels
end

function GetCurrentWindowTint()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    return GetVehicleWindowTint(plyVeh)
end

function GetCurrentVehicleWheelSmokeColour()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local r, g, b = GetVehicleTyreSmokeColor(plyVeh)

    return r, g, b
end

function GetCurrentNeonState(id)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local isEnabled = IsVehicleNeonLightEnabled(plyVeh, id)

    if isEnabled then
        return 1
    else
        return 0
    end
end

function GetCurrentNeonColour()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local r, g, b = GetVehicleNeonLightsColour(plyVeh)

    return r, g, b
end

function GetCurrentXenonState()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local isEnabled = IsToggleModOn(plyVeh, 22)

    if isEnabled then
        return 1
    else
        return 0
    end
end

function GetCurrentXenonColour()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    return GetVehicleHeadlightsColour(plyVeh)
end

function GetCurrentTurboState()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local isEnabled = IsToggleModOn(plyVeh, 18)

    if isEnabled then
        return 1
    else
        return 0
    end
end

function GetCurrentExtraState(extra)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    return IsVehicleExtraTurnedOn(plyVeh, extra)
end

function CheckValidMods(category, id, wheelType)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local tempMod = GetVehicleMod(plyVeh, id)
    local tempWheel = GetVehicleMod(plyVeh, 23)
    local tempWheelType = GetVehicleWheelType(plyVeh)
    local tempWheelCustom = GetVehicleModVariation(plyVeh, 23)
    local validMods = {}
    local amountValidMods = 0
    local hornNames = {}

    if wheelType ~= nil then
        SetVehicleWheelType(plyVeh, wheelType)
    end

    if id == 14 then
        for k, v in pairs(vehicleCustomisation) do 
            if vehicleCustomisation[k].category == category then
                hornNames = vehicleCustomisation[k].hornNames

                break
            end
        end
    end

    local modAmount = GetNumVehicleMods(plyVeh, id)
    for i = 1, modAmount do
        local label = GetModTextLabel(plyVeh, id, (i - 1))
        local modName = GetLabelText(label)

        if modName == "NULL" then
            if id == 14 then
                if i <= #hornNames then
                    modName = hornNames[i].name
                else
                    modName = "Horn " .. i
                end
            else
                modName = category .. " " .. i
            end
        end

        validMods[i] = 
        {
            id = (i - 1),
            name = modName
        }

        amountValidMods = amountValidMods + 1
    end

    if modAmount > 0 then
        table.insert(validMods, 1, {
            id = -1,
            name = "Stock " .. category
        })
    end

    if wheelType ~= nil then
        SetVehicleWheelType(plyVeh, tempWheelType)
        SetVehicleMod(plyVeh, 23, tempWheel, tempWheelCustom)
    end

    return validMods, amountValidMods
end

function RestoreOriginalMod()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    SetVehicleMod(plyVeh, originalCategory, originalMod)
    SetVehicleDoorsShut(plyVeh, true)

    originalCategory = nil
    originalMod = nil
end

function RestoreOriginalWindowTint()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    SetVehicleWindowTint(plyVeh, originalWindowTint)

    originalWindowTint = nil
end

function RestoreOriginalColours()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    SetVehicleColours(plyVeh, originalPrimaryColour, originalSecondaryColour)
    SetVehicleExtraColours(plyVeh, originalPearlescentColour, originalWheelColour)
    SetVehicleDashboardColour(plyVeh, originalDashColour)
    SetVehicleInteriorColour(plyVeh, originalInterColour)

    originalPrimaryColour = nil
    originalSecondaryColour = nil
    originalPearlescentColour = nil
    originalWheelColour = nil
    originalDashColour = nil
    originalInterColour = nil
end

function RestoreOriginalWheels()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local doesHaveCustomWheels = GetVehicleModVariation(plyVeh, 23)

    SetVehicleWheelType(plyVeh, originalWheelType)

    if originalWheelCategory ~= nil then
        SetVehicleMod(plyVeh, originalWheelCategory, originalWheel, originalCustomWheels)
        
        if GetVehicleClass(plyVeh) == 8 then --Motorcycle
            SetVehicleMod(plyVeh, 24, originalWheel, originalCustomWheels)
        end

        originalWheelType = nil
        originalWheelCategory = nil
        originalWheel = nil
        originalCustomWheels = nil
    end
end

function RestoreOriginalNeonStates()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    SetVehicleNeonLightEnabled(plyVeh, originalNeonLightSide, originalNeonLightState)

    originalNeonLightState = nil
    originalNeonLightSide = nil
end

function RestoreOriginalNeonColours()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    SetVehicleNeonLightsColour(plyVeh, originalNeonColourR, originalNeonColourG, originalNeonColourB)

    originalNeonColourR = nil
    originalNeonColourG = nil
    originalNeonColourB = nil
end

function RestoreOriginalXenonColour()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    SetVehicleHeadlightsColour(plyVeh, originalXenonColour)
    SetVehicleLights(plyVeh, 0)

    originalXenonColour = nil
end

function RestoreOldLivery()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    SetVehicleLivery(plyVeh, originalOldLivery)
end

function RestorePlateIndex()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    SetVehicleNumberPlateTextIndex(plyVeh, originalPlateIndex)
end

function PreviewMod(categoryID, modID)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    if originalMod == nil and originalCategory == nil then
        originalCategory = categoryID
        originalMod = GetVehicleMod(plyVeh, categoryID)
    end

    if categoryID == 39 or categoryID == 40 or categoryID == 41 then
        SetVehicleDoorOpen(plyVeh, 4, false, true)
    elseif categoryID == 37 or categoryID == 38 then
        SetVehicleDoorOpen(plyVeh, 5, false, true)
    end

    SetVehicleMod(plyVeh, categoryID, modID)
end

function PreviewWindowTint(windowTintID)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    if originalWindowTint == nil then
        originalWindowTint = GetVehicleWindowTint(plyVeh)
    end

    SetVehicleWindowTint(plyVeh, windowTintID)
end

function PreviewColour(paintType, paintCategory, paintID)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    SetVehicleModKit(plyVeh, 0)
    if originalDashColour == nil and originalInterColour == nil and originalPrimaryColour == nil and originalSecondaryColour == nil and originalPearlescentColour == nil and originalWheelColour == nil then
        originalPrimaryColour, originalSecondaryColour = GetVehicleColours(plyVeh)
        originalPearlescentColour, originalWheelColour = GetVehicleExtraColours(plyVeh)
        originalDashColour = GetVehicleDashboardColour(plyVeh)
        originalInterColour = GetVehicleInteriorColour(plyVeh)
    end
    if paintType == 0 then --Primary Colour
        if paintCategory == 1 then --Metallic Paint
            SetVehicleColours(plyVeh, paintID, originalSecondaryColour)
            SetVehicleExtraColours(plyVeh, originalPearlescentColour, originalWheelColour)
        else
            SetVehicleColours(plyVeh, paintID, originalSecondaryColour)
        end
    elseif paintType == 1 then --Secondary Colour
        SetVehicleColours(plyVeh, originalPrimaryColour, paintID)
    elseif paintType == 2 then --Pearlescent Colour
        SetVehicleExtraColours(plyVeh, paintID, originalWheelColour)
    elseif paintType == 3 then --Wheel Colour
        SetVehicleExtraColours(plyVeh, originalPearlescentColour, paintID)
    elseif paintType == 4 then --Dash Colour
        SetVehicleDashboardColour(plyVeh, paintID)
    elseif paintType == 5 then --Interior Colour
        SetVehicleInteriorColour(plyVeh, paintID)
    end
end

function PreviewWheel(categoryID, wheelID, wheelType)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local doesHaveCustomWheels = GetVehicleModVariation(plyVeh, 23)

    if originalWheelCategory == nil and originalWheel == nil and originalWheelType == nil and originalCustomWheels == nil then
        originalWheelCategory = categoryID
        originalWheelType = GetVehicleWheelType(plyVeh)
        originalWheel = GetVehicleMod(plyVeh, 23)
        originalCustomWheels = GetVehicleModVariation(plyVeh, 23)
    end

    SetVehicleWheelType(plyVeh, wheelType)
    SetVehicleMod(plyVeh, categoryID, wheelID, doesHaveCustomWheels)

    if GetVehicleClass(plyVeh) == 8 then --Motorcycle
        SetVehicleMod(plyVeh, 24, wheelID, doesHaveCustomWheels)
    end
end

function PreviewNeon(side, enabled)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    if originalNeonLightState == nil and originalNeonLightSide == nil then
        if IsVehicleNeonLightEnabled(plyVeh, side) then
            originalNeonLightState = 1
        else
            originalNeonLightState = 0
        end

        originalNeonLightSide = side
    end

    SetVehicleNeonLightEnabled(plyVeh, side, enabled)
end

function PreviewNeonColour(r, g, b)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    if originalNeonColourR == nil and originalNeonColourG == nil and originalNeonColourB == nil then
        originalNeonColourR, originalNeonColourG, originalNeonColourB = GetVehicleNeonLightsColour(plyVeh)
    end

    SetVehicleNeonLightsColour(plyVeh, r, g, b)
end

function PreviewXenonColour(colour)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    if originalXenonColour == nil then
        originalXenonColour = GetVehicleHeadlightsColour(plyVeh)
    end

    SetVehicleLights(plyVeh, 2)
    SetVehicleHeadlightsColour(plyVeh, colour)
end

function PreviewOldLivery(liv)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    if originalOldLivery == nil then
        originalOldLivery = GetVehicleLivery(plyVeh)
    end

    SetVehicleLivery(plyVeh, tonumber(liv))
end

function PreviewPlateIndex(index)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    if originalPlateIndex == nil then
        originalPlateIndex = GetVehicleNumberPlateTextIndex(plyVeh)
    end

    SetVehicleNumberPlateTextIndex(plyVeh, tonumber(index))
end

function ApplyMod(categoryID, modID)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    if categoryID == 18 then
        ToggleVehicleMod(plyVeh, categoryID, modID)
    elseif categoryID == 11 or categoryID == 12 or categoryID== 13 or categoryID == 15 or categoryID == 16 then --Performance Upgrades
        originalCategory = categoryID
        originalMod = modID

        SetVehicleMod(plyVeh, categoryID, modID)
    else
        originalCategory = categoryID
        originalMod = modID

        SetVehicleMod(plyVeh, categoryID, modID)
    end
end

function ApplyExtra(extraID)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local isEnabled = IsVehicleExtraTurnedOn(plyVeh, extraID)
    if isEnabled == 1 then
        SetVehicleExtra(plyVeh, tonumber(extraID), 1)
        SetVehiclePetrolTankHealth(plyVeh,4000.0)
    else
        SetVehicleExtra(plyVeh, tonumber(extraID), 0)
        SetVehiclePetrolTankHealth(plyVeh,4000.0)
    end
end

function ApplyWindowTint(windowTintID)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    originalWindowTint = windowTintID

    SetVehicleWindowTint(plyVeh, windowTintID)
end

function ApplyColour(paintType, paintCategory, paintID)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local vehPrimaryColour, vehSecondaryColour = GetVehicleColours(plyVeh)
    local vehPearlescentColour, vehWheelColour = GetVehicleExtraColours(plyVeh)

    if paintType == 0 then --Primary Colour
        if paintCategory == 1 then --Metallic Paint
            SetVehicleColours(plyVeh, paintID, vehSecondaryColour)
            -- SetVehicleExtraColours(plyVeh, paintID, vehWheelColour)
            SetVehicleExtraColours(plyVeh, originalPearlescentColour, vehWheelColour)
            originalPrimaryColour = paintID
            -- originalPearlescentColour = paintID
        else
            SetVehicleColours(plyVeh, paintID, vehSecondaryColour)
            originalPrimaryColour = paintID
        end
    elseif paintType == 1 then --Secondary Colour
        SetVehicleColours(plyVeh, vehPrimaryColour, paintID)
        originalSecondaryColour = paintID
    elseif paintType == 2 then --Pearlescent Colour
        SetVehicleExtraColours(plyVeh, paintID, vehWheelColour)
        originalPearlescentColour = paintID
    elseif paintType == 3 then --Wheel Colour
        SetVehicleExtraColours(plyVeh, vehPearlescentColour, paintID)
        originalWheelColour = paintID
    elseif paintType == 4 then --Dash Colour
        SetVehicleDashboardColour(plyVeh, paintID)
        originalDashColour = paintID
    elseif paintType == 5 then --Interior Colour
        SetVehicleInteriorColour(plyVeh, paintID)
        originalInterColour = paintID
    end
end

function ApplyWheel(categoryID, wheelID, wheelType)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local doesHaveCustomWheels = GetVehicleModVariation(plyVeh, 23)

    originalWheelCategory = categoryID
    originalWheel = wheelID
    originalWheelType = wheelType

    SetVehicleWheelType(plyVeh, wheelType)
    SetVehicleMod(plyVeh, categoryID, wheelID, doesHaveCustomWheels)
    
    if GetVehicleClass(plyVeh) == 8 then --Motorcycle
        SetVehicleMod(plyVeh, 24, wheelID, doesHaveCustomWheels)
    end
end

function ApplyCustomWheel(state)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    SetVehicleMod(plyVeh, 23, GetVehicleMod(plyVeh, 23), state)
    
    if GetVehicleClass(plyVeh) == 8 then --Motorcycle
        SetVehicleMod(plyVeh, 24, GetVehicleMod(plyVeh, 24), state)
    end
end

function ApplyNeon(side, enabled)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    originalNeonLightState = enabled
    originalNeonLightSide = side

    SetVehicleNeonLightEnabled(plyVeh, side, enabled)
end

function ApplyNeonColour(r, g, b)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    originalNeonColourR = r
    originalNeonColourG = g
    originalNeonColourB = b

    SetVehicleNeonLightsColour(plyVeh, r, g, b)
end

function ApplyXenonLights(category, state)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    ToggleVehicleMod(plyVeh, category, state)
end

function ApplyXenonColour(colour)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    originalXenonColour = colour

    SetVehicleHeadlightsColour(plyVeh, colour)
end

function ApplyOldLivery(liv)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    originalOldLivery = liv

    SetVehicleLivery(plyVeh, liv)
end

function ApplyPlateIndex(index)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    originalPlateIndex = index
    SetVehicleNumberPlateTextIndex(plyVeh, index)
end

function ApplyTyreSmoke(r, g, b)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    ToggleVehicleMod(plyVeh, 20, true)
    SetVehicleTyreSmokeColor(plyVeh, r, g, b)
end

function ExitBennys()
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)

    saveVehicle()

    DisplayMenuContainer(false)

    FreezeEntityPosition(plyVeh, false)
    SetEntityCollision(plyVeh, true, true)

    SetTimeout(100, function()
        DestroyMenus()
    end)

    isPlyInBennys = false
end





RegisterNetEvent('event:control:bennys')
AddEventHandler('event:control:bennys', function(useID)
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        bennyHeading = 319.73135375977
        if useID == 1 and not isPlyInBennys and exports["prp_manager"]:isPed("myJob") == "harmony_autos" then -- Bennys
            bennyHeading = 342.16030883789
            enterLocation(harmonyautos)
        elseif useID == 2 and not isPlyInBennys and exports["prp_manager"]:isPed("myJob") == "tuner_shop" then
            bennyHeading = 265.4372253418
            enterLocation(bennyLocationTuner)
        elseif useID == 3 and not isPlyInBennys and exports["prp_manager"]:isPed("myJob") == "police" then
            bennyHeading = 89.437484741211
            enterLocation(hayesautos)
        elseif useID == 4 and not isPlyInBennys and exports["prp_manager"]:isPed("myJob") == "auto_exotics" then
            bennyHeading = 91.957901000977
            enterLocation(AutoExoticsPlace)
        end
    end
end)

function enterLocation(locationsPos)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    local isMotorcycle = false

    SetVehicleModKit(plyVeh, 0)
    SetEntityCoords(plyVeh, locationsPos)
    SetEntityHeading(plyVeh, bennyHeading)
    FreezeEntityPosition(plyVeh, true)
    SetEntityCollision(plyVeh, false, true)

    if GetVehicleClass(plyVeh) == 8 then --Motorcycle
        isMotorcycle = true
    else
        isMotorcycle = false
    end

    InitiateMenus(isMotorcycle, GetVehicleBodyHealth(plyVeh))

    SetTimeout(100, function()
        if GetVehicleBodyHealth(plyVeh) < 1000.0 then
            DisplayMenu(true, "repairMenu")
        else
            DisplayMenu(true, "mainMenu")
        end
        
        DisplayMenuContainer(true)
        PlaySoundFrontend(-1, "OK", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    end)

    isPlyInBennys = true
end


function disableControls()
    DisableControlAction(1, 38, true) --Key: E
    DisableControlAction(1, 172, true) --Key: Up Arrow
    DisableControlAction(1, 173, true) --Key: Down Arrow
    DisableControlAction(1, 177, true) --Key: Backspace
    DisableControlAction(1, 176, true) --Key: Enter
    DisableControlAction(1, 71, true) --Key: W (veh_accelerate)
    DisableControlAction(1, 72, true) --Key: S (veh_brake)
    DisableControlAction(1, 34, true) --Key: A
    DisableControlAction(1, 35, true) --Key: D
    DisableControlAction(1, 75, true) --Key: F (veh_exit)

    if IsDisabledControlJustReleased(1, 172) then --Key: Arrow Up
        MenuScrollFunctionality("up")
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    end

    if IsDisabledControlJustReleased(1, 173) then --Key: Arrow Down
        MenuScrollFunctionality("down")
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    end

    if IsDisabledControlJustReleased(1, 176) then --Key: Enter
        MenuManager(true)
        PlaySoundFrontend(-1, "OK", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    end

    if IsDisabledControlJustReleased(1, 177) then --Key: Backspace
        MenuManager(false)
        PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    end
end

-- #MarkedForMarker
--#[Citizen Threads]#--
Citizen.CreateThread(function()
    while true do 
        local plyPed = PlayerPedId()

        if IsPedInAnyVehicle(plyPed, false) then
            local plyPos = GetEntityCoords(plyPed)
            nearTuner = isNear(plyPos, bennyLocationTuner, 5) 
            nearHayes = isNear(plyPos, hayesautos, 5)
            nearHarmony = isNear(plyPos, harmonyautos, 5)
            nearAutoExotics = isNear(plyPos, AutoExoticsPlace, 5)
            if nearTuner or nearHarmony or nearHayes or nearAutoExotics then
                local job = exports["prp_manager"]:isPed("myJob")
 
                -- Harmony Auto
                if nearHarmony and job == "harmony_autos" then
                    if not isPlyInBennys then
                        Draw3DText(harmonyautos.x, harmonyautos.y, harmonyautos.z + 0.5, "[Press ~p~E~w~ - Enter Bennys]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55)
                        if IsControlJustReleased(1, 38) then
                            TriggerEvent('event:control:bennys', 1)
                        end
                    else
                        disableControls()
                    end
                end


                -- Auto Exotics
                if nearAutoExotics and job == "auto_exotics" then
                    if not isPlyInBennys then
                        Draw3DText(AutoExoticsPlace.x, AutoExoticsPlace.y, AutoExoticsPlace.z + 0.5, "[Press ~p~E~w~ - Enter Auto Exotic's]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55)
                        if IsControlJustReleased(1, 38) then
                            TriggerEvent('event:control:bennys', 4)
                        end
                    else
                        disableControls()
                    end
                end


                -- GMS
                if nearTuner and job == "tuner_shop" then
                    if not isPlyInBennys then
                        Draw3DText(bennyLocationTuner.x, bennyLocationTuner.y, bennyLocationTuner.z + 0.5, "[Press ~p~E~w~ - Enter Goat Motor Service]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55)
                        if IsControlJustReleased(1, 38) then
                            TriggerEvent('event:control:bennys', 2)
                        end
                    else
                       disableControls()
                    end
                end

                -- Auto Bodies
                if nearHayes and job == "police" then
                    if not isPlyInBennys then
                        Draw3DText(hayesautos.x, hayesautos.y, hayesautos.z + 0.5, "[Press ~p~E~w~ - Enter Police Vehicle Garage]", 255, 255, 255, 255, 4, 0.45, true, true, true, true, 0, 0, 0, 0, 55)
                        if IsControlJustReleased(1, 38) then
                            TriggerEvent('event:control:bennys', 3)
                        end
                    else
                       disableControls()
                    end
                end

            else
                Wait(1000)
            end
        else
            Wait(2000)
        end

        Citizen.Wait(1)
    end
end)

--#[Event Handlers]#--
RegisterNetEvent("prp-bennys:purchaseSuccessful")
AddEventHandler("prp-bennys:purchaseSuccessful", function()
    isPurchaseSuccessful = true
    attemptingPurchase = false
end)

RegisterNetEvent("prp-bennys:purchaseFailed")
AddEventHandler("prp-bennys:purchaseFailed", function()
    isPurchaseSuccessful = false
    attemptingPurchase = false
end)


local NearCiv = false

Citizen.CreateThread(function()
    exports["prp-polyzone"]:AddBoxZone("Civ_repair", vector3(-211.6117401123, -1323.6309814453, 30.479585647583), 6.8, 10, {
        name="Civ_repair",
        heading=160,
        debugPoly=false,
        minZ=27.4,
        maxZ=31.4
    }) 

    exports["prp-polyzone"]:AddBoxZone("arcade_repair", vector3(714.36, -790.48, 16.47), 13.8, 4, {
        name="arcade_repair",
        heading=270,
        minZ=14.07,
        maxZ=18.07
    }) 

end)

RegisterNetEvent('prp-polyzone:enter')
AddEventHandler('prp-polyzone:enter', function(name)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if name == "Civ_repair" then
        if vehicle ~= 0 then
            NearCiv = true
            CivRepairFunction()
            TriggerEvent('prp-textui:ShowUI', 'show', ("[E] %s"):format("Repair ($350)"))
        end
    end

    if name == "arcade_repair" then
        if vehicle ~= 0 then
            NearCiv = true
            arcadeRepairFunction()
            TriggerEvent('prp-textui:ShowUI', 'show', ("[E] %s"):format("Repair ($150)"))
        end
    end
end)

RegisterNetEvent('prp-polyzone:exit')
AddEventHandler('prp-polyzone:exit', function(name)
    if name == "Civ_repair" then
        NearCiv = false
    end
    if name == "arcade_repair" then
        NearCiv = false
    end
    TriggerEvent('prp-textui:HideUI')
end)

function CivRepairFunction()
	Citizen.CreateThread(function()
        while NearCiv do
            Citizen.Wait(5)
            local car = GetVehiclePedIsIn(PlayerPedId(), false)
            if IsControlJustReleased(0, 38) then
                if car ~= 0 then
                    TriggerServerEvent("prp-bennys:repairciv", 350)
                end
            end
        end
    end)
end

function arcadeRepairFunction()
	Citizen.CreateThread(function()
        while NearCiv do
            Citizen.Wait(5)
            local car = GetVehiclePedIsIn(PlayerPedId(), false)
            if IsControlJustReleased(0, 38) then
                if car ~= 0 then
                    TriggerServerEvent("prp-bennys:repairciv", 150)
                end
            end
        end
    end)
end

RegisterNetEvent("bennys:civ:repair:cl", function()
    local car = GetVehiclePedIsIn(PlayerPedId(), false)
    if car ~= 0 then
        FreezeEntityPosition(car, true)
        local finished = exports["prp-taskbar"]:taskBar(math.random(15000, 20000),"Repairing Vehicle")
        if finished == 100 then
            SetVehicleFixed(car)
            SetVehicleDirtLevel(car, 0)
            SetVehicleDeformationFixed(car)
            SetVehicleUndriveable(car, false)
            FreezeEntityPosition(car, false)
        else
            FreezeEntityPosition(car, false)
        end
    end
end)