RegisterServerEvent("asset_portals:get:coords")
AddEventHandler("asset_portals:get:coords", function()
    local enterrecycle = vector3(845.02270507812, -902.81726074219, 25.25133895874)
    local leaverecycle = vector3(997.51324462891, -3091.9892578125, -38.999923706055)
    TriggerClientEvent("asset_portals:recieve:coords", source, enterrecycle, leaverecycle)
end)