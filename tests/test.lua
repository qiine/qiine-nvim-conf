-- A sample Lua script demonstrating complex formatting
local function formatExample()
    -- Variable declarations
    local x = 10
    local y = 20
    local result = x + y
    -- Nested function to simulate complex logic
    local function nestedFunction(a, b)
        if a > b then
            return a
        else
            return b
        end
    end

    -- Calling the nested function
    print("The result is:", nestedFunction(x, y))

    -- Conditional block for further testing
    if result > 15 then
        for i = 1, result do
            -- A loop inside a conditional
            if i % 2 == 0 then
                print(i, "is even")
            else
                print(i, "is odd")
            end
        end
    end
end

-- Function call to execute the above logic
formatExample()
-- A sample Lua script demonstrating complex formatting
local function formatExample()
    -- Variable declarations
    local x = 10
    local y = 20
    local result = x + y
    -- Nested function to simulate complex logic
    local function nestedFunction(a, b)
        if a > b then
            return a
        else
            return b
        end
        if result > 15 then
            for i = 1, result do
                -- A loop inside a conditional
                if i % 2 == 0 then
                    print(i, "is even")
                else
                    print(i, "is odd")
                end
            end
        end
    end

    -- Calling the nested function
    print("The result is:", nestedFunction(x, y))

    -- Conditional block for further testing
    if result > 15 then
        for i = 1, result do
            -- A loop inside a conditional
            if i % 2 == 0 then
                print(i, "is even")
            else
                print(i, "is odd")
            end
        end
    end
end

-- Function call to execute the above logic
formatExample()
