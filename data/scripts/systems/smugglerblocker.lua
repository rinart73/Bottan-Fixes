PermanentInstallationOnly = true

local bottanFixes_onStartDialog -- client, extended
local bottanFixes_onBlock -- server, extended

if onClient() then


bottanFixes_onStartDialog = onStartDialog
function onStartDialog(...)
    if getPermanent() and Player().craftIndex == Entity().index then
        bottanFixes_onStartDialog(...)
    end
end

function onBlock(entityId) -- overridden
    local entity = Entity(entityId)
    local title = entity.title
    entity:setTitle("", {})

    local dialog = {}
    dialog.text = "Charging ..."%_t .. "\n" .. "The hyperspace engine has been destroyed."%_t
    -- no follow up
    ScriptUI(entityId):showDialog(dialog)

    entity:setTitle(title, {})

    invokeServerFunction("onBlock", entityId)
end


else -- onServer


bottanFixes_onBlock = onBlock
function onBlock(...)
    local player = Player(callingPlayer)
    if not player or player.craftIndex ~= Entity().index then return end -- make sure that player is in the ship
    if not getPermanent() then return end -- should be installed as permanent now

    bottanFixes_onBlock(...)

    if player:hasScript("data/scripts/player/story/smugglerdelivery.lua") then
        player:invokeFunction("data/scripts/player/story/smugglerdelivery.lua", "bottanFixes_destroySmugglerBlocker")
    end
end


end