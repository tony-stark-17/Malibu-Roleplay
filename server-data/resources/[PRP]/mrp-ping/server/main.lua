RegisterServerEvent("mrp-ping:attempt", function(pCoords, pFinderId)
	local pSrc = source
	local user = exports["mrp-core"]:getModule("Player"):GetUser(pSrc)
	local char = user:getCurrentCharacter()
    local name = char.first_name .. " " .. char.last_name
	if pFinderId ~= nil then
        if pFinderId:lower() == 'accept' then
            TriggerClientEvent('mrp-ping:client:AcceptPing', pSrc)
        elseif pFinderId:lower() == 'reject' then
            TriggerClientEvent('mrp-ping:client:RejectPing', pSrc)
        else
            local tSrc = tonumber(pFinderId)
            if pSrc ~= tSrc then
                TriggerClientEvent('mrp-ping:client:SendPing', tSrc, name, pSrc, pCoords)
            else
                TriggerClientEvent('DoLongHudText', pSrc, 'Can\'t Ping Yourself', 1)
            end
        end
    end
end)

RegisterServerEvent('mrp-ping:server:SendPingResult')
AddEventHandler('mrp-ping:server:SendPingResult', function(id, result)
	local user = exports["mrp-core"]:getModule("Player"):GetUser(source)
	local char = user:getCurrentCharacter()
    local name = char.first_name .. " " .. char.last_name
	if result == 'accept' then
		TriggerClientEvent('DoLongHudText', id, name .. " Accepted Your Ping", 1)
	elseif result == 'reject' then
		TriggerClientEvent('DoLongHudText', id, name .. " Rejected Your Ping", 1)
	elseif result == 'timeout' then
		TriggerClientEvent('DoLongHudText', id, name .. " Did Not Accept Your Ping", 1)
	elseif result == 'unable' then
		TriggerClientEvent('DoLongHudText', id, name .. " Was Unable To Receive Your Ping", 1)
	elseif result == 'received' then
		TriggerClientEvent('DoLongHudText', id, 'You Sent A Ping To ' .. name .. '.', 1)
	end
end)
