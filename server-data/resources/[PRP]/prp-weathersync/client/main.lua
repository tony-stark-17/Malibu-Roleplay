CurrentWeather = 'EXTRASUNNY'
local lastWeather = CurrentWeather
local baseTime = 0
local timeOffset = 0
local timer = 0
local freezeTime = false
local blackout = false

local disable = false


--- CODE
RegisterNetEvent('mrp-weathersync:spawned')
AddEventHandler('mrp-weathersync:spawned', function()
	disable = false
    TriggerServerEvent('mrp-weathersync:server:RequestStateSync')
end)

RegisterNetEvent('mrp-weathersync:client:EnableSync')
AddEventHandler('mrp-weathersync:client:EnableSync', function()
	disable = false
    TriggerServerEvent('mrp-weathersync:server:RequestStateSync')
	SetRainLevel(0.0)
end)

RegisterNetEvent('mrp-weathersync:client:DisableSync')
AddEventHandler('mrp-weathersync:client:DisableSync', function()
	disable = true

	Citizen.CreateThread(function() 
		while disable do
			SetRainLevel(0.0)
			SetWeatherTypePersist('EXTRASUNNY')
			SetWeatherTypeNow('EXTRASUNNY')
			SetWeatherTypeNowPersist('EXTRASUNNY')
			NetworkOverrideClockTime(23, 0, 0)
			Citizen.Wait(5000)
		end
	end)
end)

RegisterNetEvent('mrp-weathersync:client:SyncTime')
AddEventHandler('mrp-weathersync:client:SyncTime', function(base, offset, freeze)
    freezeTime = freeze
    timeOffset = offset
    baseTime = base
end)

RegisterNetEvent('mrp-weathersync:client:SyncWeather')
AddEventHandler('mrp-weathersync:client:SyncWeather', function(NewWeather, newblackout)
    CurrentWeather = NewWeather
    blackout = newblackout
end)

Citizen.CreateThread(function()
    local hour = 0
    local minute = 0
    while true do
		if not disable then
			local newBaseTime = baseTime
			if GetGameTimer() - 500  > timer then
				newBaseTime = newBaseTime + 0.25
				timer = GetGameTimer()
			end
			if freezeTime then
				timeOffset = timeOffset + baseTime - newBaseTime			
			end
			baseTime = newBaseTime
			hour = math.floor(((baseTime+timeOffset)/60)%24)
			minute = math.floor((baseTime+timeOffset)%60)
			NetworkOverrideClockTime(hour, minute, 0)

			Citizen.Wait(2000)
		else
			Citizen.Wait(1000)
		end
    end
end)

Citizen.CreateThread(function()
    while true do
		if not disable then
			if lastWeather ~= CurrentWeather then
				lastWeather = CurrentWeather
				SetWeatherTypeOverTime(CurrentWeather, 15.0)
				Citizen.Wait(15000)
			end
			Citizen.Wait(100) -- Wait 0 seconds to prevent crashing.
			SetBlackout(blackout)
			ClearOverrideWeather()
			ClearWeatherTypePersist()
			SetWeatherTypePersist(lastWeather)
			SetWeatherTypeNow(lastWeather)
			SetWeatherTypeNowPersist(lastWeather)
			if lastWeather == 'XMAS' then
				SetForceVehicleTrails(true)
				SetForcePedFootstepsTracks(true)
			else
				SetForceVehicleTrails(false)
				SetForcePedFootstepsTracks(false)
			end
		else
			Citizen.Wait(1000)
		end
    end
end)

