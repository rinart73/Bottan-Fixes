if onServer() then


include("randomext")
Azimuth = include("azimuthlib-basic")

local bof_configOptions = {
  _version = { default = "1.0", comment = "Config version. Don't touch." },
  ChanceToDestroyUpgrade = { default = 0, min = 0, max = 1, comment = "Chance to break Hyperspace Overloader when player destroys Bottan's hyperdrive. 0.75 = 75%" },
  UpgradeDeletionDelay = { default = 3, min = 0, max = 10, comment = "Delay in seconds before Hyperspace Overloader upgrade will break. Used to display 'Bottan's hyperdrive destroyed' message on client" }
}
local bof_config, bof_isModified = Azimuth.loadConfig("BottanFixes", bof_configOptions)
if bof_isModified then
    Azimuth.saveConfig("BottanFixes", bof_config, bof_configOptions)
end
bof_configOptions = nil

function bof_destroySmugglerBlocker()
    local craft = Player().craft
    if not craft then return end

    if bof_config.ChanceToDestroyUpgrade ~= 0 and bof_config.ChanceToDestroyUpgrade >= math.random() then
        deferredCallback(bof_config.UpgradeDeletionDelay, "bof_deferredDestroySmugglerBlocker", craft.index) -- we can't immediately remove system, because this crashes the game :/
    end
end

function bof_deferredDestroySmugglerBlocker(craftIndex)
    local craft = Sector():getEntity(craftIndex)
    if not craft then return end

    -- remove Hyperspace Overloader from a ship
    local shipSystem = ShipSystem(craft)
    if not shipSystem then return end
    for i = 0, shipSystem.numSlots - 1 do
        local upgrade = shipSystem:getUpgrade(i)
        if upgrade and upgrade.script == "data/scripts/systems/smugglerblocker.lua" then
            shipSystem:removeUpgrade(i)
            break
        end
    end
    -- it will return to player/alliance inventory, now we need to find and destroy it
    local inventory = Faction(craft.factionIndex):getInventory()
    local upgrades = inventory:getItemsByType(InventoryItemType.SystemUpgrade)
    for idx, item in pairs(upgrades) do
        if item.item.script == "data/scripts/systems/smugglerblocker.lua" then
            inventory:remove(idx)
            break
        end
    end
    Player():sendChatMessage("Server", 0, "Hyperspace Overloader couldn't withstand the pressure! The job is done, but the system upgrade broke."%_t)
end


end