-- cmdline.lua

local ipairs, pairs, setfenv, tonumber, loadstring, type =
  ipairs, pairs, setfenv, tonumber, loadstring, type
local tinsert, tconcat = table.insert, table.concat
module(...)

local function commonerror(msg)
  return nil, ("[cmdline]: " .. msg)
end

local function argerror(msg, numarg)
  msg = msg and (": " .. msg) or ""
  return nil, ("[cmdline]: bad argument #" .. numarg .. msg)
end

local function iderror (numarg)
  return argerror("ID not valid", numarg)
end

local function idcheck (id)
  return id:match("^[%a_][%w_]*$") and true
end

function getparam(t_in, options, params)
  local t_out = {}
  for i, v in ipairs(t_in) do
    local prefix, command = v:sub(1,1), v:sub(2)
    if prefix == "$" then
      tinsert(t_out, command)
    elseif prefix == "-" then
      for id in command:gmatch"[^,;]+" do
        if not idcheck(id) then return iderror(i) end
        t_out[id] = true
      end
    elseif prefix == "!" then
      local f, err = loadstring(command)
      if not f then return argerror(err, i) end
      setfenv(f, t_out)()
    elseif v:find("=") then
      local ids, val = v:match("^([^=]+)%=(.*)")  -- no space around =
      if not ids then return argerror("invalid assignment syntax", i) end
      val = val:sub(1, 1) == "$" and val:sub(2) or tonumber(val) or val
      for id in ids:gmatch"[^,;]+" do
        if not idcheck(id) then return iderror(i) end
        t_out[id] = val
      end
    else
      tinsert(t_out, v)
    end
  end
  if options then
    local lookup, unknown = {}, {}
    for _, v in ipairs(options) do lookup[v] = true end
    for k, _ in pairs(t_out) do
      if lookup[k] == nil and type(k) == "string" then tinsert(unknown, k) end
    end
    if #unknown > 0 then
      return commonerror("unknown options: " .. tconcat(unknown, ", "))
    end
  end
  if params then
    local missing = {}
    for _, v in ipairs(params) do
      if t_out[v] == nil then tinsert(missing, v) end
    end
    if #missing > 0 then
      return commonerror("missing parameters: " .. tconcat(missing, ", "))
    end
  end
  return t_out
end
