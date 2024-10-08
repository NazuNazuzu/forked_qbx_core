lib.versionCheck('Qbox-project/qbx_core')
local startupErrors, errorMessage
if not lib.checkDependency('ox_lib', '3.20.0', true) then
    startupErrors, errorMessage = true, 'ox_lib version 3.20.0 or higher is required'
elseif not lib.checkDependency('ox_inventory', '2.42.1', true) then
    startupErrors, errorMessage = true, 'ox_inventory version 2.42.1 or higher is required'
elseif GetConvar('inventory:framework', '') ~= 'qbx' then
    startupErrors, errorMessage = true, 'inventory:framework must be set to "qbx" in order to use qbx_core'
elseif GetConvarInt('onesync_enableInfinity', 0) ~= 1 then
    startupErrors, errorMessage = true, 'OneSync Infinity is not enabled. You can do so in txAdmin settings or add +set onesync on to your server startup command line'
end
if startupErrors then
    lib.print.error('Startup errors detected, shutting down server...')
    ExecuteCommand('quit immediately')
    for _ = 1, 100 do
        lib.print.error(errorMessage)
    end
    error(errorMessage)
end

---@type 'strict'|'relaxed'|'inactive'
local bucketLockDownMode = GetConvar('qbx:bucketlockdownmode', 'inactive')
SetRoutingBucketEntityLockdownMode(0, bucketLockDownMode)

QBX = {}
QBX.Shared = require 'shared.main'

---@alias Source integer
---@type table<Source, Player>
QBX.Players = {}
GlobalState.PlayerCount = 0
GlobalState.MaxPlayers = GetConvarInt('sv_maxclients', 48)

QBX.Player_Buckets = {}
QBX.Entity_Buckets = {}
QBX.UsableItems = {}

---@alias Model number
---@alias VehicleClass integer see https://docs.fivem.net/natives/?_0x29439776AAA00A62
---@type table<Model, VehicleClass>
local vehicleClasses = {}

---Caches the vehicle classes the first time this is called by getting the data from a random client.
---Returns nil if there is no cache and no client is connected to get the data from.
---@param model number
---@return VehicleClass?
function GetVehicleClass(model)
    if #vehicleClasses == 0 then
        local players = GetPlayers()
        if #players == 0 then return end
        local playerId = players[math.random(#players)]
        vehicleClasses = lib.callback.await('qbx_core:client:getVehicleClasses', playerId)
    end
    return vehicleClasses[model]
end

exports('GetVehicleClass', GetVehicleClass)

---@return table<string, Vehicle>
function GetVehiclesByName()
    return QBX.Shared.Vehicles
end

exports('GetVehiclesByName', GetVehiclesByName)

---@return table<number, Vehicle>
function GetVehiclesByHash()
    return QBX.Shared.VehicleHashes
end

exports('GetVehiclesByHash', GetVehiclesByHash)

---@return table<string, Vehicle[]>
function GetVehiclesByCategory()
	return qbx.table.mapBySubfield(QBX.Shared.Vehicles, 'category')
end

exports('GetVehiclesByCategory', GetVehiclesByCategory)

---@return table<number, Weapon>
function GetWeapons()
    return QBX.Shared.Weapons
end

exports('GetWeapons', GetWeapons)

---@deprecated
---@return table<string, vector4>
function GetLocations()
    return QBX.Shared.Locations
end

exports('GetLocations', GetLocations)
