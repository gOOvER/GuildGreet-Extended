-- Test file to verify CI pipeline
-- This file tests that our GitHub Actions workflow correctly handles:
-- 1. Lua syntax checking
-- 2. Warning vs Error detection
-- 3. WoW addon specific patterns

local function test_ci_functionality()
    -- This should generate some warnings but no errors
    local unused_var = "test"  -- W211: unused variable (warning only)
    
    -- WoW API calls that might be undefined (should be ignored)
    local guild_name = GetGuildName()  -- Should be ignored due to read_globals
    
    return true
end

-- Global for testing
GLDG_CI_TEST = test_ci_functionality