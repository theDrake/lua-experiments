-- class.lua
-- Compatible with Lua 5.1 (not 5.0).

function class(base, init)
  local c = {}  -- New class instance.
  if not init and type(base) == 'function' then
    init = base
    base = nil
  elseif type(base) == 'table' then
    -- New class is a shallow copy of the base class:
    for i, v in pairs(base) do
      c[i] = v
    end
    c._base = base
  end
  c.__index = c  -- The class will be a metatable of methods for its objects.

  -- Constructor: <classname>(<args>)
  local mt = {}
  mt.__call = function(class_tbl, ...)
    local obj = {}
    setmetatable(obj, c)
    if init then
      init(obj,...)
    else
      -- Ensure any stuff from the base class is initialized:
      if base and base.init then
        base.init(obj, ...)
      end
    end
    return obj
  end
  c.init = init
  c.is_a = function(self, klass)
    local m = getmetatable(self)
    while m do
      if m == klass then return true end
      m = m._base
    end
    return false
  end
  setmetatable(c, mt)
  return c
end
