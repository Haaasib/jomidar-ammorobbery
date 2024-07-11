local QBCore = exports[Config.CoreName]:GetCoreObject()


-- cool down for job
RegisterServerEvent('jomidar-ammorobbery:sv:coolout', function()
    Cooldown = true
    local timer = Config.Cooldown * 60000
    while timer > 0 do
        Wait(1000)
        timer = timer - 1000
        if timer == 0 then
            Cooldown = false
            TriggerClientEvent("jomidar-ammorobbery:cl:clear", -1)
        end
    end
end)

QBCore.Functions.CreateCallback("jomidar-ammorobbery:sv:coolc",function(source, cb)
    if Cooldown then
        cb(true)
    else
        cb(false) 
    end
end)

QBCore.Functions.CreateCallback('jomidar-ammorobbery:sv:GetCops', function(source, cb)
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if (v.PlayerData.job.type == Config.PoliceJobtype) and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    cb(amount)
end)


RegisterServerEvent('jomidar-ammorobbery:sv:containerSync')
AddEventHandler('jomidar-ammorobbery:sv:containerSync', function(coords, rotation, index)
    TriggerClientEvent('jomidar-ammorobbery:cl:containerSync', -1, coords, rotation, index)
end)

RegisterServerEvent('jomidar-ammorobbery:sv:lockSync')
AddEventHandler('jomidar-ammorobbery:sv:lockSync', function(index)
    TriggerClientEvent('jomidar-ammorobbery:cl:lockSync', -1, index)
end)

RegisterServerEvent('jomidar-ammorobbery:sv:objectSync')
AddEventHandler('jomidar-ammorobbery:sv:objectSync', function(e)
    TriggerClientEvent('jomidar-ammorobbery:cl:objectSync', -1, e)
end)

RegisterServerEvent('jomidar-ammorobbery:sv:synctarget')
AddEventHandler('jomidar-ammorobbery:sv:synctarget', function()
    TriggerClientEvent('jomidar-ammorobbery:cl:targetsync', -1)
    local index = math.random(1, #Config.Items)
    local stashName = "WeaponCrate"
    local newItems = Config.Items[index]
    AddItemsToStash(stashName, newItems)
end)

RegisterServerEvent('jomidar-ammorobbery:sv:ClearSync')
AddEventHandler('jomidar-ammorobbery:sv:ClearSync', function()
    TriggerClientEvent("jomidar-ammorobbery:cl:clear", -1)
end)

-- Function to add multiple items to the stash in the corresponding row of the database table
function AddItemsToStash(stashName, newItems)
    -- Convert the list of new items into a JSON string
    local newItemsJSON = json.encode(newItems)

    -- SQL query to update the 'items' column in the row with the name 'WeaponCrate'
    local query = "UPDATE stashitems SET items = JSON_MERGE_PATCH(items, '" .. newItemsJSON .. "') WHERE stash = '" .. stashName .. "'"

    -- Execute the query asynchronously
    MySQL.Async.execute(query, {}, function(rowsChanged)
        if rowsChanged > 0 then
            print("Items added to stash successfully!")
        else
            print("Failed to add items to stash.")
        end
    end)
end




