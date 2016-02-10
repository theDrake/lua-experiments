--[[
  binsearch.lua

  binsearch(table, value [, compval [, reversed]])

  Searches a sorted table for a given value via binary search. If successful,
  a table holding matching indices is returned. Otherwise, nil.
]]--

do
  local default_fcompval = function(value) return value end
  local fcompf = function(a, b) return a < b end
  local fcompr = function(a, b) return a > b end
  function table.binsearch(t, value, fcompval, reversed)
    local fcompval = fcompval or default_fcompval
    local fcomp = reversed and fcompr or fcompf
    local iStart, iEnd, iMid = 1, #t, 0
    while iStart <= iEnd do
      iMid = math.floor((iStart + iEnd) / 2)
      local value2 = fcompval(t[iMid])
      if value == value2 then
        local tfound, num = {iMid, iMid}, iMid - 1
        while value == fcompval(t[num]) do
          tfound[1], num = num, num - 1
        end
        num = iMid + 1
        while value == fcompval(t[num]) do
          tfound[2], num = num, num + 1
        end
        return tfound
      elseif fcomp(value, value2) then
        iEnd = iMid - 1
      else
        iStart = iMid + 1
      end
    end
  end
end
