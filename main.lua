-- Sets the image filter and line style so the graphics aren't blurry
love.graphics.setDefaultFilter ("nearest", "nearest")
love.graphics.setLineStyle ("smooth")

-- Declares the local variables
local map = {}
local mapSize = 32

local tileImage = love.graphics.newImage ("tileImage.png")
local tileW = 32
local tileH = 16

local mouseX, mouseY
local mapX, mapY = -1, -1

local heightMult = 8
local maxHeight = 9
local minHeight = 0
local belowOffset = math.ceil (maxHeight / (tileH / heightMult))
local aboveOffset = math.floor (minHeight / (tileH / heightMult))


function love.load ()
    -- Initializes the map table with a bunch of tiles with heights of 0
    for i = 1, mapSize do
        map[i] = {}
        for j = 1, mapSize do
            map[i][j] = 0
        end
    end
end


function love.update (dt)
	-- Gets the mouse position and translates it into a map position
    mouseX, mouseY = love.mouse.getPosition ()

     -- The 2D map position that the mouse cursor is over
    local origX = math.floor (mouseY / tileH + (mouseX - tileH) / tileW)
    local origY = math.floor (mouseY / tileH - (mouseX - tileH) / tileW)

    -- The next tile that the algorithm should check. It starts at the lowest possible position within the diagonal strips
    local nextX = origX + belowOffset
    local nextY = origY + belowOffset

    -- The last possible tile the algorithm should check. It ends at the highest possible position within the diagonal strips
    local targetX = origX + aboveOffset
    local targetY = origY + aboveOffset

    local hit = false

    -- Used to determine the next value of nextX and nextY
    -- It's based on the current map position and which half of the current map position the mouse is hovering over
    local moveEast = ((mouseX % tileW) > (tileW / 2)) ~= (nextX % 2 == 1) ~= (nextY % 2 == 1)

    -- Loops until the correct tile is "hit" or until it surpasses the target tile
    while hit == false and nextX >= targetX and nextY >= targetY do
        -- Used to offset mouseY so we can calculate the predicted position
        local tempY = 0
        
        -- Ensures that we don't reference the map table when the current position is out of bounds
        if (nextX >= 1 and nextX <= mapSize) and (nextY >= 1 and nextY <= mapSize) then
            tempY = mouseY + map[nextX][nextY] * heightMult
        end

        -- Translates the mouse position (with the offset mouseY value) into a 2D map position
        local predictedX = math.floor (tempY / tileH + (mouseX - tileH) / tileW)
        local predictedY = math.floor (tempY / tileH - (mouseX - tileH) / tileW)

        -- Checks if the correct tile was hit
        if predictedX == nextX and predictedY == nextY then
            hit = true
            mapX = predictedX
            mapY = predictedY

        else
            -- Finds the next tile's coordinates
            if moveEast == false then
                nextX = nextX - 1 -- Choose north (right) tile
                moveEast = not moveEast
            else
                nextY = nextY - 1 -- Choose west (left) tile
                moveEast = not moveEast
            end
        end
    end

    -- If a tile was never found, we can assume the mouse was out of bounds and set a default value
    if hit == false then
        mapX = -1
        mapY = -1
    end
end


function love.draw ()
    for i = 1, mapSize do
        for j = 1, mapSize do
            local screenX = (i - j) * (tileW / 2) -- Formula for the screen's x position
            local screenY = (i + j) * (tileH / 2) - map[i][j] * heightMult -- Formula for the screen's y position
            love.graphics.draw (tileImage, screenX, screenY) -- Renders the tile's image
        end
    end

    love.graphics.setColor (1, 1, 1, 1)
    love.graphics.print ("Mouse Coords: " .. mouseX .. ", " .. mouseY, 650, 20)
    love.graphics.print ("3D Map Coords: " .. mapX .. ", " .. mapY, 650, 40)
    love.graphics.print ("2D Map Coords: " .. math.floor (mouseY / tileH + (mouseX - tileH) / tileW) .. ", " .. math.floor (mouseY / tileH - (mouseX - tileH) / tileW), 650, 60)
end


function love.keypressed (key)
    -- Resets the map
    if key == "r" then
        for i = 1, mapSize do
            map[i] = {}
            for j = 1, mapSize do
                map[i][j] = 0
            end
        end
    end
end


function love.mousepressed (x, y, button, istouch, presses)
    -- Ensures that the map coordinates are in bounds
    if mapX ~= -1 and mapY ~= -1 then
        -- Raises tile height when LMB is pressed
        if button == 1 and map[mapX][mapY] < maxHeight then
            map[mapX][mapY] = map[mapX][mapY] + 1

        -- Lower tile height when RMB is pressed
        elseif button == 2 and map[mapX][mapY] > minHeight then
            map[mapX][mapY] = map[mapX][mapY] - 1
        end
    end
end