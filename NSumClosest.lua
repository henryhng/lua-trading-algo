--[[
    -= Accurate Search =-
        For n = 1:
            Time complexity = O[1]
        For n = 2:
            Time complexity = O[2]
        For n > 2:
            Time complexity = O[N^n]

            The time complexity for n > 2 can be reduced by n - 1 for O[N^n] time complexity using pointers, however n > 2 is written with a bruteforce method and is slower than if calculated with pointers.

    -= Quick Search =-
        Time complexity = O(n)
    
        May not be as accurate.
]]

local NSumClosestLib = {}

--// Generate case
function generateCase()
    local arr = {}
    local maxArrValue = 20
    local arrcount = math.random(3, 7) + 1
    for i = 1, arrcount do
        table.insert(arr, math.random(maxArrValue))
    end
    local n = math.random(2, arrcount - 1)
    local target = math.random(arrcount * maxArrValue)
    return arr, n, target
end

--// Checks if it maxed out
local function isMaxed(indexes, index1, arrLength)
    local max1 = indexes[#indexes]
    local min1 = indexes[index1]
    local n = #indexes - index1 + 1 --number of elements

    return max1 - min1 + 1 == n and max1 == arrLength
end

--// Reset indexes
local function resetIndexes(indexes, startIndexReset)
    local res = {}
    for i = indexes[startIndexReset], indexes[startIndexReset] + #indexes - 1 do
        table.insert(res, i)
    end
    
    return res
end

--// Calculate sum
local function getSum(arr, indexes)
    print("sum inputs")
    local sum = 0
    local res = {}
    for position, index in ipairs(indexes) do
        sum = sum + arr[index]["rolimonsValue"]
        table.insert(res, arr[index])
    end
    return sum, res
end


return NSumClosestLib
