Battle = Class {}

-- Battle time decrease interval
local BATTLE_TIME_DEC = 1
-- Prompt time decrease interval
local PROMPT_TIME_DEC = 40
-- Length between subsequent prompts
local PROMPT_INTERVAL = 400
-- The duration of each prompt on the screen before it disappears or the user makes a choice
local PROMPT_TIME = 800

function Battle:init(playerArmy, computerArmy, terrain)

    -- Stores the player army
    self.playerArmy = playerArmy

    -- Properties that keep track of whether any of the player's units are retreating (and whether the infantry is bracing)
    self.infRetreating = false
    self.cavRetreating = false
    self.arcRetreating = false
    self.infBracing = false

    -- Stores the computer army
    self.computerArmy = computerArmy

    -- Calculates morale per unit (MPU) for each unit the two armies have. Apportions the total morale to different units 
    -- with different weights, and then calculates how much morale each unit of that type provides to the army.
    -- 10 is added before the portion of morale for each unit is divided by the unit count to ensure that armies can
    -- run out of morale and rout before they lose all their units (realistically)
    local playerInfMorale = self.playerArmy.morale * 0.6
    local playerCavMorale = self.playerArmy.morale * 0.25
    local playerArcMorale = self.playerArmy.morale * 0.15
    playerMPU = {
        ["infantry"] = (playerInfMorale + 10) / self.playerArmy.infCount,
        ["cavalry"] = (playerCavMorale + 10) / self.playerArmy.cavCount,
        ["archers"] = (playerArcMorale + 10) / self.playerArmy.arcCount
    }

    local computerInfMorale = self.computerArmy.morale * 0.9
    local computerArcMorale = self.computerArmy.morale * 0.1
    computerMPU = {
        ["infantry"] = (computerInfMorale + 10) / self.computerArmy.infCount,
        ["archers"] = (computerArcMorale + 10) / self.computerArmy.arcCount
    }

    -- The current terrain
    self.terrain = terrain

    -- The information that will be displayed regarding the terrain
    terrainInfo = {
        ["Steppe"] = "No army should stand a chance against the Mongol horde on the open steppe.",
        ["Mountains"] = "Your cavalry are unable to move quickly when fighting uphill: Cavalry Charge --",
        ["Urban"] = "Your cavalry and archers have difficulty targeting enemies in close quarters: Cavalry Charge --, Cavalry Skirmish --, Archer Ranged --"
    }

    -- The winner of the battle
    self.winner = "none"

    -- Battle states: prompt and fight
    self.battleState = "prompt" 
    
    -- The battle timer
    self.battleTimer = 2000

    -- The prompt marker (indicates the location of the next prompt)
    self.promptMarker = 2000

    -- The current prompt
    self.currentPrompt = 1

    -- The prompt timer
    self.promptTimer = PROMPT_TIME

    -- A bool keeping track of whether prompts are finished (after an end prompt is reached)
    self.promptsFinished = false

    -- The prompts
    self.prompts = {
        {
            ["text"] = "Choose your opening move:",
            ["choice1"] = "1 - Send the archers forward",
            ["event1"] = "volley",
            ["next1"] = 2, 
            ["choice2"] = "2 - Order the cavalry to charge",
            ["event2"] = "cavChargeInf",
            ["next2"] = 3,
            ["choice3"] = "3 - Order the entire army to march",
            ["event3"] = "march",
            ["next3"] = 4
        },
        {
            ["text"] = "The enemy infantry charges at your archers:",
            ["choice1"] = "1 - Order the archers to retreat",
            ["event1"] = "arcRet",
            ["next1"] = 3,
            ["choice2"] = "2 - Order the infantry to advance",
            ["event2"] = "infAttack",
            ["next2"] = 4,
            ["choice3"] = "3 - Order the cavalry to flank the enemy",
            ["event3"] = "cavFlank",
            ["next3"] = 3
        },
        {
            ["text"] = "The enemy archers open fire on your cavalry:",
            ["choice1"] = "1 - Order the cavalry to retreat",
            ["event1"] = "cavRet",
            ["next1"] = 5,
            ["choice2"] = "2 - Send our archers forward to provide support",
            ["event2"] = "volley",
            ["next2"] = 2,
            ["choice3"] = "3 - Order the cavalry to charge at their archers",
            ["event3"] = "cavChargeArc",
            ["next3"] = 6
        },
        {
            ["text"] = "The enemy army archers open fire on your infantry:",
            ["choice1"] = "1 - Order the infantry to brace",
            ["event1"] = "brace",
            ["next1"] = 5,
            ["choice2"] = "2 - Order the infantry to continue their march",
            ["event2"] = "infAttack",
            ["next2"] = 5,
            ["choice3"] = "3 - Order the archers to open fire on the enemy",
            ["event3"] = "volley",
            ["next3"] = 5
        },
        {
            ["text"] = "The enemy infantry charges at your infantry",
            ["choice1"] = "1 - Order the archers to open fire",
            ["event1"] = "volley",
            ["next1"] = 0,
            ["choice2"] = "2 - Order the cavalry to flank their infantry",
            ["event2"] = "cavFlank",
            ["next2"] = 0,
            ["choice3"] = "3 - Order the infantry to brace",
            ["event3"] = "brace",
            ["next3"] = 0
        },
        {
            ["text"] = "The enemy infantry flanks your cavalry",
            ["choice1"] = "1 - Order the cavalry to retreat",
            ["event1"] = "cavRet",
            ["next1"] = 0,
            ["choice2"] = "2 - Order the cavalry to attack their infantry",
            ["event2"] = "cavAttackInf",
            ["next2"] = 0,
            ["choice3"] = "3 - Order the infantry to charge at their infantry",
            ["event3"] = "infCharge",
            ["next3"] = 0
        }
    }

end

-- The update function for the battle class
function Battle:update(dt)

    -- If the battle state is currently the end state, pressing Enter will return to the map
    if self.battleState == "end" then
        if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
            -- Increments the nextBattle global by 1 to indicate if the player has won the battle before changing the game state
            if self.winner == "player" then
                nextBattle = nextBattle + 1
            end
            gameState = "map"
        end
    end

    -- If the morale of one of the armies reaches 0, ends the battle
    if self.computerArmy.morale == 0 then
        self.battleState = "end"
        self.winner = "player"
    elseif self.playerArmy.morale == 0 then
        self.battleState = "end"
        self.winner = "computer"
    end

    -- If the current prompt has been set to 0 (end prompt), disables the prompt mechanic
    if self.currentPrompt == 0 then
        self.promptsFinished = true
    end

    -- If the battle timer has reached the next prompt marker, sets the battle state to prompt
    if self.battleTimer <= self.promptMarker and self.battleState == "fight" and self.promptsFinished == false then
        self.battleState = "prompt"
    end

    -- If the battle state is currently fight (i.e the player isn't prompted), calls simulate combat and decreases the battle timer
    if self.battleState == "fight" then
        self:simulateCombat(dt)
        self.battleTimer = self.battleTimer - BATTLE_TIME_DEC

    -- If the player is currently prompted 
    elseif self.battleState == "prompt" then

        -- If the 1 key was pressed
        if love.keyboard.wasPressed("1") then
            -- Processes the current prompt's first choice
            self:processChoice(self.prompts[self.currentPrompt]["event1"], "1")

            -- Sets the battle state to fight
            self.battleState = "fight"
            -- Moves the prompt marker
            self.promptMarker = self.promptMarker - PROMPT_INTERVAL
             
        -- If the w key was pressed
        elseif love.keyboard.wasPressed("2") then
            -- Processes the current prompt's secomd choice
            self:processChoice(self.prompts[self.currentPrompt]["event2"], "2")

            -- Sets the battle state to fight
            self.battleState = "fight"
            -- Moves the prompt marker
            self.promptMarker = self.promptMarker - PROMPT_INTERVAL

        -- If the 3 key was pressed
        elseif love.keyboard.wasPressed("3") then
            -- Processes the current prompt's third choice
            self:processChoice(self.prompts[self.currentPrompt]["event3"], "3")

            -- Sets the battle state to fight
            self.battleState = "fight"
            -- Moves the prompt marker
            self.promptMarker = self.promptMarker - PROMPT_INTERVAL
            
        -- Initially, the player is provided with time to examine the screen, the terrain modifiers, etc.
        -- Therefore, the prompt timer is activated starting with the second prompt
        elseif self.currentPrompt > 1 then
            -- If a key isn't pressed, decreases the prompt timer (caps the prompt timer at 0)
            self.promptTimer = math.max(self.promptTimer - PROMPT_TIME_DEC * dt, 0)

        end

        -- If the prompt timer is 0, calls processChoice and passes "noChoice" to indicate the player has run out of time
        -- For choice, a random number between 1-3 is passed (a random prompt choice is chosen)
        if self.promptTimer == 0 then
            self:processChoice("noChoice", math.random(3))

            -- Sets the battle state to fight
            self.battleState = "fight"

            -- Moves the prompt marker
            self.promptMarker = self.promptMarker - PROMPT_INTERVAL
        end
    end

end

-- Renders the battle graphics
function Battle:render(promptX, promptY, choicesX, choicesY)

    -- Renders both armies
    self.playerArmy:renderArmy(50, 50, 200)
    self.computerArmy:renderArmy(WINDOW_WIDTH - 250, 50, 200)

    -- For testing
    -- love.graphics.printf("Battle timer: " .. tostring(self.battleTimer), 200, 100, 200)
    -- love.graphics.printf("Prompt timer: " .. tostring(self.promptTimer), 200, 200, 200)
    -- love.graphics.printf("Prompt marker: " .. tostring(self.promptMarker), 200, 300, 200)
    -- love.graphics.printf("Current prompt: " .. tostring(self.currentPrompt), 200, 400, 200)
    -- love.graphics.printf("Current state: " .. tostring(self.battleState), 200, 500, 200)

    -- If the battle stat is end, prints the end message (indicating victory or defeat)
    if self.battleState == "end" then
        love.graphics.setFont(large)

        -- In case of player victory
        if self.winner == "player" then
            love.graphics.printf("Mongol Victory", 500, 300, 400)
            love.graphics.printf("You have routed the enemy!", 400, 380, 600)

        -- In case of computer victory
        else 
            love.graphics.printf("Chinese Victory", 500, 300, 400)
            love.graphics.printf("Your forces flee the battlefield!", 400, 380, 600)
        end

        -- Prınts instruction
        love.graphics.printf("Press Enter to continue", 440, 600, 400)

    -- If the battle state is prompt, renders the current prompt
    elseif self.battleState == "prompt" then
        -- Prints the prompt if the player is currently being prompted
       love.graphics.printf(self.prompts[self.currentPrompt]["text"], promptX, promptY, 600)
       love.graphics.printf(self.prompts[self.currentPrompt]["choice1"], choicesX, choicesY, 200)
       love.graphics.printf(self.prompts[self.currentPrompt]["choice2"], choicesX + 280, choicesY, 200)
       love.graphics.printf(self.prompts[self.currentPrompt]["choice3"], choicesX + 560, choicesY, 200)
       love.graphics.rectangle("fill", WINDOW_WIDTH / 2 - 400, 650, self.promptTimer, 20)
    end
    
    love.graphics.setFont(medium)

    -- Displays the terrain information
    love.graphics.printf("Terrain: " .. tostring(self.terrain), 550, 40, 400)
    love.graphics.printf(terrainInfo[self.terrain], 400, 70, 500)

end

-- Simulates combat (called during the fight game state)
function Battle:simulateCombat(dt)

    -- The damage modifier applied while calculating net damage
    local DAMAGE_MODIFIER = 1.5

    -- Calculates net damage for each army
    playerNetDamage = DAMAGE_MODIFIER * (self.playerArmy.infSkirmish + self.playerArmy.cavSkirmish + self.playerArmy.arcSkirmish)
    computerNetDamage = DAMAGE_MODIFIER * (self.computerArmy.infSkirmish + self.computerArmy.arcSkirmish)

    -- Removes the contribution of retreating units
    if self.infRetreating then
        playerNetDamage = playerNetDamage - DAMAGE_MODIFIER * self.playerArmy.infSkirmish
    elseif self.cavRetreating then
        playerNetDamage = playerNetDamage - DAMAGE_MODIFIER * self.playerArmy.cavSkirmish
    elseif self.arcRetreating then
        playerNetDamage = playerNetDamage - DAMAGE_MODIFIER * self.playerArmy.arcSkirmish
    end

    -- If it is the initial phases of the battle, adds specific bonuses
    if self.battleTimer > 1000 then
        -- Realistic bonuses relevant to things like whether archers have ranged attack available (enough arrows) or whether
        -- the cavalry is at a position to charge the enemy (likely to be the case near the start of the battle) are added
        playerNetDamage = playerNetDamage + (self.playerArmy.cavCharge + self.playerArmy.arcRanged) * 0.5
        computerNetDamage = computerNetDamage + (self.computerArmy.cavCharge + self.computerArmy.arcRanged) * 0.5
    end
    


    -- Deals damage to units (the infantry absorbs the bulk of the total damage dealt)
    -- Caps unit counts at 0
    -- Does not deal damage to retreating units (for the player)

    -- Deals damage to the player's units
    if self.infRetreating == false then
        local infantryBrace = self.infBracing and 0.5 or 1
        self.playerArmy.infCount = math.max(self.playerArmy.infCount - computerNetDamage * 0.8 * dt * infantryBrace, 0) 
    end
    if self.cavRetreating == false then
        self.playerArmy.cavCount = math.max(self.playerArmy.cavCount - computerNetDamage * 0.4 * dt, 0)
    end
    if self.arcRetreating == false then
        self.playerArmy.arcCount = math.max(self.playerArmy.arcCount - computerNetDamage * 0.3 * dt, 0)
    end

    -- Deals damage to the computer's units
    self.computerArmy.infCount = math.max(self.computerArmy.infCount - playerNetDamage * 0.9 * dt, 0)
    self.computerArmy.arcCount = math.max(self.computerArmy.arcCount - playerNetDamage * 0.45 * dt, 0)
    
    -- Calculates current morale for each army (subtracts 30 and 20 respectively to cover the 10s that were added while calculating MPU's earlier)
    -- Caps morales at 0
    self.playerArmy.morale = math.max(0, self.playerArmy.infCount * playerMPU["infantry"] + self.playerArmy.cavCount * playerMPU["cavalry"] + self.playerArmy.arcCount * playerMPU["archers"] - 30)
    self.computerArmy.morale = math.max(0, self.computerArmy.infCount * computerMPU["infantry"] + self.computerArmy.arcCount * computerMPU["archers"] - 20)

end

-- Processes a choice made by the player
function Battle:processChoice(event, choice)

    -- Resets unit retreating/bracing properties
    self.infRetreating = false
    self.arcRetreating = false
    self.cavRetreating = false
    self.infBracing = false

    -- Simulates the outcomes of the choice
    -- If the player made a choice
    if event ~= "noChoice" then

        -- Initializes local variables for modifiers to allow easier access
        local playerInf = {
            ["charge"] = self.playerArmy.infCharge, 
            ["skirmish"] = self.playerArmy.infSkirmish 
        }
        local playerArc = {
            ["ranged"] = self.playerArmy.arcRanged, 
            ["skirmish"] = self.playerArmy.arcSkirmish, 
        }
        local playerCav = {
            ["charge"] = self.playerArmy.cavCharge, 
            ["skirmish"] = self.playerArmy.cavSkirmish
        }
        local computerInf = {
            ["charge"] = self.computerArmy.infCharge, 
            ["skirmish"] = self.computerArmy.infSkirmish 
        }
        local computerArc = {
            ["ranged"] = self.computerArmy.arcRanged, 
            ["skirmish"] = self.computerArmy.arcSkirmish 
        }

        -- Caps all unit numbers to 0
        -- Deals damage / sets retreating or bracing properties to true based on the event
        if event == "volley" then
            self.computerArmy.infCount = math.max(math.floor(self.computerArmy.infCount - 3 * playerArc["ranged"] * (3 + math.random(3))), 0)
            self.computerArmy.arcCount = math.max(math.floor(self.computerArmy.arcCount - 1 * playerArc["ranged"] * (3 + math.random(3))), 0)

        elseif event == "cavChargeInf" then 
            self.computerArmy.infCount = math.max(math.floor(self.computerArmy.infCount - 4 * playerCav["charge"] * (3 + math.random(3))), 0)
            self.playerArmy.cavCount = math.max(math.floor(self.playerArmy.cavCount - 3 * computerInf["skirmish"] * (3 + math.random(3))), 0)

        elseif event == "march" then 
            self.computerArmy.infCount = math.max(math.floor(self.computerArmy.infCount - 2 * playerInf["skirmish"] * (3 + math.random(3))), 0)
            self.computerArmy.infCount = math.max(math.floor(self.computerArmy.infCount - 1 * playerCav["skirmish"] * (3 + math.random(3))), 0)

        elseif event == "arcRet" then 
            self.arcRetreating = true
            
        elseif event == "infAttack" then 
            self.computerArmy.infCount = math.max(math.floor(self.computerArmy.infCount - 5 * playerInf["skirmish"] * (3 + math.random(3))), 0)
            self.computerArmy.arcCount = math.max(math.floor(self.computerArmy.infCount - 1 * playerInf["skirmish"] * (3 + math.random(3))), 0)
            self.playerArmy.infCount = math.max(math.floor(self.playerArmy.infCount - 1 * computerInf["skirmish"] * (3 + math.random(3))), 0)
            self.playerArmy.infCount = math.max(math.floor(self.playerArmy.infCount - 0.5 * computerArc["ranged"] * (3 + math.random(3))), 0)
            
        elseif event == "infRet" then 
            self.infRetreating = true

        elseif event == "cavFlank" then 
            self.computerArmy.infCount = math.max(math.floor(self.computerArmy.infCount - 6 * playerCav["charge"] * (3 + math.random(3))), 0)
            self.playerArmy.cavCount = math.max(math.floor(self.playerArmy.cavCount - 1 * computerInf["skirmish"] * (3 + math.random(3))), 0)

        elseif event == "cavRet" then 
            self.cavRetreating = true

        elseif event == "cavChargeArc" then 
            self.computerArmy.arcCount = math.max(math.floor(self.computerArmy.arcCount - 5 * playerCav["charge"] * (3 + math.random(3))), 0)
            self.playerArmy.cavCount = math.max(math.floor(self.playerArmy.cavCount - 3 * computerArc["skirmish"] * (3 + math.random(3))), 0)

        elseif event == "brace" then 
            self.infBracing = true

        elseif event == "infCharge" then 
            self.computerArmy.infCount = math.max(math.floor(self.computerArmy.infCount - 5 * playerInf["charge"] * (3 + math.random(3))), 0)
            self.playerArmy.infCount = math.max(math.floor(self.playerArmy.infCount - 1 * computerInf["charge"] * (3 + math.random(3))), 0)

        elseif event == "cavAttackInf" then
            self.computerArmy.infCount = math.max(math.floor(self.computerArmy.infCount - 4 * playerCav["skirmish"] * (3 + math.random(3))), 0)
            self.playerArmy.cavCount = math.max(math.floor(self.playerArmy.cavCount - 2 * computerInf["skirmish"] * (3 + math.random(3))), 0)

        end

    -- If event is "noChoice" (i.e the user didn't pick a choice) then deals damage to the player's army
    else
        self.playerArmy.infCount = math.max(math.floor(self.playerArmy.cavCount - 1 * computerInf["skirmish"] * (2 + math.random(3))), 0)
        self.playerArmy.arcCount = math.max(math.floor(self.playerArmy.cavCount - 1 * computerInf["skirmish"] * (2 + math.random(3))), 0)
        self.playerArmy.cavCount = math.max(math.floor(self.playerArmy.cavCount - 1 * computerInf["skirmish"] * (2 + math.random(3))), 0)
        
    end

    -- Sets currentPrompt to the next prompt (that the current choice leads to,) and resets the prompt timer
    self.currentPrompt = self.prompts[self.currentPrompt]["next" .. choice]
    self.promptTimer = PROMPT_TIME

end