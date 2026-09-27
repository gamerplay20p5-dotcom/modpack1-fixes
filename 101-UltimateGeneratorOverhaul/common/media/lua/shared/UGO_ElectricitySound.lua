require "UGO_Electricity"
if isServer() then return end

local sounds = {}

local function stop(generator)
    local sound = sounds[generator]
    if not sound then return end
    sound.emitter:stopAll()
    IsoWorld.instance:returnOwnershipOfEmitter(sound.emitter)
    sounds[generator] = nil
end

function UGOElectricity.updateSound(sources)
    for _, source in pairs(sources) do
        local sq = getCell():getGridSquare(source.x, source.y, source.z)
        if sq then
            local objects = sq:getObjects()
            for i = 0, objects:size()-1 do
                local obj = objects:get(i)
                if UGOShared.isGeneratorCustom(obj) then
                    if source.active then
                        if not sounds[obj] then
                            local emitter = IsoWorld.instance:getFreeEmitter(source.x+0.5, source.y+0.5, source.z)
                            IsoWorld.instance:takeOwnershipOfEmitter(emitter)
                            emitter:playSound("GeneratorLoop")
                            sounds[obj] = {emitter=emitter, square=sq}
                        end
                    else
                        stop(obj)
                    end
                end
            end
        end
    end
end

Events.OnTick.Add(function()
    for obj, sound in pairs(sounds) do
        local sq = sound.square
        if obj:getObjectIndex() < 0 or
           getCell():getGridSquare(sq:getX(), sq:getY(), sq:getZ()) ~= sq then
            stop(obj)
        else
            sound.emitter:tick()
        end
    end
end)

Events.OnObjectAboutToBeRemoved.Add(stop)
