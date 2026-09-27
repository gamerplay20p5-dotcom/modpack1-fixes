require "TimedActions/ISBaseTimedAction"

ProximitySensorActivation = ISBaseTimedAction:derive("ProximitySensorActivation");


function ProximitySensorActivation:calculateArea(square)
	--- Check if the building contains rooms
	local roomDefs = square:getBuilding():getDef():getRooms()
	if not roomDefs then return 0 end

	local area = 0
	for i = 0, roomDefs:size() - 1 do
		area = area + roomDefs:get(i):getArea()
	end

	return area
end

--- Checks if the action is valid before updating.
--- @return boolean If the action is valid.
function ProximitySensorActivation:isValid()
	local building = self.square and self.square:getBuilding() and self.square:getBuilding():getDef()

	if not building then
		self.character:Say(getText('UI_ProximitySensorActivation_notInsideBuilding'))
		return false
	end

	local area = ProximitySensorActivation:calculateArea(self.square)
	self.nbScrapNeeded = math.ceil(0.251 * math.pow(area, 0.796))
	if self.activate and self.character:getInventory():getCountTypeRecurse("Base.ElectronicsScrap") < self.nbScrapNeeded then
		self.character:Say(getText('UI_ProximitySensorActivation_needScrap_1') .. self.nbScrapNeeded .. getText('UI_ProximitySensorActivation_needScrap_2'))
		return false
	end

	return true
end

--- Waits for the action to become valid to start.
--- @return boolean If the action can start.
function ProximitySensorActivation:waitToStart()
	self.character:faceThisObject(self.generator)
	return self.character:shouldBeTurning()
end

--- Starts the action.
function ProximitySensorActivation:start()
	local area = ProximitySensorActivation:calculateArea(self.square)
	self.action:setTime(math.ceil(0.251 * math.pow(area, 0.796) * 10))
	if self.character:isTimedActionInstant() then
		self.action:setTime(1)
	end

	self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Mid")
	self.character:reportEvent("EventLootItem")
end

--- Updates the action every tick.
function ProximitySensorActivation:update()
	self.character:faceThisObject(self.generator)
	self.character:setMetabolicTarget(Metabolics.HeavyDomestic);
end

--- Stops the action.
function ProximitySensorActivation:stop()
    ISBaseTimedAction.stop(self);
end

--- Handles the activation of the proximity sensor.
--- This function checks if the generator is inside or near to a building
--- and handles the activation or deactivation of the proximity sensor.
--- @param generator any The generator object.
---	@param activate boolean Whether to activate or deactivate the proximity sensor.
function ProximitySensorActivation:handleProximitySensor(square, generator, activate)
	--- Check if square is inside a building
	local roomDefs = square:getBuilding():getDef():getRooms() or ArrayList.new()
	for i = 0, roomDefs:size() - 1 do
		local squares = roomDefs:get(i):getIsoRoom():getSquares() or ArrayList.new()
		for j = 0, squares:size() - 1 do
			local currSquare = squares:get(j)
			if currSquare then
				currSquare:getModData()['proximityAlert'] = activate
				currSquare:getModData()['generator'] = generator
				currSquare:transmitModdata()
			end
		end
	end
	generator:getModData()['proximityAlert'] = activate
	generator:getSquare():transmitModdata()
	generator:transmitModData()
end

--- Performs the action at the end.
function ProximitySensorActivation:perform()
	self.character:playSound("activateSensor")
	ProximitySensorActivation:handleProximitySensor(self.square, self.generator, self.activate)

	-- Remove all ElectronicsScrap from the inventory
	for _ = 1, self.nbScrapNeeded do
		if self.activate then
			local item = self.character:getInventory():getFirstTypeRecurse("Base.ElectronicsScrap")
			self.character:getInventory():Remove(item)
			sendRemoveItemFromContainer(self.character:getInventory(), item)
		else
			self.character:getInventory():AddItem("Base.ElectronicsScrap")
		end
	end

	ISBaseTimedAction.perform(self);
end

--- Constructor for the ProximitySensorActivation class.
--- @field character any IsoGameCharacter
--- @field generator any IsoGenerator
--- @field activate boolean If the proximity sensor should be activated or deactivated.
function ProximitySensorActivation:new(character, generator)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.generator = generator;
	o.activate = not generator:getModData()['proximityAlert'];
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = 30;

	local square = generator:getSquare()
	local adjacentSquares = {
		square,                                     -- Center
		square:getAdjacentSquare(IsoDirections.N),  -- North
		square:getAdjacentSquare(IsoDirections.S),  -- South
		square:getAdjacentSquare(IsoDirections.W),  -- West
		square:getAdjacentSquare(IsoDirections.E),  -- East
		square:getAdjacentSquare(IsoDirections.NW), -- North West
		square:getAdjacentSquare(IsoDirections.NE), -- North East
		square:getAdjacentSquare(IsoDirections.SW), -- South West
		square:getAdjacentSquare(IsoDirections.SE)  -- South East
	}

	for i = 1, #adjacentSquares do
		if adjacentSquares[i]:getBuilding() then
			o.square = adjacentSquares[i]
			break
		end
	end

	return o;
end
