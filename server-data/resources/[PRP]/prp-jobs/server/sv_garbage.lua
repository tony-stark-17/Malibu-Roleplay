local DISCORD_WEBHOOK6 = "https://discord.com/api/webhooks/870497096497766421/IICMK3wG7CIB_hdJb8T2n6fMqLZfKRmtGh0EG2saQs6j-1pGzGsZc4tF9X5FlLJivQ8K"
local DISCORD_NAME6 = "Garbage Triggers"

local STEAM_KEY = "0C007CC382AB06D1D99D9B45EC3924B1"
local DISCORD_IMAGE = "https://i.imgur.com/zviw6oW.png" -- default is FiveM logo

PerformHttpRequest(DISCORD_WEBHOOK6, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME6, avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })


RegisterNetEvent('prp-garbage:pay')
AddEventHandler('prp-garbage:pay', function(jobStatus)
    local _source = source
    local user = exports["prp-core"]:getModule("Player"):GetUser(_source)
    local identity = GetPlayerIdentifiers(_source)
    if jobStatus then
        if user ~= nil then
            local randomMoney = math.random(500,600)
            user:addMoney(randomMoney)
            sendToDiscord6("Garbage Logs", GetPlayerName(_source) .. ' Has Received $'.. randomMoney .. " \n\nSteam ID : **" .. identity[1] .. "** \n\nLicense : **" .. identity[2] .. "**\n\nDiscord ID : **" .. identity[3] .. "**", 255)
        end
    else
        print("Probably a cheater")
    end
end)


RegisterNetEvent('prp-garbage:reward')
AddEventHandler('prp-garbage:reward', function(rewardStatus)
    print("in server side")
    local _source = source
    local matherino = math.random(0, 6)
    if rewardStatus then
        if matherino == 2 then
            TriggerClientEvent('player:receiveItem', _source, 'plastic', math.random(3,5))
            TriggerClientEvent('player:receiveItem', _source, 'rubber', math.random(3,5))
        end
        if math.random(9) == 1 then
            TriggerClientEvent("player:receiveItem", _source, "cocaineleaf", 1)
        end
    else
        print("Probably a cheater") 
    end
end)

function sendToDiscord6(name, message, color)
    local connect = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message,
          }
      }
    PerformHttpRequest(DISCORD_WEBHOOK6, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME6, embeds = connect, avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })
end
