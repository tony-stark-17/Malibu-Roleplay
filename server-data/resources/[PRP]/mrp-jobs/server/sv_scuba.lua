RegisterServerEvent('mrp-scuba:checkAndTakeDepo')
AddEventHandler('mrp-scuba:checkAndTakeDepo', function()
local src = source
local user = exports["mrp-core"]:getModule("Player"):GetUser(src)
    user:removeMoney(400)
end)

RegisterServerEvent('mrp-scuba:returnDepo')
AddEventHandler('mrp-scuba:returnDepo', function()
local src = source
local user = exports["mrp-core"]:getModule("Player"):GetUser(src)
    user:addMoney(200)
end)

RegisterServerEvent('mrp-scuba:findTreasure')
AddEventHandler('mrp-scuba:findTreasure', function()
local source = source
    local roll = math.random(1,8)
    if roll == 1 then
        TriggerClientEvent('player:receiveItem', source, "ironbar", math.random(6,9))
    end
    if roll == 2 then
        TriggerClientEvent('player:receiveItem', source, 'ironbar', math.random(6,11))
    end
    if roll == 3 then
        TriggerClientEvent('player:receiveItem', source, 'ironbar', math.random(6,9))
    end
    if roll == 5 then
        TriggerClientEvent('player:receiveItem', source, "ironbar", math.random(6,11))
    end
    if roll == 6 then
        TriggerClientEvent('player:receiveItem', source, "ironbar", math.random(5,7))
    end
    if roll == 7 then
        TriggerClientEvent('player:receiveItem', source, "umetal", math.random(2,3))
    end
    if roll == 8 then
        TriggerClientEvent('player:receiveItem', source, "umetal", math.random(2,3))
    end
end)

RegisterServerEvent('mrp-scuba:paySalvage')
AddEventHandler('mrp-scuba:paySalvage', function(money)
    local src = source
    local user = exports["mrp-core"]:getModule("Player"):GetUser(src)
    if money ~= nil then
        user:addMoney(tonumber(money))
    end
end)

RegisterServerEvent('mrp-scuba:makeGold')
AddEventHandler('mrp-scuba:makeGold', function()
 local source = source
 TriggerClientEvent('inventory:removeItem', source, 'umetal', 10)
 TriggerClientEvent("player:receiveItem", source, "goldbar", 1)
end)