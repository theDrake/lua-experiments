-- Returns the length of a given file.
function length_of_file(filename)
  local fh = assert(io.open(filename, "rb"))
  local len = assert(fh:seek("end"))
  fh:close()
  return len
end

-- Returns true if file exists and is readable.
function file_exists(path)
  local file = io.open(path, "rb")
  if file then file:close() end
  return file ~= nil
end

-- Same as file:seek, except it throws a string on error. Requires Lua 5.1.
function seek(fh, ...)
  assert(fh:seek(...))
end
