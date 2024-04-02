ESX = nil
ESX = exports["es_extended"]:getSharedObject()

local function generateNewToken()
    return math.random(100000, 999999)
end

local serverToken = generateNewToken()



RegisterNetEvent('lnd-flare:startlog')
AddEventHandler('lnd-flare:startlog', function ()
    local src = source
    local currentTime = os.date("%Y-%m-%d %H:%M:%S")
    local discord = nil

    local identifiers = GetNumPlayerIdentifiers(src)
    for i = 0, identifiers - 1 do
        local identifier = GetPlayerIdentifier(src, i)
        if identifier ~= nil and string.match(identifier, "discord") then
            discord = string.sub(identifier, 9)
            break
        end
    end

    twitterWood("START FLARE LOG \n" .."PLAYER: " .. GetPlayerName(src).."\n" .. "DISCORD ID: " .. discord .."\n".. "DATE: " .. currentTime)
end)



local dropTable = {
    {
        groupName = "Group1", -- Nazwa grupy / GroupName
        totalChance = 50,
        items = { -- Przedmioty w grupie / Items in Group
            "water",
            "lockpick"
        }
    },
    {
        groupName = "Group2",
        totalChance = 50,
        items = {
            "wood",
            "stone"
        }
    }
}


RegisterNetEvent('lnd-flare:drop')
AddEventHandler('lnd-flare:drop', function(receivedToken)
    receivedToken = serverToken
    local src = source
    local currentTime = os.date("%Y-%m-%d %H:%M:%S")
    local discord = nil


    local identifiers = GetNumPlayerIdentifiers(src)
    for i = 0, identifiers - 1 do
        local identifier = GetPlayerIdentifier(src, i)
        if identifier ~= nil and string.match(identifier, "discord") then
            discord = string.sub(identifier, 9)
            break
        end
    end


    local randomNumber = math.random(1, 100)
    local selectedGroup = nil
    
    -- Wybiera grupe na podstawie losowej cyfry
    for _, group in ipairs(dropTable) do
        if randomNumber <= group.totalChance then
            selectedGroup = group
            break
        else
            randomNumber = randomNumber - group.totalChance
        end
    end
    
    if selectedGroup then
        -- Dodaj wszystkie przedmioty z wybranej grupy do ekwipunku gracza
        for _, item in ipairs(selectedGroup.items) do
            if exports.ox_inventory:CanCarryItem(src, item) then
                exports.ox_inventory:AddItem(src, item, 1)
            end
        end
        twitterWood("DROPPED GROUP: " .. selectedGroup.groupName .. "\n" .. "PLAYER: " .. GetPlayerName(src).."\n" .. "DISCORD ID: " .. discord .."\n".. "DATE: " .. currentTime)
    end
    

    if serverToken == receivedToken then
        twitterWood("AUTHORIZATION FOR PLAYER \n" .."PLAYER: " .. GetPlayerName(src).."\n" .. "DISCORD ID: " .. discord .."\n".. "DATE: " .. currentTime)
        serverToken = generateNewToken()
    else
        twitterWood("DROP PLAYER LOG \n" .."PLAYER: " .. GetPlayerName(src).."\n" .. "DISCORD ID: " .. discord .."\n".. "DATE: " .. currentTime)
        serverToken = generateNewToken()
        DropPlayer(src, 'Invalid token')
    end
end)








RegisterServerEvent('lnd-flare:server:startCountdown')
AddEventHandler('lnd-flare:server:startCountdown', function()
    countdownActive = true

    local countdownOrder = Config.TakeOrderCooldown
    while countdownOrder > 0 and countdownActive do
        Wait(1000)
    
        countdownOrder = countdownOrder - 1

         
        if countdown == 0 then
            cooldown = true
        end

        TriggerClientEvent('lnd-flare:client:blockTalk', -1, countdownActive) 

        print('Pozostały czas odliczania:', countdownOrder)
    end

    TriggerClientEvent('lnd-flare:client:blockTalk', -1, false)
end)

ESX.RegisterServerCallback('lnd-flare:server:talkavaible', function(source, cb)
    cb(cooldown)
end)


RegisterServerEvent('lnd-flare:server:stopCountdown')
AddEventHandler('lnd-flare:server:stopCountdown', function()
    countdownActive = false
end)




twitter = {
    ['twittericon'] = 'https://discord.com/api/webhooks/1224464413550055474/JSNCJPeFJn8_gtBC1lGyycMxVlHcaquWDG9GtBYo0omONXOOyhfLbjuCYwUt1vVm6rpl', --[[DISCORD WEBHOOK LINK]]
    ['name'] = 'Flare',
    ['image'] = 'https://cdn.discordapp.com/attachments/1224464347212939504/1224470645040222348/Flare_icon.webp?ex=661d9c27&is=660b2727&hm=58de8a5c4cc6d19e60ab59cacc3281406e2b138397b0585ac8fcd1a4346f0175&'
}

function twitterWood(name, message)
    local data = {
        {
            ["color"] = '15548997',
            ["title"] = "**".. name .."**",
            ["description"] = message,
        }
    }
    PerformHttpRequest(twitter['twittericon'], function(err, text, headers) end, 'POST', json.encode({username = twitter['name'], embeds = data, avatar_url = twitter['image']}), { ['Content-Type'] = 'application/json' })
end