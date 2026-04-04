-- scripts/seed-lint.lua
-- Lightweight policy linter for Horror.Place Seed contracts.
-- Enforces cross-field constraints that are awkward to express in JSON Schema:
--   - metric_targets.ARR_min <= metric_targets.ARR_max
--   - deadledger_ref must be non-null when intensity_band >= 8
--
-- Usage:
--   lua scripts/seed-lint.lua path/to/seed1.json path/to/seed2.json ...
--
-- Exit codes:
--   0: all files passed
--   1: one or more files failed lint rules or could not be parsed

local json_ok, json = pcall(require, "dkjson")
if not json_ok then
  io.stderr:write("[seed-lint] error: dkjson Lua module not found. Install dkjson or adjust require.\n")
  os.exit(1)
end

local function read_file(path)
  local f, err = io.open(path, "r")
  if not f then
    return nil, "cannot open file: " .. tostring(err)
  end
  local content = f:read("*a")
  f:close()
  if not content or content == "" then
    return nil, "file is empty"
  end
  return content, nil
end

local function decode_seed(json_str)
  local obj, pos, err = json.decode(json_str, 1, nil)
  if err then
    return nil, "JSON decode error at position " .. tostring(pos) .. ": " .. tostring(err)
  end
  if type(obj) ~= "table" then
    return nil, "decoded root is not an object"
  end
  return obj, nil
end

local function safe_number(v)
  if type(v) == "number" then
    return v
  end
  return nil
end

local function lint_arr_bounds(seed)
  local mt = seed.metric_targets
  if type(mt) ~= "table" then
    return false, "metric_targets missing or not an object"
  end

  local arr_min = safe_number(mt.ARR_min)
  local arr_max = safe_number(mt.ARR_max)

  if not arr_min then
    return false, "metric_targets.ARR_min missing or not a number"
  end
  if not arr_max then
    return false, "metric_targets.ARR_max missing or not a number"
  end
  if arr_min < 0.0 or arr_min > 1.0 then
    return false, string.format("metric_targets.ARR_min out of range [0,1]: %.4f", arr_min)
  end
  if arr_max < 0.0 or arr_max > 1.0 then
    return false, string.format("metric_targets.ARR_max out of range [0,1]: %.4f", arr_max)
  end
  if arr_min > arr_max then
    return false, string.format("metric_targets.ARR_min (%.4f) > ARR_max (%.4f)", arr_min, arr_max)
  end

  return true, nil
end

local function lint_deadledger_policy(seed)
  local ib = safe_number(seed.intensity_band)
  if not ib then
    return false, "intensity_band missing or not a number"
  end

  local dl = seed.deadledger_ref
  if ib >= 8 then
    if dl == nil then
      return false, "intensity_band >= 8 requires deadledger_ref to be non-null"
    end
    if type(dl) ~= "string" or dl == "" then
      return false, "deadledger_ref must be a non-empty string when intensity_band >= 8"
    end
  end

  return true, nil
end

local function lint_seed(seed)
  local ok, err = lint_arr_bounds(seed)
  if not ok then
    return false, err
  end

  ok, err = lint_deadledger_policy(seed)
  if not ok then
    return false, err
  end

  return true, nil
end

local function main(args)
  if #args == 0 then
    io.stderr:write("Usage: lua scripts/seed-lint.lua path/to/seed1.json [seed2.json ...]\n")
    return 1
  end

  local failed = false

  for _, path in ipairs(args) do
    local content, rerr = read_file(path)
    if not content then
      io.stderr:write(string.format("[seed-lint] %s: %s\n", path, rerr))
      failed = true
    else
      local seed, derr = decode_seed(content)
      if not seed then
        io.stderr:write(string.format("[seed-lint] %s: %s\n", path, derr))
        failed = true
      else
        local ok, lerr = lint_seed(seed)
        if not ok then
          io.stderr:write(string.format("[seed-lint] %s: %s\n", path, lerr))
          failed = true
        else
          io.stdout:write(string.format("[seed-lint] %s: OK\n", path))
        end
      end
    end
  end

  if failed then
    return 1
  end
  return 0
end

local exit_code = main(arg or {})
os.exit(exit_code)
