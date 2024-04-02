ESX = nil
ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)


AddEventHandler('onClientResourceStart', function(ressourceName)
    if(GetCurrentResourceName() ~= ressourceName) then
        return
    end 
    print("" ..ressourceName.." start")
    flareped()
end)

---- zielony #2ECC71 czerwony #C53030

local blockedTalk = false
local startflare = false

function flareped() -- PED

    local modelName = "a_m_m_skidrow_01"
    local modelHash = GetHashKey(modelName)
    
    lib.requestModel(modelHash)

    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    flaretalk = CreatePed(5, modelHash, -1517.0228, 1502.7448, 111.6212 - 1.0, 78.2675, false,false)

    if flaretalk ~= 0 then
        SetPedDefaultComponentVariation(flaretalk)
        SetEntityInvincible(flaretalk, true)
        SetBlockingOfNonTemporaryEvents(flaretalk, true)
        SetPedFleeAttributes(flaretalk, 0, 0)
        FreezeEntityPosition(flaretalk, true)


        ClearPedTasksImmediately(flaretalk)
        TaskStartScenarioInPlace(flaretalk, "WORLD_HUMAN_DRINKING", 0, false)
    end
    
    
    exports.ox_target:addLocalEntity(flaretalk, {
        {
            name = 'flare-location',
            event = '',
            icon = 'fa-regular fa-comments',
            label = 'Talk',
            onSelect = function()

                if startflare then
                    lib.notify({
                        description = 'Listen go find this box',
                        duration = 5000,
                        style = {
                            backgroundColor = '#141517',
                            color = '#C1C2C5',
                            ['.description'] = {
                              color = '#909296'
                            }
                        },
                        icon = 'fa-solid fa-xmark',
                        iconColor = '#C53030',
                        iconAnimation = 'fade',
                        alignIcon = 'center'
                    })
                    return
                end

                if cooldown then
                    lib.notify({
                        description = 'Get away from me',
                        duration = 5000,
                        style = {
                            backgroundColor = '#141517',
                            color = '#C1C2C5',
                            ['.description'] = {
                              color = '#909296'
                            }
                        },
                        icon = 'fa-solid fa-xmark',
                        iconColor = '#C53030',
                        iconAnimation = 'fade',
                        alignIcon = 'center'
                    })
                    return
                end


                if not cooldown then
                    lib.notify({
                        description = 'Listen, there is a hidden box and I have not been able to find it, maybe you can find it if you find the contents are yours',
                        duration = 5000,
                        style = {
                            backgroundColor = '#141517',
                            color = '#C1C2C5',
                            ['.description'] = {
                              color = '#909296'
                            }
                        },
                        icon = 'fa-solid fa-check',
                        iconColor = '#2ECC71',
                        iconAnimation = 'fade',
                        alignIcon = 'center'
                    })
                    TriggerServerEvent('lnd-flare:startlog')
                    TriggerServerEvent('lnd-flare:server:startCountdown')
                    TriggerServerEvent('lnd-flare:server:talkavaible')
                    randomZone()
                    chestlocation()
                    cooldown = true
                    startflare = true
                end
            end
        }
    })
end


RegisterNetEvent('lnd-flare:client:blockTalk')
AddEventHandler('lnd-flare:client:blockTalk', function(blocked)
    blockedTalk  = blocked

    if blockedTalk  then
        cooldown  = true
    else
        cooldown = false
    end
end)


function chestlocation() -- RANDOM CHEST LOCATION & INTERACTION

    exports.ox_target:addLocalEntity(chestprop, {

        name = 'flare-chest',
        event = '',
        icon = 'fa-solid fa-lock',
        label = 'Open',
        distance = 1.2,
        onSelect = function()

            local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'easy'}, {'e'})

            if success then
                lib.progressCircle({
                    duration = 15000,
                    position = 'middle',
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        sprint = true,
                        move = true
                    },
                    anim = {
                        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                        clip = 'machinic_loop_mechandplayer',
                        flag = 1
                    },
                })
                lib.notify({
                    description = 'Niicee you open the chest and u got some items',
                    duration = 5000,
                    style = {
                        backgroundColor = '#141517',
                        color = '#C1C2C5',
                        ['.description'] = {
                          color = '#909296'
                        }
                    },
                    icon = 'fa-solid fa-check',
                    iconColor = '#2ECC71',
                    iconAnimation = 'fade',
                    alignIcon = 'center'
                })
                TriggerServerEvent('lnd-flare:drop',receivedToken)
                DeleteObject(chestprop)
                startflare = false
                removeB()
                stopeffect()
            end
        end
    })
end



function flareffect(coords) -- EFFECT FLARE SMOKE

    local particleEffects = {}
    local dict = "core"
    local particleName = "exp_grd_flare"
    local particleAmount = 1

    lib.requestNamedPtfxAsset(dict)

    for x = 0, particleAmount do
        UseParticleFxAssetNextCall(dict)

        local particle = StartParticleFxLoopedAtCoord(particleName, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        particleEffects[#particleEffects+1] = particle
        Wait(0)
    end

    function stopeffect()
        for _, v in pairs(particleEffects) do
        StopParticleFxLooped(v, true)
    end 

    end
end



function blipflare(coords) -- BLIP & RADIUS


    local flareblip1 = AddBlipForRadius(coords.x, coords.y, coords.z, 125.0)
    SetBlipColour(flareblip1, 65)
    SetBlipAlpha(flareblip1, 128)


    local flareblip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(flareblip, 842)
    SetBlipColour(flareblip, 65)
    SetBlipScale(flareblip, 0.6)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Area to search")
    EndTextCommandSetBlipName(flareblip)


    function removeB()
        RemoveBlip(flareblip)
        RemoveBlip(flareblip1)
    end
end



function randomZone()

    local randomNumber = math.random(1, 100)
    local selectedZone = nil

    for _, zone in ipairs(Config.Zones) do
        if randomNumber <= zone.Chance then
            selectedZone = zone
            
            break
        else
            randomNumber = randomNumber - zone.Chance
        end
    end

    if selectedZone then

        local randomIndex = math.random(1, #selectedZone.chests)
        local randomChestCoords = selectedZone.chests[randomIndex]


        blipflare(selectedZone.BlipCoord)
        flareffect(selectedZone.FlareCoords)

        chestprop = CreateObject(Config.chestprop, randomChestCoords.x, randomChestCoords.y, randomChestCoords.z -1.0, true,true,true)
        print("Wybrano strefę: " .. selectedZone.ZoneName .. ". Umieszczam skrzynkę w lokalizacji: " .. randomChestCoords.x .. ", " .. randomChestCoords.y)

    end

end