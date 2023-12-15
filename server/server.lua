ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('kAdmin:Admin_GetPerm', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil then
        local playerGroup = xPlayer.getGroup()
        if playerGroup ~= nil then
            cb(playerGroup)
        else
            cb(nil)
        end
    else
        cb(nil)
    end
end)
RegisterServerEvent("give")
AddEventHandler("give",function(item, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(item, amount)
end)

    local jailedPlayers = {}

    local function jailPlayer(source, targetId, jailTime, reason, position)
        local xPlayer = ESX.GetPlayerFromId(source)
        local targetPlayer = ESX.GetPlayerFromId(targetId)
    
        local targetName = GetPlayerName(targetId)
        local jailerName = GetPlayerName(source)
    
        MySQL.Async.execute('INSERT INTO jail (identifier, name, jailTime, reason, jailer) VALUES (@identifier, @name, @jailTime, @reason, @jailer)', {
            ['@identifier'] = targetPlayer.getIdentifier(),
            ['@name'] = targetName,
            ['@jailTime'] = jailTime,
            ['@reason'] = reason,
            ['@jailer'] = jailerName
        })
    
        targetPlayer.setCoords(position)
    
        jailedPlayers[targetId] = {releaseTime = os.time() + jailTime * 60, isJailed = true, manualUnjail = false}
    
        xPlayer.showNotification('Vous avez emprisonné ' .. targetName .. ' pour ' .. jailTime .. ' minutes pour la raison suivante : ' .. reason)

    end
    
    local function unjailPlayer(identifier)
        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    
        if xPlayer then
            if jailedPlayers[xPlayer.source] then
                jailedPlayers[xPlayer.source].manualUnjail = true
            end
    
            local position = {
                x = 1847.9,
                y = 2586.2,
                z = 45.7
            }
    
            xPlayer.setCoords(position)
    
            MySQL.Async.execute('DELETE FROM jail WHERE identifier = @identifier', {
                ['@identifier'] = identifier
            })

        end
    end
    
    RegisterServerEvent('jail')
    AddEventHandler('jail', function(playerID, jailTime, reason, position)
        local source = source
        local targetPlayer = ESX.GetPlayerFromId(playerID)
    
        if targetPlayer and jailTime and reason then
            jailPlayer(source, playerID, jailTime, reason, position)
        else
            print("Erreur: ID de joueur, Temps ou raison invalide")
        end
    end)
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
    
            for playerId, data in pairs(jailedPlayers) do
                if data.manualUnjail == false and os.time() >= data.releaseTime then
                    local xPlayer = ESX.GetPlayerFromId(playerId)
    
                    if xPlayer then
                        MySQL.Async.fetchScalar('SELECT identifier FROM jail WHERE identifier = @identifier', {
                            ['@identifier'] = xPlayer.getIdentifier()
                        }, function(result)
                            if result then
                                local position = {
                                    x = 1847.9,
                                    y = 2586.2,
                                    z = 45.7
                                }
    
                                xPlayer.setCoords(position)
    
                                MySQL.Async.execute('DELETE FROM jail WHERE identifier = @identifier', {
                                    ['@identifier'] = xPlayer.getIdentifier()
                                })
    
                                jailedPlayers[playerId] = nil

                            end
                        end)
                    end
                end
            end
        end
end)

RegisterCommand('notif', function(PlayerPedId, args, rawCommand)
    if #args > 0 then
        local mot = table.concat(args, ' ')
        notif(mot)
    end
end)

function notif(mot)
local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        TriggerClientEvent('ox_lib:notify', xPlayers[i], {
            id = 'notif',
            title = 'Annonce',
            description = mot,
            position = 'top',
            duration = '1000',
            style = {
                backgroundColor = '#141517',
                color = '#FFFFFF',
                ['.description'] = {
                  color = '#909296'
                },
            },
            icon = 'bullhorn',
            iconColor = '#F8FFD6'
        })
    end
end

    