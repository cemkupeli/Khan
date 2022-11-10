Army = Class {}

function Army:init(infantry, archers, cavalry, general, isComputer)

    -- Infantry attributes
    self.infCount = infantry["count"]
    self.infCharge = infantry["charge"]
    self.infSkirmish = infantry["skirmish"]

    -- Archer attributes
    self.arcCount = archers["count"]
    self.arcRanged = archers["ranged"]
    self.arcSkirmish = archers["skirmish"]

    -- Cavalry attributes (the computer, controlling the Chinese army, does not have cavalry)
    self.cavCount = cavalry["count"]
    self.cavCharge = cavalry["charge"]
    self.cavSkirmish = cavalry["skirmish"]

    -- General attributes
    self.morale = general["morale"]

    -- Whether army is AI controlled or not
    self.isComputer = isComputer

end

-- Renders the army details
function Army:renderArmy(x, y, width)

    -- Renders army title
    love.graphics.setFont(large)
    if self.isComputer then
        love.graphics.printf("Enemy Army", x, y, width)
    else 
        love.graphics.printf("Your Army", x, y, width)
    end

    love.graphics.setFont(medium)

    -- Renders infantry details
    love.graphics.printf("Infantry: " .. tostring(round(self.infCount, 0)), x, y + 60, width)
    love.graphics.printf("Charge: " .. tostring(round(self.infCharge, 0)), x + 20, y + 90, width)
    love.graphics.printf("Skirmish: " .. tostring(round(self.infSkirmish)), x + 20, y + 120, width)

    -- Renders archer details
    love.graphics.printf("Archers: " .. tostring(round(self.arcCount)), x, y + 180, width)
    love.graphics.printf("Ranged: " .. tostring(round(self.arcRanged)), x + 20, y + 210, width)
    love.graphics.printf("Skirmish: " .. tostring(round(self.arcSkirmish)), x + 20, y + 240, width)

    -- Renders cavalry details
    if self.isComputer == false then
        love.graphics.printf("Cavalry: " .. tostring(round(self.cavCount)), x, y + 300, width)
        love.graphics.printf("Charge: " .. tostring(round(self.cavCharge)), x + 20, y + 330, width)
        love.graphics.printf("Skirmish: " .. tostring(round(self.cavSkirmish)), x + 20, y + 360, width)
    end

    -- Renders general details
    love.graphics.printf("Morale: " .. tostring(round(self.morale, 1)), x, y + 420, width)

end

-- Rounding function
-- Source: http://lua-users.org/wiki/SimpleRound
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end