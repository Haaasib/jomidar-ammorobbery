local QBCore = exports[Config.CoreName]:GetCoreObject()

local containers = {}
local collisions = {}
local locks = {}
local clientContainer = {}
local clientLock = {}
local rndContainer = nil

function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(1)
    end
end

function loadPtfxAsset(asset)
    RequestNamedPtfxAsset(asset)
    while not HasNamedPtfxAssetLoaded(asset) do
        Wait(1)
    end
end

local function hasItem(item)
    if exports['ox_inventory'] then
        local items = exports.ox_inventory:Search('count', item)
        print('ox_inventory items:', json.encode(items)) -- Debugging output
        local count = items[item] or 0
        return count > 0
    else
        local itemInfo = QBCore.Functions.HasItem(item)
        print('qb-inventory itemInfo:', json.encode(itemInfo)) -- Debugging output
        if type(itemInfo) == "table" then
            return itemInfo.amount and itemInfo.amount > 0
        else
            return itemInfo
        end
    end
end

local function handleContainerOpen(k)
    local result = hasItem(Config.requiredItem)
    print("HasItem result:", result) -- Debugging output
    if result then
        if not Config['containers'][k]['lock']['taken'] then
            OpenContainer(k)
        else
            QBCore.Functions.Notify("Already Open", "error")
        end
    else
        QBCore.Functions.Notify("No Item", "error")
    end
end

local function addTargetEntity(entity, options, distance)
    if exports['qb-target'] then
        exports['qb-target']:AddTargetEntity(entity, {
            options = options,
            distance = distance
        })
    elseif exports['ox_target'] then
        exports['ox_target']:AddTarget({
            entity = entity,
            options = options,
            distance = distance
        })
    else
        print("No target system found.")
    end
end

local function addCircleZone(name, center, radius, options, targetOptions)
    if exports['qb-target'] then
        exports['qb-target']:AddCircleZone(name, center, radius, options, targetOptions)
    elseif exports['ox_target'] then
        exports['ox_target']:AddCircleZone(name, center, radius, {
            options = targetOptions.options,
            distance = targetOptions.distance,
            debug = options.debugPoly,
            useZ = options.useZ
        })
    else
        print("No target system found.")
    end
end

local function removeZone(name)
    if exports['qb-target'] then
        exports['qb-target']:RemoveZone(name)
    elseif exports['ox_target'] then
        exports['ox_target']:RemoveZone(name)
    else
        print("No target system found.")
    end
end

local function removeTargetEntity(entity, label)
    if exports['qb-target'] then
        exports['qb-target']:RemoveTargetEntity(entity, label)
    elseif exports['ox_target'] then
        exports['ox_target']:RemoveTarget(entity)
    else
        print("No target system found.")
    end
end

local function openInventory(stashId)
    if exports['ox_inventory'] then
        exports.ox_inventory:openInventory('stash', stashId)
    else
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', stashId, {
            maxweight = 1000000,
            slots = 10,
        })
        TriggerEvent('inventory:client:SetCurrentStash', stashId)
    end
end

CreateThread(function()
    RequestModel(Config.PedModel)
    while not HasModelLoaded(Config.PedModel) do
        Wait(1)
    end
    startped = CreatePed(2, Config.PedModel, Config.StartPedLoc.x, Config.StartPedLoc.y, Config.StartPedLoc.z-1, Config.StartPedLoc.w, false, false)
    SetPedFleeAttributes(startped, 0, 0)
    SetPedDiesWhenInjured(startped, false)
    TaskStartScenarioInPlace(startped, Config.StartPedAnimation, 0, true)
    SetPedKeepTask(startped, true)
    SetBlockingOfNonTemporaryEvents(startped, true)
    SetEntityInvincible(startped, true)
    FreezeEntityPosition(startped, true)

    Wait(100)

    addTargetEntity(startped, {
        { 
            type = "client",
            event = "jomidar-ammorobbery:cl:start",
            icon = "fas fa-user-secret",
            label = "Ammo Rob",
        },
    }, 2.0)
end)

RegisterNetEvent('jomidar-ammorobbery:cl:clear')
AddEventHandler('jomidar-ammorobbery:cl:clear', function()
    for i = 1, #Config['containers'] do
        DeleteEntity(containers[i])
        DeleteEntity(locks[i])
        DeleteEntity(collisions[i])
        removeZone("opencontainers"..i)
        Config['containers'][i]['lock']['taken'] = false
        DeleteEntity(clientContainer[i])
        DeleteEntity(clientLock[i])
    end
    removeTargetEntity(weaponBox, 'Open Crate')
    DeleteEntity(weaponBox)
    print("limpou")
end)

RegisterNetEvent('jomidar-ammorobbery:cl:start')
AddEventHandler('jomidar-ammorobbery:cl:start', function()
    QBCore.Functions.TriggerCallback('jomidar-ammorobbery:sv:GetCops', function(cops)
        QBCore.Functions.TriggerCallback("jomidar-ammorobbery:sv:coolc",function(isCooldown)
            if not isCooldown then
                if cops >= Config.CopAmount then
                    TriggerServerEvent("jomidar-ammorobbery:sv:coolout")
                    TriggerServerEvent("jomidar-ammorobbery:sv:ClearSync")
                    ClearArea(Config['containers'][1].pos)
                    SetupContainers()
                else
                    QBCore.Functions.Notify("No Cops", "error")
                end
            else
                QBCore.Functions.Notify("In Cooldown", "error")
            end
        end)
    end)
end)

function SetupContainers()
    containersBlip = AddBlipForCoord(1088.02, -3193.23, 5.9)
    SetBlipSprite(containersBlip, 677)
    SetBlipColour(containersBlip, 1)
    SetBlipScale(containersBlip, 0.7)
    SetBlipRoute(containersBlip, true)
    SetBlipRouteColour(containersBlip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Containers')
    EndTextCommandSetBlipName(containersBlip)

    loadModel('prop_ld_container')
    rndContainer = math.random(1, #Config['containers'])

    print(rndContainer)
    if rndContainer == 1 then
        exports['jomidar-ui']:Show('Ammunation Containers', 'Rob the container S8B5')
    elseif rndContainer == 2 then
        exports['jomidar-ui']:Show('Ammunation Containers', 'Rob the container 8E7T')
    elseif rndContainer == 3 then
        exports['jomidar-ui']:Show('Ammunation Containers', 'Rob the container S92H')
    elseif rndContainer == 4 then
        exports['jomidar-ui']:Show('Ammunation Containers', 'Rob the container 9C0B')
    elseif rndContainer == 5 then
        exports['jomidar-ui']:Show('Ammunation Containers', 'Rob the container B09W')
    else
        exports['jomidar-ui']:Show('Ammunation Containers', 'Rob the container 0B06')
    end

    for k, v in pairs(Config['containers']) do
        loadModel(Config['containers'][k].containerModel)
        Wait(100)
        containers[k] = CreateObject(GetHashKey(Config['containers'][k].containerModel), v.pos, 1, 1, 0)
        SetEntityHeading(containers[k], v.heading)
        FreezeEntityPosition(containers[k], true)
        Wait(math.random(100, 500))
        collisions[k] = CreateObject(GetHashKey('prop_ld_container'), v.pos, 1, 1, 0)
        SetEntityHeading(collisions[k], v.heading)
        SetEntityVisible(collisions[k], false)
        FreezeEntityPosition(collisions[k], true)
        Wait(math.random(100, 500))
        locks[k] = CreateObject(GetHashKey('tr_prop_tr_lock_01a'), v.lock.pos, 1, 1, 0)
        SetEntityHeading(locks[k], v.heading)
        FreezeEntityPosition(locks[k], true)

        addCircleZone("opencontainers"..k, v.target, 1.0, {
            name = "opencontainers"..k,
            useZ = true,
            debugPoly = false
        }, {
            options = {
                {
                    event = "jomidar-ammorobbery:handleContainerOpen",
                    icon = "fas fa-user-secret",
                    label = "Open Container",
                    args = k
                },
            },
            job = {"all"},
            distance = 1.5,
        })
    end

    weaponBox = CreateObject(GetHashKey("ex_prop_crate_ammo_sc"), vector3(Config['containers'][rndContainer].box.x, Config['containers'][rndContainer].box.y, Config['containers'][rndContainer].box.z), 1, 1, 0)
    SetEntityHeading(weaponBox, Config['containers'][rndContainer].box.w)
    FreezeEntityPosition(weaponBox, true)
    TriggerServerEvent("jomidar-ammorobbery:sv:synctarget")
end

function OpenContainer(index)
    QBCore.Functions.Progressbar("opencontainer", "Opening the container...", 11500, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
    end)
    AlertCops()
    local ped = PlayerPedId()
    local pedCo = GetEntityCoords(ped)
    local pedRotation = GetEntityRotation(ped)
    local animDict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
    loadAnimDict(animDict)
    loadPtfxAsset('scr_tn_tr')
    TriggerServerEvent('jomidar-ammorobbery:sv:lockSync', index)

    for i = 1, #ContainerAnimation['objects'] do
        loadModel(ContainerAnimation['objects'][i])
        ContainerAnimation['sceneObjects'][i] = CreateObject(GetHashKey(ContainerAnimation['objects'][i]), pedCo, 1, 1, 0)
    end

    sceneObject = GetClosestObjectOfType(pedCo, 2.5, GetHashKey(Config['containers'][index].containerModel), 0, 0, 0)
    lockObject = GetClosestObjectOfType(pedCo, 2.5, GetHashKey('tr_prop_tr_lock_01a'), 0, 0, 0)
    NetworkRegisterEntityAsNetworked(sceneObject)
    NetworkRegisterEntityAsNetworked(lockObject)

    scene = NetworkCreateSynchronisedScene(GetEntityCoords(sceneObject), GetEntityRotation(sceneObject), 2, true, false, 1065353216, 0, 1065353216)

    NetworkAddPedToSynchronisedScene(ped, scene, animDict, ContainerAnimation['animations'][1][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(sceneObject, scene, animDict, ContainerAnimation['animations'][1][2], 1.0, -1.0, 1148846080)
    NetworkAddEntityToSynchronisedScene(lockObject, scene, animDict, ContainerAnimation['animations'][1][3], 1.0, -1.0, 1148846080)
    NetworkAddEntityToSynchronisedScene(ContainerAnimation['sceneObjects'][1], scene, animDict, ContainerAnimation['animations'][1][4], 1.0, -1.0, 1148846080)
    NetworkAddEntityToSynchronisedScene(ContainerAnimation['sceneObjects'][2], scene, animDict, ContainerAnimation['animations'][1][5], 1.0, -1.0, 1148846080)

    SetEntityCoords(ped, GetEntityCoords(sceneObject))
    NetworkStartSynchronisedScene(scene)
    Wait(4000)
    UseParticleFxAssetNextCall('scr_tn_tr')
    sparks = StartParticleFxLoopedOnEntity("scr_tn_tr_angle_grinder_sparks", ContainerAnimation['sceneObjects'][1], 0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false, 1065353216, 1065353216, 1065353216, 1)
    Wait(1000)
    StopParticleFxLooped(sparks, 1)
    Wait(GetAnimDuration(animDict, 'action') * 1000 - 5000)
    TriggerServerEvent('jomidar-ammorobbery:sv:containerSync', GetEntityCoords(sceneObject), GetEntityRotation(sceneObject), index)
    TriggerServerEvent('jomidar-ammorobbery:sv:objectSync', NetworkGetNetworkIdFromEntity(sceneObject))
    TriggerServerEvent('jomidar-ammorobbery:sv:objectSync', NetworkGetNetworkIdFromEntity(lockObject))
    DeleteObject(ContainerAnimation['sceneObjects'][1])
    DeleteObject(ContainerAnimation['sceneObjects'][2])
    ClearPedTasks(ped)
    if rndContainer == index then
        SpawnGuards()
        exports['jomidar-ui']:Close()
        RemoveBlip(containersBlip)
    end
end

local guardPeds = {}

function SpawnGuards()
    for _, guard in ipairs(Config.GuardPeds) do
        local model = GetHashKey(guard.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end

        local guardPed = CreatePed(4, model, guard.coords.x, guard.coords.y, guard.coords.z, guard.heading, true, true)

        GiveWeaponToPed(guardPed, GetHashKey("WEAPON_ASSAULTRIFLE"), 250, false, true)
        SetPedCombatAttributes(guardPed, 46, true)
        SetPedFleeAttributes(guardPed, 0, false)
        SetPedCombatAbility(guardPed, 2)
        SetPedCombatRange(guardPed, 2)
        SetPedCombatMovement(guardPed, 2)
        SetPedRelationshipGroupHash(guardPed, GetHashKey("HATES_PLAYER"))
        TaskCombatPed(guardPed, PlayerPedId(), 0, 16)

        local blip = AddBlipForEntity(guardPed)
        SetBlipAsFriendly(blip, false)

        table.insert(guardPeds, { ped = guardPed, blip = blip })
    end
end

Citizen.CreateThread(function()
    AddRelationshipGroup("GUARDS")
    AddRelationshipGroup("PLAYER")

    SetRelationshipBetweenGroups(5, GetHashKey("GUARDS"), GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("GUARDS"))
end)

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        for i, guard in ipairs(guardPeds) do
            if IsPedDeadOrDying(guard.ped, true) then
                RemoveBlip(guard.blip)
                table.remove(guardPeds, i)
            end
        end
    end
end)

RegisterNetEvent('jomidar-ammorobbery:cl:containerSync')
AddEventHandler('jomidar-ammorobbery:cl:containerSync', function(coords, rotation, index)
    animDict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
    loadAnimDict(animDict)

    clientContainer[index] = CreateObject(GetHashKey(Config['containers'][index].containerModel), coords, 0, 0, 0)
    clientLock[index] = CreateObject(GetHashKey('tr_prop_tr_lock_01a'), coords, 0, 0, 0)

    clientScene = CreateSynchronizedScene(coords, rotation, 2, true, false, 1065353216, 0, 1065353216)
    PlaySynchronizedEntityAnim(clientContainer[index], clientScene, ContainerAnimation['animations'][1][2], animDict, 1.0, -1.0, 0, 1148846080)
    ForceEntityAiAndAnimationUpdate(clientContainer[index])
    PlaySynchronizedEntityAnim(clientLock[index], clientScene, ContainerAnimation['animations'][1][3], animDict, 1.0, -1.0, 0, 1148846080)
    ForceEntityAiAndAnimationUpdate(clientLock[index])

    SetSynchronizedScenePhase(clientScene, 0.99)
    SetEntityCollision(clientContainer[index], false, true)
    FreezeEntityPosition(clientContainer[index], true)
end)

RegisterNetEvent('jomidar-ammorobbery:cl:lockSync')
AddEventHandler('jomidar-ammorobbery:cl:lockSync', function(index)
    Config['containers'][index]['lock']['taken'] = true
end)

RegisterNetEvent('jomidar-ammorobbery:cl:objectSync')
AddEventHandler('jomidar-ammorobbery:cl:objectSync', function(e)
    local entity = NetworkGetEntityFromNetworkId(e)
    DeleteEntity(entity)
    DeleteObject(entity)
end)

RegisterNetEvent('jomidar-ammorobbery:cl:targetsync')
AddEventHandler('jomidar-ammorobbery:cl:targetsync', function()
    addTargetEntity(weaponBox, {
        { 
            icon = "fas fa-user-secret",
            label = "Open Crate",
            action = function()
                openCrate()
            end,
        },
    }, 1.4)
end)

function getRandomItem(items)
    local itemIndex = math.random(1, #items)
    return items[itemIndex]
end

-- Open crate function
function openCrate()
    exports['skillchecks']:startUntangleGame(50000, 5, function(success)
        if success then
            if Config.UseStash then 
                openInventory("WeaponCrate")
            else
                QBCore.Functions.Progressbar("opencontainer", "Opening the crate...", 7000, false, false, {
                    disableMovement = true,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function()
                    local item = getRandomItem(Config.WithoutStashItem)
                    TriggerServerEvent('Jommidar-ammorobbery:AddItem', item.name, item.amount)
                    removeTargetEntity(weaponBox)
                end)
            end
        else
            QBCore.Functions.Notify("You Failed, Try again!", "error")
        end
    end)
end

function checkStash()
    if Config.UseStash then
        print("if you get stash issue then make Config.UseStash = true to Config.UseStash = false")
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        checkStash()
    end
end)

AddEventHandler('onResourceStop', function (resource)
    if resource == GetCurrentResourceName() then
        for i = 1, #Config['containers'] do
            DeleteEntity(containers[i])
            DeleteEntity(locks[i])
            DeleteEntity(collisions[i])
            removeZone("opencontainers"..i)
            Config['containers'][i]['lock']['taken'] = false
            DeleteEntity(clientContainer[i])
            DeleteEntity(clientLock[i])
        end
        removeTargetEntity(weaponBox, 'Open Crate')
        DeleteEntity(weaponBox)
        exports['jomidar-ui']:Close()
    end
end)

RegisterNetEvent('jomidar-ammorobbery:handleContainerOpen')
AddEventHandler('jomidar-ammorobbery:handleContainerOpen', function(k)
    handleContainerOpen(k)
end)
