#!/usr/bin/env lua
-- scripts/runstylelint.lua
--
-- Command-line entrypoint for the Horror$Place Style Linter.
-- Takes a path to a style contract file (JSON or potentially a DSL output converted to JSON),
-- parses it, and runs it through the linting logic in stylelint.lua.
-- Designed for use in CI/CD pipelines or as a pre-commit hook.

local linter = require("scripts.stylelint") -- Import the linter module
local json = require("dkjson") -- Assuming a JSON parsing library

-- --- Argument Parsing ---
local args = {...}
if #args ~= 1 then
    print("Usage: lua runstylelint.lua <path_to_style_contract.json>")
    os.exit(1)
end

local file_path = args[1]
print("Loading style contract from: " .. file_path)

-- --- File Loading and Parsing ---
local file_handle = io.open(file_path, "r")
if not file_handle then
    print("ERROR: Could not open file: " .. file_path)
    os.exit(1)
end

local file_content = file_handle:read("*a")
file_handle:close()

local parsed_contract, _, parse_error = json.decode(file_content)
if not parsed_contract then
    print("ERROR: Failed to parse JSON: " .. (parse_error or "Unknown error"))
    os.exit(1)
end

-- --- Linting Execution ---
local success, message = linter.lint_style_contract(parsed_contract)

-- --- Exit Code ---
if success then
    print("\nOverall Result: Style Contract PASSED linting.")
    os.exit(0)
else
    print("\nOverall Result: Style Contract FAILED linting.")
    print("Details: " .. message)
    os.exit(1) -- Non-zero exit code indicates failure for CI/CD
end

-- Example command line usage (from project root):
-- lua scripts/runstylelint.lua path/to/my_style_contract.json
