

UGOShared = {}
UGOShared.Verbose = false
UGOShared.Key = 'GeneratorOverhaul'

function UGOShared.getModData()
    local modData = ModData.getOrCreate(UGOShared.Key)
    if isClient() then
        ModData.request(UGOShared.Key)
    end

    if not modData.Generator then modData.Generator = {} end
    if not modData.LightSensor then modData.LightSensor = {} end

    return modData
end

function UGOShared.coordsToKey(square)
    return square:getX() .. "_" .. square:getY() .. "_" .. square:getZ()
end
function UGOShared.coordsChunkToKey(chunkWX, chunkWY)
    return chunkWX .. "_" .. chunkWY
end

function UGOShared.getChunkX(square)
    return math.floor(square:getX() / 8)
end
function UGOShared.getChunkY(square)
    return math.floor(square:getY() / 8)
end

function UGOShared.transmitUGOModData()
    ModData.transmit(UGOShared.Key)
end

Events.OnInitGlobalModData.Add(UGOShared.getModData)

function UGOShared.isGeneratorCustom(object)
    return object:getName() == "GeneratorCustom" and
           object:getTextureName() and
           (object:getTextureName() == "security_01_0" or
            object:getTextureName() == "security_01_1" or
            object:getTextureName() == "security_01_2" or
            object:getTextureName() == "security_01_3")
end