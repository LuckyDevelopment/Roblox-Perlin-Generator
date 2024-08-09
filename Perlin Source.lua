-- Written by @LxckyDev, 8/8/2024

local Perlin = {}
local PerlinBlock = script.PerlinBlock

local MapSize = 100
local TerrainParts = workspace.TerrainParts
local Colors = {
    [0.8] = Color3.fromRGB(255, 255, 255), -- Mountain Crests
    [0.75] = Color3.fromRGB(66, 66, 66), -- Dark Rock
    [0.7] = Color3.fromRGB(88, 88, 88), -- Rock
    [0.5] = Color3.fromRGB(44, 93, 40), -- Dark Grass
    [0.3] = Color3.fromRGB(52, 111, 48), -- Grass
    [0.25] = Color3.fromRGB(110, 168, 255), -- Foamy Edges
    [0.10] = Color3.fromRGB(70, 130, 214), -- Ocean
    [0] = Color3.fromRGB(48, 89, 149), -- Deep Ocean
}


local function GetColor(y : number) : Color3
    local closetKey = -1

    -- Loop through colors and find the one that it is greater than but also less than the next one.
    for key, color in pairs(Colors) do
        if y >= key then
            if key > closetKey then
                closetKey = key
            end
        end
    end

    return Colors[closetKey]
end

local function InverseLerp(value : number, start : number, endingValue : number) : number
    return (value - start) / (endingValue - start)
end

local function SmoothNumber(baseY : number, threshold : number) : number
    if baseY <= threshold then
        return 0
    else
        local lerpedValue = InverseLerp(baseY, threshold, 1)
        return lerpedValue
    end
end

function Perlin.Generate(Scale : number, Frequency : number, Amplitude : number, ChunkSize : number, SmoothingFactor : number, Seed : number)
    -- Remove all previous blocks.
    for _, object in pairs(TerrainParts:GetChildren()) do
        object:Destroy()
    end

    -- Generate random offsets.
    local random = Random.new(Seed)
    local xOffset = random:NextNumber(-100000, 100000)
    local zOffset = random:NextNumber(-100000, 100000)

    -- Loop through each chunk.
    for x = 0, MapSize do
        for z = 0, MapSize do
            -- Change sizes of sample X and Z.
            local sampleX = x / Scale * Frequency + xOffset
            local sampleZ = z / Scale * Frequency + zOffset

            -- Generate the perlin noise?!?!
            local baseY = math.clamp((math.noise(sampleX, sampleZ) + 0.5), 0, 1)
            local preservedBaseY = baseY
            
            baseY = SmoothNumber(baseY, SmoothingFactor)
            
            local y = baseY * Amplitude

            -- Get the correct CFrame.
            local BlockCFrame = CFrame.new(x * ChunkSize, y * ChunkSize, z * ChunkSize)

            -- Create a new part for the terrain.
            local clone = PerlinBlock:Clone()
            clone.CFrame = BlockCFrame
            clone.Color = GetColor(preservedBaseY)
            clone.Size = Vector3.new(ChunkSize, y * (ChunkSize + 1) + 1, ChunkSize)
            clone.Parent = TerrainParts   

        end
        task.wait()
    end
end

return Perlin
