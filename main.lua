-- The properties of the game window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- The reveal speed for texts that are not instantly shown but revealed
REVEAL_SPEED = 2

Class = require "class"

require "Army"
-- Battle requires army
require "Battle"

function love.load()

    -- Sets the title of the window
    love.window.setTitle("Khan")

    -- Loads the music file
    music = love.audio.newSource("music.mp3", "static")

    -- Loads the click sound effect file
    click = love.audio.newSource("click.wav", "static")
    click:setVolume(0.25)

    -- Starts background music
    music:setVolume(0.25)
    music:setLooping(true)
    music:play()

    -- Seeds the random number generator
    math.randomseed(os.time())

    -- Stores the map image
    mapImage = love.graphics.newImage("map.png")

    -- The variable keeping track of the game state
    gameState = "splash"

    -- The variable used to add a "reveal" effect to text
    revealAlpha = 0

    -- The id of the next text in the intro that will be revealed
    introNext = 1

    -- The next battle that will be played
    nextBattle = 1

    -- The fonts that will be used throughout the game
    small = love.graphics.newFont("font.ttf", 12)
    medium = love.graphics.newFont("font.ttf", 20)
    large = love.graphics.newFont("font.ttf", 32)
    title = love.graphics.newFont("font.ttf", 80)

    -- Sets color to white
    love.graphics.setColor(1, 1, 1, 1)

    -- Sets window mode
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true,
    })

    -- The army object that represents the army controlled by the user
    playerArmy = Army(
    {["count"] = 200, ["charge"] = 1.5, ["skirmish"] = 2},
    {["count"] = 200, ["ranged"] = 3, ["skirmish"] = 1.5},
    {["count"] = 200, ["charge"] = 4, ["skirmish"] = 1.5},
    {["morale"] = 50},
    false)

    -- The army object that represents the army controlled by the AI player
    computerArmy = Army(
    {["count"] = 350, ["charge"] = 2, ["skirmish"] = 2.5},
    {["count"] = 250, ["ranged"] = 4, ["skirmish"] = 1},
    {["count"] = 0, ["charge"] = 0, ["skirmish"] = 0},
    {["morale"] = 50},
    true)

    -- The battle object that represents the current battle
    currentBattle = Battle(playerArmy, computerArmy, "Steppe")

    -- The keysPressed table that will be used to acces key pressing functionality in objects
    love.keyboard.keysPressed = {}

end

function love.keypressed(key)

    -- Clears keysPressed
    love.keyboard.keysPressed = {}

    -- Quits if escape is pressed
    if key == "escape" then
        love.event.quit()

    -- Enter is the primary state changing button throughout the game
    elseif key == "enter" or key == "return" then

        -- Plays click sound
        click:play()

        -- If game state is splash, switches to intro
        if gameState == "splash" then
            gameState = "intro"

        -- If game state is intro, sets revealAlpha to 0 and increments introNext until all introTexts (total 3) are revealed
        elseif gameState == "intro" then
            if (introNext < 3) then
                revealAlpha = 0
                introNext = introNext + 1
            else
            -- Once introNext is equal to 3, sets color to white and switches game state to map
                love.graphics.setColor(1, 1, 1, 1)
                gameState = "map"
            end

        elseif gameState == "map" then

            -- According to the next battle, adjusts the army objects and the battle object and starts the battle

            if nextBattle == 1 then
                -- Adjusts the playerArmy object
                playerArmy = Army(
                {["count"] = 180, ["charge"] = 1.5, ["skirmish"] = 2},
                {["count"] = 200, ["ranged"] = 3, ["skirmish"] = 1.5},
                {["count"] = 250, ["charge"] = 4, ["skirmish"] = 1.5},
                {["morale"] = 50},
                false)

                -- Adjusts the computerArmy object
                computerArmy = Army(
                {["count"] = 350, ["charge"] = 2, ["skirmish"] = 2.5},
                {["count"] = 250, ["ranged"] = 4, ["skirmish"] = 1},
                {["count"] = 0, ["charge"] = 0, ["skirmish"] = 0},
                {["morale"] = 50},
                true)

                -- Adjusts the currentBattle object
                currentBattle = Battle(playerArmy, computerArmy, "Steppe")

                -- Adjusts the game state to start the battle
                gameState = "battle"

            elseif nextBattle == 2 then

                -- Adjusts the playerArmy object
                playerArmy = Army(
                {["count"] = 180, ["charge"] = 1.5, ["skirmish"] = 2},
                {["count"] = 200, ["ranged"] = 3, ["skirmish"] = 1.5},
                {["count"] = 250, ["charge"] = 2, ["skirmish"] = 1.5},
                {["morale"] = 50},
                false)

                -- Adjusts the computerArmy object
                computerArmy = Army(
                {["count"] = 400, ["charge"] = 2, ["skirmish"] = 2.5},
                {["count"] = 300, ["ranged"] = 4, ["skirmish"] = 1},
                {["count"] = 0, ["charge"] = 0, ["skirmish"] = 0},
                {["morale"] = 55},
                true)

                 -- Adjusts the currentBattle object
                currentBattle = Battle(playerArmy, computerArmy, "Mountains")

                -- Adjusts the game state to start the battle
                gameState = "battle"

            elseif nextBattle == 3 then

                -- Adjusts the playerArmy object
                playerArmy = Army(
                {["count"] = 300, ["charge"] = 1.5, ["skirmish"] = 2},
                {["count"] = 225, ["ranged"] = 1.5, ["skirmish"] = 1.5},
                {["count"] = 250, ["charge"] = 2, ["skirmish"] = 0.5},
                {["morale"] = 50},
                false)

                -- Adjusts the computerArmy object
                computerArmy = Army(
                {["count"] = 425, ["charge"] = 2, ["skirmish"] = 2.5},
                {["count"] = 325, ["ranged"] = 4, ["skirmish"] = 1},
                {["count"] = 0, ["charge"] = 0, ["skirmish"] = 0},
                {["morale"] = 60},
                true)

                -- Adjusts the currentBattle object
                currentBattle = Battle(playerArmy, computerArmy, "Urban")

                -- Adjusts the game state to start the battle
                gameState = "battle"

            -- The nextBattle variable being 4 indicates that the player has completed the final battle and is restarting the game
            elseif nextBattle == 4 then

                -- Resets nextBattle
                nextBattle = 1

                -- Sets the game state to splash to render the splash screen and effectively restart the game
                gameState = "splash"

            end
        end
    end

    -- Adds key to keysPressed
    love.keyboard.keysPressed[key] = true

end

function love.update(dt)

    -- If game state is intro, increases revealAlpha unless all texts are already revealed
    if gameState == "intro" then
        if introNext < 4 then
            -- Increases the alpha for revealed text (caps at 1)
            revealAlpha = math.min(revealAlpha + REVEAL_SPEED * dt, 1)
        end

    -- If game state is battle, calls the update method of the currentBattle object
    elseif gameState == "battle" then
        currentBattle:update(dt)
    end

    -- Resets keysPressed before the frame is released
    love.keyboard.keysPressed = {}

end

function love.draw()

    -- Sets the background color
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    -- Renders graphics according to the current game state

    if gameState == "splash" then
        renderSplash()

    elseif gameState == "intro" then
        renderIntro(introNext)

    elseif gameState == "map" then
        renderMap()

    elseif gameState == "battle" then
        currentBattle:render(500, 500, 250, 550)

    end

end

-- Renders the splash screne graphics
function renderSplash()

    -- Prints title and instruction

    love.graphics.setFont(title)
    love.graphics.printf("KHAN", 0, WINDOW_HEIGHT / 2 - 100 , WINDOW_WIDTH, "center")

    love.graphics.setFont(large)
    love.graphics.printf("Press Enter to start", 0, WINDOW_HEIGHT / 2 + 40 , WINDOW_WIDTH, "center")
end

-- Renders the intro texts
function renderIntro(textNum)

    -- The intro texts
    texts = {
        "News have reached Karakorum. The Celestial Emperor has died in Beijing, the Chinese Empire's capital.",
        "Genghis Khan himself has commanded you to lead the Mongol armies through China and claim Beijing for the Mongol Empire.",
        "Your soldiers await your orders..."
    }

    -- Prints the current intro text based on the inputted textNum
    -- For higher textNums, reveals the previous texts immediately and the additional one using revealAlpha
    if textNum == 1 then
        love.graphics.setFont(large)
        love.graphics.setColor(1, 1, 1, revealAlpha)
        love.graphics.printf(texts[1], 0, 50, WINDOW_WIDTH, "center")

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press Enter to continue...", 0, 250, WINDOW_WIDTH, "center")

    elseif textNum == 2 then
        love.graphics.setFont(large)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(texts[1], 0, 50, WINDOW_WIDTH, "center")

        love.graphics.setColor(1, 1, 1, revealAlpha)
        love.graphics.printf(texts[2], 0, 220, WINDOW_WIDTH, "center")

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press Enter to continue...", 0, 420, WINDOW_WIDTH, "center")

    elseif textNum == 3 then
        love.graphics.setFont(large)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(texts[1], 0, 50, WINDOW_WIDTH, "center")
        love.graphics.printf(texts[2], 0, 220, WINDOW_WIDTH, "center")

        love.graphics.setColor(1, 1, 1, revealAlpha)
        love.graphics.printf(texts[3], 0, 390, WINDOW_WIDTH, "center")

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press Enter to continue...", 0, 600, WINDOW_WIDTH, "center")

    elseif textNum == 4 then
        love.graphics.setFont(large)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(texts[1], 0, 50, WINDOW_WIDTH, "center")
        love.graphics.printf(texts[2], 0, 220, WINDOW_WIDTH, "center")
        love.graphics.printf(texts[3], 0, 390, WINDOW_WIDTH, "center")
        love.graphics.printf("Press Enter to continue...", 0, 600, WINDOW_WIDTH, "center")
    end

end

-- Renders the game map, placing the player at the location of the next battle
function renderMap()

    -- Unless all battles are over, renders the game map
    if nextBattle < 4 then
        love.graphics.setColor(255 / 255, 210 / 255, 190 / 255, 1)
        love.graphics.draw(mapImage, 200, 20, 0, 1.2, 1.2)
        love.graphics.setFont(large)
    end

    -- Renders rectangles representing battle locations and using green (completed) or red (incomplete)
    -- Prints instruction at the bottom of the screen

    if nextBattle == 1 then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", 620, 320, 30, 30)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf("Gansu", 580, 370, WINDOW_WIDTH)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press Enter to start the next battle...", 0, 650, WINDOW_WIDTH, "center")
    elseif nextBattle == 2 then
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.rectangle("fill", 620, 320, 30, 30)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf("Gansu", 600, 380, WINDOW_WIDTH)
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", 730, 350, 30, 30)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf("Shanxi", 730, 400, WINDOW_WIDTH)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press Enter to start the next battle...", 0, 650, WINDOW_WIDTH, "center")
    elseif nextBattle == 3 then
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.rectangle("fill", 620, 320, 30, 30)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf("Gansu", 600, 380, WINDOW_WIDTH)
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.rectangle("fill", 730, 350, 30, 30)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf("Shanxi", 730, 400, WINDOW_WIDTH)
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", 785, 290, 30, 30)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf("Beijing", 785, 250, WINDOW_WIDTH)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press Enter to start the next battle...", 0, 650, WINDOW_WIDTH, "center")

    -- If next battle is 4, that indicates that the player has won all battles, so the end message is displayed
    elseif nextBattle == 4 then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(large)
        love.graphics.printf("You have prevailed against the Empire of China and her armies!", 0, 150, WINDOW_WIDTH, "center")
        love.graphics.printf("The annals of history will recount your tactical ingenuity and decisive leadership.", 0, 300, WINDOW_WIDTH, "center")
        -- The instruction to print enter if the player wishes to restart the game is printed at the bottom of the screen
        love.graphics.printf("Press Enter to restart the game...", 0, 650, WINDOW_WIDTH, "center")
    end

end

-- A global function used to keep track of keys that were pressed (used in class methods)
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end
