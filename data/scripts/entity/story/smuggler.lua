local bof_onShotHit -- extended server function


if onServer() then


if GameVersion() < Version("1.3.5") then

bof_onShotHit = onShotHit
function onShotHit(...)
    if not wasHit and not canFlee then
        for _, player in pairs({Sector():getPlayers()}) do
            player:invokeFunction("story/smugglerdelivery", "fail") -- prevent people from farming bottan by re-entering the sector again and again
        end
    end

    bof_onShotHit(...)
end

end

-- onCantJump shouldn't be callable by a client
Callable["onCantJump"] = nil


end