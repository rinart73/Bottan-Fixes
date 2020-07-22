if onServer() then


include("randomext")
local Azimuth = include("azimuthlib-basic")

local bottanFixes_configOptions = {
  _version = { default = "1.0", comment = "Config version. Don't touch." },
  ChanceToDestroyUpgrade = { default = 0, min = 0, max = 1, comment = "Chance to break Hyperspace Overloader when player destroys Bottan's hyperdrive. 0.75 = 75%" },
  UpgradeDeletionDelay = { default = 3, min = 0, max = 10, comment = "Delay in seconds before Hyperspace Overloader upgrade will break. Used to display 'Bottan's hyperdrive destroyed' message on client" }
}
local BottanFixesConfig, bottanFixes_isModified = Azimuth.loadConfig("BottanFixes", bottanFixes_configOptions)
if bottanFixes_isModified then
    Azimuth.saveConfig("BottanFixes", BottanFixesConfig, bottanFixes_configOptions)
end
bottanFixes_configOptions = nil

function bottanFixes_destroySmugglerBlocker()
    local craft = Player().craft
    if not craft then return end
    if BottanFixesConfig.ChanceToDestroyUpgrade ~= 0 and BottanFixesConfig.ChanceToDestroyUpgrade >= math.random() then
        deferredCallback(BottanFixesConfig.UpgradeDeletionDelay, "bottanFixes_deferredDestroySmugglerBlocker", craft.index) -- we can't immediately remove system, because this crashes the game :/
    end
end

function bottanFixes_deferredDestroySmugglerBlocker(craftIndex)
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