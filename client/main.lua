local blockedTalk = false
local startflare = false
local cooldown = false
local playerPed = cache.ped
local CHEST_DROP = false
local chestZone

local TASK_DURATION = Config.TaskDuration
local WARNING_TIME = Config.WarningTime

local function HasItem()
    local item = exports.ox_inventory:Search('count', Config.RequiredItem)
    
    if not Config.RequiredItemEnabled then return ContextMenu() end

    if item >= Config.RequiredItemQuanity then
        ContextMenu()
    else
        lib.notify({ type = 'error', description = Config.translation.no_required_item })
    end
end

local function spawnFlarePed()
    local modelName = Config.PedModel
    local modelHash = GetHashKey(modelName)

    lib.requestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    flaretalk = CreatePed(5, modelHash, Config.talkped, false, false)
    if flaretalk ~= 0 then
        SetPedDefaultComponentVariation(flaretalk)
        SetEntityInvincible(flaretalk, true)
        SetBlockingOfNonTemporaryEvents(flaretalk, true)
        SetPedFleeAttributes(flaretalk, 0, 0)
        FreezeEntityPosition(flaretalk, true)
        ClearPedTasksImmediately(flaretalk)
        TaskStartScenarioInPlace(flaretalk, Config.AnimationPed, 0, false)
    end

    exports.ox_target:addLocalEntity(flaretalk, {
        {
            name = 'flare-location',
            event = '',
            icon = 'fa-regular fa-comments',
            label = Config.translation.talk,
            distance = 1.2,
            onSelect = function()
                HasItem()
            end
        }
    })
end


RegisterNetEvent('lnd-flare:receivePoliceCount')
AddEventHandler('lnd-flare:receivePoliceCount', function(policeCount)
    local requiredPolice = Config.RequiredPolice

    if policeCount < requiredPolice then
        lib.notify({ type = 'error', description = Config.translation.no_required_police })
        return
    else
        handleFlareTalkSelect()
    end
end)


function handleFlareTalkSelect()
    ESX.TriggerServerCallback('lnd-flare:server:checkCooldown', function(isCooldownActive)

        if startflare then
            lib.notify({
                description = Config.translation.started,
                duration = 5000,
                icon = 'fa-solid fa-xmark',
                iconColor = '#C53030',
                iconAnimation = 'fade',
                alignIcon = 'center'
            })
            return
        end

        if isCooldownActive then
            lib.notify({
                description = Config.translation.cooldownnotif,
                duration = 5000,
                icon = 'fa-solid fa-xmark',
                iconColor = '#C53030',
                iconAnimation = 'fade',
                alignIcon = 'center'
            })
            return
        end

        if blockedTalk then
            lib.notify({
                description = Config.translation.cooldownnotif,
                duration = 5000,
                icon = 'fa-solid fa-xmark',
                iconColor = '#C53030',
                iconAnimation = 'fade',
                alignIcon = 'center'
            })
            return
        end

        lib.notify({
            description = Config.translation.start,
            duration = 5000,
            icon = 'fa-solid fa-check',
            iconColor = '#2ECC71',
            iconAnimation = 'fade',
            alignIcon = 'center'
        })
        TriggerServerEvent('lnd-flare:server:startCountdown')
        TriggerServerEvent('lnd-flare:createchest')
        startTaskTimer()
        startflare = true
    end)
end

function ContextMenu()
    local ped = GetEntityCoords(flaretalk)
    
    ESX.TriggerServerCallback('lnd-flare:server:checkCooldown', function(isCooldownActive)
        lib.registerContext({
            id = 'flare-menu',
            title = Config.translation.menuTitle,
            options = {
                {
                    title = Config.translation.title,
                    description = Config.translation.descStart,
                    icon = 'star',
                    disabled = isCooldownActive,
                    onSelect = function ()
                        TriggerServerEvent('lnd-flare:checkPoliceCount', ped)
                    end
                },
            }
        })
        lib.showContext('flare-menu')
    end)
end

local function FlareEffect(coords)
    local particleEffects = {}
    local dict = "core"
    local particleName = "exp_grd_flare"
    local particleAmount = 1

    lib.requestNamedPtfxAsset(dict)
    for x = 0, particleAmount do
        UseParticleFxAssetNextCall(dict)
        local particle = StartParticleFxLoopedAtCoord(particleName, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        particleEffects[#particleEffects + 1] = particle
        Wait(0)
    end

    function StopEffect()
        for _, v in pairs(particleEffects) do
            StopParticleFxLooped(v, true)
        end
    end
end

local function BlipFlare(coords)
    flareblip1 = AddBlipForRadius(coords.x, coords.y, coords.z, Config.ZoneRadius)
    SetBlipColour(flareblip1, 65)
    SetBlipAlpha(flareblip1, 128)

    flareblip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(flareblip, 842)
    SetBlipColour(flareblip, 65)
    SetBlipScale(flareblip, 0.6)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.translation.blipname)
    EndTextCommandSetBlipName(flareblip)
end

local function removeBlip()
    RemoveBlip(flareblip)
    RemoveBlip(flareblip1)
end

local function playAnimation(playerPed)
    local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
    local animName = "machinic_loop_mechandplayer"

    lib.requestAnimDict(animDict, 100)
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 1.0, false, false, false)
end


function startTaskTimer()
    lib.notify({
        description = Config.translation.starttimer,
        duration = 5000,
        icon = 'fa-solid fa-exclamation',
        iconColor = '#FFA500',
        iconAnimation = 'fade',
        alignIcon = 'center'
    })

    CreateThread(function()
        Wait(WARNING_TIME)
        if startflare then
            lib.notify({
                description = Config.translation.endreminder,
                duration = 5000,
                icon = 'fa-solid fa-exclamation',
                iconColor = '#FFA500',
                iconAnimation = 'fade',
                alignIcon = 'center'
            })
        end
    end)

    CreateThread(function()
        Wait(TASK_DURATION)
        if startflare then
            lib.notify({
                description = Config.translation.timeend,
                duration = 5000,
                icon = 'fa-solid fa-times',
                iconColor = '#C53030',
                iconAnimation = 'fade',
                alignIcon = 'center'
            })
            startflare = false
            removeBlip()
            StopEffect()
            exports.ox_target:removeModel(Config.chestprop, 'flare-chest')
        end
    end)
end

local function openChest()
    local playerPed = cache.ped
    local coords = GetEntityCoords(playerPed)

    if Config.Dispatch then
        Dispatch(playerPed, coords)
    end

    playAnimation(playerPed)

    local success = lib.skillCheck(Config.SkillCheckSettings.Difficulties, Config.SkillCheckSettings.Keys)

    exports.ox_target:removeModel(Config.chestprop, 'flare-chest')

    if not success then
        ClearPedTasks(playerPed)
    else
        lib.progressCircle({duration = 15000,position = 'middle',useWhileDead = false,canCancel = false,disable = { sprint = true, move = true },anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer', flag = 1 }})
        TriggerServerEvent('lnd-flare:networksync', 'drop')
    end
end


RegisterNetEvent('lnd-flare:createchest', function(DROP)
	CHEST_DROP = DROP

    FlareEffect(CHEST_DROP.selected_Zone.FlareCoords)

    chestZone = lib.zones.sphere({
        coords = CHEST_DROP.coords,
        radius = Config.ZoneRadius,
        debug = Config.Debug,

        onEnter = function ()
            CHEST_PROP = CreateObject(Config.chestprop, CHEST_DROP.coords.x,CHEST_DROP.coords.y, CHEST_DROP.coords.z, true)
        
            exports.ox_target:addModel(Config.chestprop, {
                name = 'flare-chest',
                icon = 'fa-solid fa-lock',
                label = Config.translation.open,
                distance = 2.0,
                onSelect = function()
                    openChest()
                end
            })
        end,

        onExit = function ()
            DeleteEntity(CHEST_PROP) 
        end
    })
end)

RegisterNetEvent('lnd-flare:createblip', function(DATA)
    COORDS_DATA = DATA
    BlipFlare(COORDS_DATA.selected_Zone.BlipCoord)
end)

RegisterNetEvent('lnd-flare:networksync', function(action, DROP)

	if action == 'drop' then
        exports.ox_target:removeModel(Config.chestprop, 'flare-chest')
        
        if chestZone then
            chestZone:remove()
            chestZone = nil  
        end

        SetTimeout(Config.CleanTime, function()
            removeBlip()
            StopEffect()
            DeleteEntity(CHEST_PROP)
        end)

	end
	CHEST_DROP = DROP
end)

RegisterNetEvent('lnd-flare:client:blockTalk')
AddEventHandler('lnd-flare:client:blockTalk', function(blocked)
    blockedTalk = blocked
end)


local flarePed = lib.zones.sphere({
    coords = Config.ZonePed.coords,
    radius = Config.ZonePed.radius,
    debug = Config.Debug,
    onEnter = function()
        spawnFlarePed()
    end,
    onExit = function()
        if flaretalk then
            DeleteEntity(flaretalk)
        end
    end
})
