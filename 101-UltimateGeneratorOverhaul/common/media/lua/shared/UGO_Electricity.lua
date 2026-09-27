-- UGO electricity bridge for the Java sources supplied with the bug report.
-- Pure Lua compatibility layer: retains UGO's synthetic generator positions.
-- This is not a Java cache flush and does not change native generator ranges.
require "UGO_shared"

UGOElectricity = UGOElectricity or {}
local E = UGOElectricity
local MODULE = "UGO_Electricity"
local SAVE_KEY = "UGO_Electricity_v1"
local state
local points = {}

local function key(x, y, z)
    return x .. ":" .. y .. ":" .. z
end

local function authorityState()
    if not state then
        state = ModData.getOrCreate(SAVE_KEY)
        state.revision = state.revision or 0
        state.sources = state.sources or {}
    end
    return state
end

local function rebuildIndex()
    points = {}
    for _, source in pairs(state.sources) do
        -- Retain inactive footprints, to remove old positions when chunks load.
        for _, rect in ipairs(source.rects) do
            for x = rect.x, rect.x + rect.w - 1 do
                for y = rect.y, rect.y + rect.h - 1 do
                    local id = key(x, y, rect.z)
                    local p = points[id]
                    if not p then
                        p = { x = x, y = y, z = rect.z, active = false }
                        points[id] = p
                    end
                    p.active = p.active or source.active
                end
            end
        end
    end
end

function E.findBuilding(generator)
    local sq = generator and generator:getSquare()
    if not sq then return nil end
    if sq:getBuilding() then return sq:getBuilding() end
    -- No array of nullable squares: Lua's length operator is undefined for holes.
    local offsets = { {0,-1}, {0,1}, {-1,0}, {1,0},
                      {-1,-1}, {1,-1}, {-1,1}, {1,1} }
    for _, d in ipairs(offsets) do
        local nextSq = getCell():getGridSquare(sq:getX()+d[1], sq:getY()+d[2], sq:getZ())
        if nextSq and nextSq:getBuilding() then return nextSq:getBuilding() end
    end
end

local function buildingRects(building)
    local result = {}
    local rooms = building:getDef():getRooms()
    for i = 0, rooms:size() - 1 do
        local room = rooms:get(i)
        local rects = room:getRects()
        for j = 0, rects:size() - 1 do
            local r = rects:get(j)
            result[#result+1] = {x=r:getX(), y=r:getY(), z=room:getZ(),
                                w=r:getW(), h=r:getH()}
        end
    end
    return result
end

function E.reconcile()
    if not state then return end
    local cell = getCell()
    if not cell then return end
    local loaded = {}
    -- Phase 1: install ALL positions before consulting any appliance.
    for _, p in pairs(points) do
        local sq = cell:getGridSquare(p.x, p.y, p.z)
        if sq and sq:getChunk() then
            local chunk = sq:getChunk()
            local native = sq:getGenerator()
            if p.active or (native and native:isActivated()) then
                chunk:addGeneratorPos(p.x, p.y, p.z)
            else
                chunk:removeGeneratorPos(p.x, p.y, p.z)
            end
            loaded[#loaded+1] = sq
        end
    end
    -- Phase 2: refresh consumers. This call does NOT invalidate hasPowerTick.
    -- Do not remove consumers from the native chunk list when UGO switches off.
    for _, sq in ipairs(loaded) do
        local objects = sq:getObjects()
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            if obj:couldBePoweredByGenerator() then
                sq:getChunk():addObjectPoweredByGenerator(obj)
                obj:checkHaveElectricity()
            end
        end
    end
    if E.updateSound then E.updateSound(state.sources) end
end

function E.recalculateConsumption(generator)
    if isClient() then return end
    local md = generator:getModData()
    md.Consumption = 0
    if not md.PoweredOn then return end
    local building = E.findBuilding(generator)
    if not building then return end
    local seen = {}
    local total = 0.02
    local multiplier = getSandboxOptions():getOptionByName("GeneratorFuelConsumption"):getValue()
    for _, r in ipairs(buildingRects(building)) do
        for x = r.x, r.x+r.w-1 do
            for y = r.y, r.y+r.h-1 do
                local sq = getCell():getGridSquare(x, y, r.z)
                if sq then
                    local objects = sq:getObjects()
                    for i = 0, objects:size()-1 do
                        local obj = objects:get(i)
                        if not seen[obj] then
                            seen[obj] = true
                            if not zombie.inventory.ItemContainer.isObjectPowered(obj, false) then
                                total = total + math.max(0, obj:getGeneratorPowerConsumption()) * multiplier
                            end
                        end
                    end
                end
            end
        end
    end
    md.Consumption = total
end

local function publish(player)
    if not isServer() then return end
    if player then
        sendServerCommand(player, MODULE, "State", authorityState())
    else
        sendServerCommand(MODULE, "State", authorityState())
    end
end

-- SERVER / SINGLE PLAYER ONLY. The calling timed action or command must validate
-- the player's permissions. Automatic shutdown calls can use this directly.
function E.setGenerator(generator, active)
    if isClient() then return false, "server-only" end
    if type(active) ~= "boolean" or not generator or
       not UGOShared.isGeneratorCustom(generator) then return false, "invalid-generator" end
    local sq = generator:getSquare()
    if not sq then return false, "unloaded-generator" end
    local md = generator:getModData()
    if active and ((tonumber(md.FuelAmount) or 0) <= 0 or
                   (tonumber(md.Condition) or 0) <= 0) then
        return false, "no-fuel-or-broken"
    end
    local s = authorityState()
    local id = key(sq:getX(), sq:getY(), sq:getZ())
    local record = s.sources[id]
    if not record then
        local building = E.findBuilding(generator)
        if not building then return false, "no-building" end
        record = {x=sq:getX(), y=sq:getY(), z=sq:getZ(),
                  rects=buildingRects(building), active=false}
        if #record.rects == 0 then return false, "no-rooms" end
        s.sources[id] = record
    end
    -- The footprint is stable for this installed generator. Call setGenerator
    -- (oldObject, false) BEFORE moving/removing it. See migration notes.
    record.active = active
    md.PoweredOn = active
    if not active then md.Consumption = 0 end
    s.revision = s.revision + 1
    rebuildIndex()
    E.reconcile()                 -- Server Java state first.
    E.recalculateConsumption(generator)
    publish()                     -- Clients rebuild their own Java state.
    generator:transmitModData()   -- UGO metadata, not the electrical chunk list.
    return true
end

-- Call from perform() ONLY when retaining the supplied legacy timed action
-- (without complete()). Do not also call this from a native complete() path.
function E.requestGenerator(player, generator, active)
    if not isClient() then return E.setGenerator(generator, active) end
    local sq = generator and generator:getSquare()
    if not sq or not player then return false end
    sendClientCommand(player, MODULE, "SetGenerator", {
        x=sq:getX(), y=sq:getY(), z=sq:getZ(),
        index=generator:getObjectIndex(), active=active
    })
    return true -- Request queued, not an acknowledgement.
end

local function integer(n)
    return type(n) == "number" and n == n and n > -2147483648 and
           n < 2147483647 and n == math.floor(n)
end

local function onClientCommand(module, command, player, args)
    if module ~= MODULE or not isServer() or not player then return end
    if command == "GetState" then publish(player); return end
    if command ~= "SetGenerator" or type(args) ~= "table" then return end
    if not integer(args.x) or not integer(args.y) or not integer(args.z) or
       not integer(args.index) or type(args.active) ~= "boolean" then return end
    if player:isDead() or math.floor(player:getZ()) ~= args.z then return end
    local dx, dy = player:getX() - (args.x+0.5), player:getY() - (args.y+0.5)
    if dx*dx + dy*dy > 9 then return end
    local sq = getCell():getGridSquare(args.x, args.y, args.z)
    if not sq then return end
    local objects = sq:getObjects()
    if args.index < 0 or args.index >= objects:size() then return end
    local obj = objects:get(args.index)
    if not UGOShared.isGeneratorCustom(obj) then return end
    -- Fuel/condition are read from the server object; never trust client values.
    local ok, reason = E.setGenerator(obj, args.active)
    if not ok then
        sendServerCommand(player, MODULE, "Rejected", {reason=reason})
    end
end

local function onServerCommand(module, command, args)
    if module ~= MODULE or not isClient() then return end
    if command == "Rejected" then
        print("[UGO electricity] " .. tostring(args and args.reason))
        return
    end
    if command ~= "State" or type(args) ~= "table" or
       type(args.sources) ~= "table" or type(args.revision) ~= "number" then return end
    if state and args.revision < state.revision then return end
    state = args
    rebuildIndex()
    E.reconcile()
end

local function onInit()
    state = nil
    points = {}
    if not isClient() then authorityState(); rebuildIndex() end
end

local function onLoadChunk(chunk)
    if not isClient() and not state then authorityState(); rebuildIndex() end
    -- chunkLoaded() also purges positions in NEIGHBOURING chunks. Reconcile
    -- all known loaded footprints, not just the chunk passed to this event.
    E.reconcile()
end

local function onGameStart()
    if isClient() then
        sendClientCommand(MODULE, "GetState", {})
    else
        if not state then authorityState(); rebuildIndex() end
        E.reconcile()
    end
end

-- Read-only diagnostic; run on the actual appliance square on BOTH processes.
function E.debugSquare(x, y, z)
    local side = isServer() and "server" or (isClient() and "client" or "solo")
    local sq = getCell():getGridSquare(x, y, z)
    if not sq then print("[UGO "..side.."] unloaded"); return end
    print("[UGO "..side.."] "..key(x,y,z).." electricity="..tostring(sq:haveElectricity())..
          " grid="..tostring(sq:hasGridPower()))
    local objects = sq:getObjects()
    for i = 0, objects:size()-1 do
        local obj = objects:get(i)
        local raw = zombie.inventory.ItemContainer.isObjectPowered(obj, true)
        print("  "..i.." "..tostring(obj:getObjectName())..
              " raw="..tostring(raw).." cached="..tostring(obj:checkObjectPowered()))
        if instanceof(obj, "IsoLightSwitch") then
            print("  canSwitch="..tostring(obj:canSwitchLight())..
                  " active="..tostring(obj:isActivated()))
        end
        if instanceof(obj, "IsoTelevision") or instanceof(obj, "IsoRadio") then
            local device = obj:getDeviceData()
            if device then print("  devicePower="..tostring(device:canBePoweredHere())) end
        end
    end
end

Events.OnInitGlobalModData.Add(onInit)
Events.LoadChunk.Add(onLoadChunk)
Events.OnGameStart.Add(onGameStart)
Events.OnClientCommand.Add(onClientCommand)
Events.OnServerCommand.Add(onServerCommand)
