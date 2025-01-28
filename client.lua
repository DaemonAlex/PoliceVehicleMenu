local QBCore = exports['qb-core']:GetCoreObject()

-- Debug: Check if ox_lib is loaded
print("Checking if ox_lib is loaded...")
if not lib then
    print("^1[ERROR] ox_lib is not loaded. Attempting to initialize it manually...^7")
    
    -- Attempt to initialize ox_lib manually
    lib = exports.ox_lib:init()
    
    if not lib then
        print("^1[ERROR] Failed to initialize ox_lib. Please ensure ox_lib is installed and started before PoliceVehicleMenu.^7")
        return
    else
        print("^2[SUCCESS] ox_lib initialized manually.^7")
    end
else
    print("^2[SUCCESS] ox_lib is loaded and ready to use.^7")
end

-- Command to open the vehicle modification menu
RegisterCommand('modvehicle', function()
    local ped = PlayerPedId()
    if IsPedSittingInAnyVehicle(ped) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleModel = GetEntityModel(vehicle)
        local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel):lower()

        -- Check if the vehicle is in the Config.PoliceVehicles list
        if IsVehicleInConfig(vehicleName) then
            TriggerServerEvent('vehiclemods:server:verifyPoliceJob')
        else
            lib.notify({
                title = 'Error',
                description = 'This menu is only for approved police vehicles.',
                type = 'error',
                duration = 5000
            })
        end
    else
        lib.notify({
            title = 'Error',
            description = 'You must be inside a vehicle to use this command.',
            type = 'error',
            duration = 5000
        })
    end
end)

-- Function to check if the vehicle is in the Config.PoliceVehicles list
function IsVehicleInConfig(vehicleName)
    for _, v in pairs(Config.PoliceVehicles) do
        if v == vehicleName then
            return true
        end
    end
    return false
end

-- Event to open the vehicle modification menu
RegisterNetEvent('vehiclemods:client:openVehicleModMenu')
AddEventHandler('vehiclemods:client:openVehicleModMenu', function()
    OpenVehicleModMenu()
end)

-- Function to open the modification menu using ox_lib
function OpenVehicleModMenu()
    local options = {
        {
            title = 'Performance Upgrades',
            description = 'Upgrade your vehicle\'s performance.',
            onSelect = function()
                TriggerEvent('vehiclemods:client:upgradePerformance')
            end
        },
        {
            title = 'Change Skin',
            description = 'Change your vehicle\'s appearance.',
            onSelect = function()
                TriggerEvent('vehiclemods:client:changeSkin')
            end
        },
        {
            title = 'Toggle Extras',
            description = 'Enable or disable vehicle extras.',
            onSelect = function()
                TriggerEvent('vehiclemods:client:toggleExtras')
            end
        }
    }

    lib.registerContext({
        id = 'vehicleModMenu',
        title = 'Vehicle Modification Menu',
        options = options
    })

    lib.showContext('vehicleModMenu')

    -- Keep the menu open until ESC is pressed
    Citizen.CreateThread(function()
        local menuOpen = true
        while menuOpen do
            Citizen.Wait(0)
            -- Check if the ESC key (key code 177) is pressed
            if IsControlJustPressed(0, 177) then
                menuOpen = false  -- Close the menu when ESC is pressed
                lib.hideContext()  -- Hide the menu
            end
        end
    end)
end

-- Event to handle performance upgrades
RegisterNetEvent('vehiclemods:client:upgradePerformance')
AddEventHandler('vehiclemods:client:upgradePerformance', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    SetVehicleModKit(vehicle, 0)
    for i = 0, 49 do
        SetVehicleMod(vehicle, i, GetNumVehicleMods(vehicle, i) - 1, false)
    end
    lib.notify({
        title = 'Success',
        description = 'Vehicle performance upgraded to level 4.',
        type = 'success',
        duration = 5000
    })

    -- Save modifications to the database
    local vehicleModel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    TriggerServerEvent('vehiclemods:server:saveModifications', vehicleModel, 4, nil, nil)
end)

-- Event to handle skin changes
RegisterNetEvent('vehiclemods:client:changeSkin')
AddEventHandler('vehiclemods:client:changeSkin', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local skin = math.random(Config.SkinsRange.min, Config.SkinsRange.max)
    SetVehicleLivery(vehicle, skin)
    lib.notify({
        title = 'Success',
        description = 'Vehicle skin changed to ' .. skin .. '.',
        type = 'success',
        duration = 5000
    })

    -- Save modifications to the database
    local vehicleModel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    TriggerServerEvent('vehiclemods:server:saveModifications', vehicleModel, nil, skin, nil)
end)

-- Event to handle toggling extras
RegisterNetEvent('vehiclemods:client:toggleExtras')
AddEventHandler('vehiclemods:client:toggleExtras', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local extra = math.random(Config.ExtrasRange.min, Config.ExtrasRange.max)
    SetVehicleExtra(vehicle, extra, false)
    lib.notify({
        title = 'Success',
        description = 'Vehicle extra ' .. extra .. ' toggled.',
        type = 'success',
        duration = 5000
    })

    -- Save modifications to the database
    local vehicleModel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    TriggerServerEvent('vehiclemods:server:saveModifications', vehicleModel, nil, nil, tostring(extra))
end)

-- Event to apply saved modifications when entering a vehicle
RegisterNetEvent('vehiclemods:client:applyModifications')
AddEventHandler('vehiclemods:client:applyModifications', function(data)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if DoesEntityExist(vehicle) then
        -- Apply performance level
        SetVehicleModKit(vehicle, 0)
        for i = 0, 49 do
            SetVehicleMod(vehicle, i, data.performance_level, false)
        end

        -- Apply skin
        if data.skin then
            SetVehicleLivery(vehicle, data.skin)
        end

        -- Apply extras
        if data.extras then
            local extras = json.decode(data.extras)
            for _, extra in pairs(extras) do
                SetVehicleExtra(vehicle, extra, false)
            end
        end
    end
end)
