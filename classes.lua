local P = {}

local setmetatable = setmetatable

if setenv then
  setfenv(1, P)
else
  --noinspection GlobalCreationOutsideO
  _ENV = P
end

-------------------------------------------------------------------------------

function inheritsFrom(baseClass)

  local newClass = {}
  local class_mt = { __index = newClass }

  function newClass:_create()
    if self ~= newClass then
      return nil, "First argument must be self"
    end

    local newInst = {}
    setmetatable(newInst, class_mt)
    return newInst
  end

  if nil ~= baseClass then
    setmetatable(newClass, { __index = baseClass })
  end

  function newClass:class()
    return newClass
  end

  function newClass:superClass()
    return baseClass
  end

  function newClass:isA(theClass)
    local _isA = false
    local currentClass = newClass
    while (nil ~= currentClass) and (not _isA) do
      if currentClass == theClass then
        _isA = true
      else
        currentClass = currentClass:superClass()
      end
    end

    return _isA
  end

  return newClass
end

P.inheritsFrom = inheritsFrom

return P