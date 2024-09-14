local blockedTalk = false
local startflare = false
local cooldown = false
local playerPed = cache.ped

local TASK_DURATION = Config.TaskDuration
local WARNING_TIME = Config.WarningTime

local function spawnFlarePed()
    local modelName = Config.PedModel
    local modelHash = GetHashKey(modelName)

    lib.requestModel(modelHash)

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
                ContextMenu()
            end
        }
    })
end

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
        startflare = true
        randomZone()
        startTaskTimer()
    end)
end

function ContextMenu()
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
                        handleFlareTalkSelect()
                    end
                },
            }
        })
        lib.showContext('flare-menu')
    end)
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
            removeB()
            stopeffect()
            exports.ox_target:removeEntity(chestprop, 'flare-chest')
        end
    end)
end

function flareffect(coords)
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

    function stopeffect()
        for _, v in pairs(particleEffects) do
            StopParticleFxLooped(v, true)
        end
    end
end

function blipflare(coords)
    local flareblip1 = AddBlipForRadius(coords.x, coords.y, coords.z, 125.0)
    SetBlipColour(flareblip1, 65)
    SetBlipAlpha(flareblip1, 128)

    local flareblip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(flareblip, 842)
    SetBlipColour(flareblip, 65)
    SetBlipScale(flareblip, 0.6)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.translation.blipname)
    EndTextCommandSetBlipName(flareblip)

    function removeB()
        RemoveBlip(flareblip)
        RemoveBlip(flareblip1)
    end
end


local function playAnimation()
    local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
    local animName = "machinic_loop_mechandplayer"

    lib.requestAnimDict(animDict, 100)
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 1.0, false, false, false)
end

function randomZone()
    selectedZone = Config.Zones[math.random(#Config.Zones)]

    if selectedZone then
        local randomIndex = math.random(1, #selectedZone.chests)
        local randomChestCoords = selectedZone.chests[randomIndex]

        blipflare(selectedZone.BlipCoord)
        flareffect(selectedZone.FlareCoords)


        chestprop = CreateObjectNoOffset(Config.chestprop, randomChestCoords.x, randomChestCoords.y, randomChestCoords.z - 1.0, true, true, false)

        exports.ox_target:addLocalEntity(chestprop, {
            name = 'flare-chest',
            icon = 'fa-solid fa-lock',
            label = Config.translation.open,
            distance = 10,
            onSelect = function()
                playAnimation()
                local success = lib.skillCheck(Config.SkillCheckSettings.Difficulties, Config.SkillCheckSettings.Keys)
                if not success then
                    ClearPedTasks(playerPed)
                else
                    lib.progressCircle({
                        duration = 15000,
                        position = 'middle',
                        useWhileDead = false,
                        canCancel = false,
                        disable = { sprint = true, move = true },
                        anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer', flag = 1 }
                    })
                    propCoords = GetEntityCoords(chestprop)
                    TriggerServerEvent('lnd-flare:drop', propCoords)
                    DeleteObject(chestprop)
                    startflare = false
                    removeB()
                    stopeffect()
                end
            end
        })
    end
end

RegisterNetEvent('lnd-flare:client:blockTalk')
AddEventHandler('lnd-flare:client:blockTalk', function(blocked)
    blockedTalk = blocked
end)


local flarePed = lib.zones.sphere({
    coords = Config.ZonePed.coords,
    radius = Config.ZonePed.radius,
    debug = Config.ZonePed.debug,
    onEnter = function()
        spawnFlarePed()
    end,
    onExit = function()
        if flaretalk then
            DeleteEntity(flaretalk)
        end
    end
})
