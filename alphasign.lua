local P = {}
--[[
if _REQUIREDNAME == nil then
  alphasign = P
else
  _G[_REQUIREDNAME] = P
end
--]]

local string = string
local setmetatable = setmetatable
local getmetatable = getmetatable
local table = table
local classes = require("classes")
local uart = uart

local tostring = tostring
local print = print
local ipairs = ipairs

if setenv then
  setfenv(1, P)
else
  --noinspection GlobalCreationOutsideO
  _ENV = P
end

-------------------------------------------------------------------------------

local Types = {
  ALL_WITH_VISUAL_VERIFICATION     = "!",
  SERIAL_CLOCK                     = '"',
  ALPHA_VISION                     = "#",
  FULL_MATRIX_ALPHAVISION          = "$",
  CHARACTER_MATRIX_ALPHAVISION     = "%",
  LINE_MATRIX_ALPHAVISION          = "&",
  RESPONSE                         = "0",
  ONE_LINE                         = "1",
  TWO_LINE                         = "2",
  ALL_                             = "?",
  _430I                            = "C",
  _440I                            = "D",
  _460I                            = "E",
  ALPHAECLIPSE_3600_DISPLAY_DRIVER = "F",
  ALPHAECLIPSE_3600_TURBO_ADAPTER  = "G",
  LIGHT_SENSOR                     = "L",
  _790I                            = "U",
  ALPHAECLIPSE_3600                = "V",
  ALPHAECKIPSE_TIME_TEMP           = "W",
  ALPHAPREMIERE_4000_9000          = "X",
  ALL                              = "Z",
  BETABRIGHT                       = "^",
  _4120C                           = "a",
  _4160C                           = "b",
  _4200C                           = "c",
  _4240C                           = "d",
  _215R                            = "e",
  _215C                            = "f",
  _4120R                           = "g",
  _4160R                           = "h",
  _4200R                           = "i",
  _4240R                           = "j",
  _300                             = "k",
  _7000                            = "l",
  MATRIX_SOLAR_96X16               = "m",
  MATRIX_SOLAR_128X16              = "n",
  MATRIX_SOLAR_160X16              = "o",
  MATRIX_SOLAR_192X16              = "p",
  PPS                              = "q",
  DIRECTOR                         = "r",
  _1005                            = "s",
  _4080C                           = "t",
  _210C_220C                       = "u",
  ALPHAECLIPSE_3500                = "v",
  ALPHAECLIPSE_1500_TIME_TEMP      = "w",
  TEMPERATURE_PROBE                = "y",
  ALL_WITH_26_MEMORY_FILES         = "z"
}
P.Types = Types

local Commands = {
  WRITE_TEXT            = "A",  -- Write TEXT file (p18)
  READ_TEXT             = "B",  -- Read TEXT file (p19)
  WRITE_SPECIAL         = "E",  -- Write SPECIAL FUNCTION commands (p21)
  READ_SPECIAL          = "F",  -- Read SPECIAL FUNCTION commands (p29)
  WRITE_STRING          = "G",  -- Write STRING (p37)
  READ_STRING           = "H",  -- Read STRING (p38)
  WRITE_SMALL_DOTS      = "I",  -- Write SMALL DOTS PICTURE file (p39)
  READ_SMALL_DOTS       = "J",  -- Read SMALL DOTS PICTURE file (p41)
  WRITE_RGB_DOTS        = "K",  -- Write RGB DOTS PICTURE file (p44)
  READ_RGB_DOTS         = "L",  -- Read RGB DOTS PICTURE file (p46)
  WRITE_LARGE_DOTS      = "M",  -- Write LARGE DOTS PICTURE file (p42)
  READ_LARGE_DOTS       = "N",  -- Read LARGE DOTS PICTURE file (p43)
  WRITE_ALPHAVISION     = "O",  -- Write ALPHAVISION BULLETIN (p48)
  SET_TIMEOUT           = "T",  -- Set Timeout Message (p118) (Alpha 2.0/3.0)
}
P.Commands = Commands

local Constants = {
  UNLOCKED              = "U",
  LOCKED                = "L",
  PACKET_PREFIX         = "\000\000\000\000\000"
}
P.Constants = Constants

local Charsets = {
  -- Character sets
  FIVE_HIGH_STD         = "\0261",
  FIVE_STROKE           = "\0262",
  SEVEN_HIGH_STD        = "\0263",
  SEVEN_STROKE          = "\0264",
  SEVEN_HIGH_FANCY      = "\0265",
  TEN_HIGH_STD          = "\0266",
  SEVEN_SHADOW          = "\0267",
  FULL_HEIGHT_FANCY     = "\0268",
  FULL_HEIGHT_STD       = "\0269",
  SEVEN_SHADOW_FANCY    = "\026:",
  FIVE_WIDE             = "\026;",
  SEVEN_WIDE            = "\026<",
  SEVEN_FANCY_WIDE      = "\026=",
  WIDE_STROKE_FIVE      = "\026>",

  -- Alpha 2.0 and 3.0 only
  FIVE_HIGH_CUST        = "\026W",
  SEVEN_HIGH_CUST       = "\026X",
  TEN_HIGH_CUST         = "\026Y",
  FIFTEEN_HIGH_CUST     = "\026Z",

  -- Character attributes
  WIDE_ON               = "\02901",
  WIDE_OFF              = "\02900",
  DOUBLE_WIDE_ON        = "\02911",
  DOUBLE_WIDE_OFF       = "\02910",
  DOUBLE_HIGH_ON        = "\02921",
  DOUBLE_HIGH_OFF       = "\02920",
  TRUE_DESCENDERS_ON    = "\02931",
  TRUE_DESCENDERS_OFF   = "\02930",
  FIXED_WIDTH_ON        = "\02941",
  FIXED_WIDTH_OFF       = "\02940",
  FANCY_ON              = "\02951",
  FANCY_OFF             = "\02950",
  AUXILIARY_PORT_ON     = "\02961",
  AUXILIARY_PORT_OFF    = "\02960",
  SHADOW_CHARACTERS_ON  = "\02971",
  SHADOW_CHARACTERS_OFF = "\02970",

  FLASH_ON              = "\0071",
  FLASH_OFF             = "\0070",

  -- Character spacing
  PROPORTIONAL          = "\0300",
  FIXED_WIDTH           = "\0301"
}
P.Charsets = Charsets

local Chars = {
  NUL = "\000", -- NULL
  SOH = "\001", -- Start Of Header
  STX = "\002", -- Start of TeXt
  ETX = "\003", -- End of TeXt
  EOT = "\004", -- End Of Transmission
  ENQ = "\005", -- ENQuiry
  ACK = "\006", -- ACKnowledge
  BEL = "\007", -- BELl
  BS  = "\008", -- BackSpace
  HT  = "\009", -- Horizontal Tab
  LF  = "\010", -- Line Feed
  NL  = "\010", -- New Line
  VT  = "\011", -- Vertical Tab
  FF  = "\012", -- Form Feed
  NP  = "\012", -- New Page
  CR  = "\013", -- Carriage Return
  SO  = "\014",
  SI  = "\015",
  DLE = "\016",
  DC1 = "\017",
  DC2 = "\018",
  DC3 = "\019",
  DC4 = "\020",
  NAK = "\021",
  SYN = "\022",
  ETB = "\023",
  CAN = "\024", -- CANcel
  EM  = "\025",
  SUB = "\026", -- SUBstitute
  ESC = "\027", -- ESCape
  FS  = "\028",
  GS  = "\029",
  RS  = "\030",
  US  = "\031"
}
P.Chars = Chars

local ExtendedChars = {
  -- Extended characters
  UP_ARROW         = "\008d",
  DOWN_ARROW       = "\008e",
  LEFT_ARROW       = "\008f",
  RIGHT_ARROW      = "\008g",
  PACMAN           = "\008h",
  SAIL_BOAT        = "\008i",
  BALL             = "\008j",
  TELEPHONE        = "\008k",
  HEART            = "\008l",
  CAR              = "\008m",
  HANDICAP         = "\008n",
  RHINO            = "\008o",
  MUG              = "\008p",
  SATELLITE_DISH   = "\008q",
  COPYRIGHT_SYMBOL = "\008r",
  MALE_SYMBOL      = "\008s",
  FEMALE_SYMBOL    = "\008t",
  BOTTLE           = "\008u",
  DISKETTE         = "\008v",
  PRINTER          = "\008w",
  MUSICAL_NOTE     = "\008x",
  INFINITY_SYMBOL  = "\008y"
}
P.ExtendedChars = ExtendedChars

local ControlCodes = {
  DOUBLE_HIGH_CHARS_OFF            = "\0050",
  DOUBLE_HIGH_CHARS_ON             = "\0051",
  TRUE_DESCENDERS_OFF              = "\0060",
  TRUE_DESCENDERS_ON               = "\0061",
  DISPLAY_TEMP_CELSIUS             = "\008\028",
  DISPLAY_TEMP_FAHRENHEIT          = "\008\029",
  NO_HOLD_SPEED                    = "\009",
  CALL_DATE_PREFIX                 = "\011",   -- followed by format char ("0" - "9")
  CALL_STRING_PREFIX               = "\016",  -- followed by file label
  DISABLE_WIDE_CHARS               = "\017",
  ENABLE_WIDE_CHARS                = "\018",
  CALL_TIME                        = "\019",
  CALL_SMALL_DOTS_PICTURE_PREFIX   = "\020",  -- followed by file label
  CALL_PICTURE_OR_ANIMATION_PREFIX = "\031"  -- followed by picture definition
}
P.ControlCodes = ControlCodes

local Modes = {
  -- Normal display modes
  ROTATE            = "a",
  HOLD              = "b",
  FLASH             = "c",
  ROLL_UP           = "e",
  ROLL_DOWN         = "f",
  ROLL_LEFT         = "g",
  ROLL_RIGHT        = "h",
  WIPE_UP           = "i",
  WIPE_DOWN         = "j",
  WIPE_LEFT         = "k",
  WIPE_RIGHT        = "l",
  SCROLL            = "m",
  AUTOMODE          = "o",
  ROLL_IN           = "p",
  ROLL_OUT          = "q",
  WIPE_IN           = "r",
  WIPE_OUT          = "s",
  COMPRESSED_ROTATE = "t",
  EXPLODE           = "u",
  CLOCK             = "v",

  -- Special modes
  TWINKLE           = "n0",
  SPARKLE           = "n1",
  SNOW              = "n2",
  INTERLOCK         = "n3",
  SWITCH            = "n4",
  SLIDE             = "n5",
  SPRAY             = "n6",
  STARBURST         = "n7",
  WELCOME           = "n8",
  SLOT_MACHINE      = "n9",
  NEWS_FLASH        = "nA",
  TRUMPET_ANIMATION = "nB",
  CYCLE_COLORS      = "nC",

  -- Special graphics
  THANK_YOU         = "nS",
  NO_SMOKING        = "nU",
  DONT_DRINK_DRIVE  = "nV",
  RUNNING_ANIMAL    = "nW",
  FISH_ANIMATION    = "nW",
  FIREWORKS         = "nX",
  TURBO_CAR         = "nY",
  BALLOON_ANIMATION = "nY",
  CHERRY_BOMB       = "nZ"
}
P.Modes = Modes

local Positions = {
  -- Display positions
  MIDDLE_LINE = " ",
  TOP_LINE    = '"',
  BOTTOM_LINE = "&",
  FILL        = "0",
  LEFT        = "1",
  RIGHT       = "2"
}
P.Positions = Positions

local Speeds = {
  -- Display speeds
  SPEED_1 = "\021",  -- slowest
  SPEED_2 = "\022",
  SPEED_3 = "\023",
  SPEED_4 = "\024",
  SPEED_5 = "\025"   -- fastest
}
P.Speeds = Speeds

local Counters = {
  -- Counters
  COUNTER_1 = "\008z",
  COUNTER_2 = "\008{",
  COUNTER_3 = "\008|",
  COUNTER_4 = "\008}",
  COUNTER_5 = "\008-"
}
P.Counters = Counters

local Colors = {
  -- Colors
  RED       = "\0281",
  GREEN     = "\0282",
  AMBER     = "\0283",
  DIM_RED   = "\0284",
  DIM_GREEN = "\0285",
  BROWN     = "\0286",
  ORANGE    = "\0287",
  YELLOW    = "\0288",
  RAINBOW_1 = "\0289",
  RAINBOW_2 = "\028A",
  COLOR_MIX = "\028B",
  AUTOCOLOR = "\028C"
}

function Colors.rgb(rgb)
  return "\028Z"..rgb
end

function Colors.shadow_rgb(rgb)
  return "\028Y"..rgb
end

P.Colors = Colors

-------------------------------------------------------------------------------

local Packet = classes.inheritsFrom(nil)

function Packet:new(type, address, content)
  local p = Packet:_create()
  p:_init(type, address, content)
  return p
end
setmetatable(Packet, { __call = Packet.new })

function Packet:_init(type, addres, content)
  self._packet = string.rep(Chars.NUL, 5)..Chars.SOH..type..address..Chars.STX..content..Chars.EOT
end

function Packet:out()
  return self._packet
end

P.Packet = Packet

-------------------------------------------------------------------------------

local Command = classes.inheritsFrom(nil)

function Command:new(type, size)
  local f = Command:_create()
  f:_init(type, size)
  return f
end
setmetatable(Command, { __call = Command.new })

function Command:_init(code, size)
  self._code = code
  self._size = size
end

function Command:code()
  return self._code
end

function Command:size(size)
  if size then
    self._size = size
  else
    return self._size
  end
end

function Command:out(data)
  return self._code..data
end

-------------------------------------------------------------------------------

local FileCommand = classes.inheritsFrom(Command)

function FileCommand:new(code, label, size)
  local f = FileCommand:_create()
  f:_init(code, label, size)
  return f
end
getmetatable(FileCommand).__call = FileCommand.new

function FileCommand:_init(code, label, size)
  self._label = label
  Command._init(self, code, size)
end

function FileCommand:label()
  return self._label
end

function FileCommand:out(filedata)
  if filedata then
    return Command.out(self, self._label..filedata)
  else
    return Command.out(self, self._label)
  end
end

P.FileCommand = FileCommand

-------------------------------------------------------------------------------

local StringFile = classes.inheritsFrom(FileCommand)

function StringFile:new(data, label, size)
  local s = StringFile:_create()
  s:_init(data, label, size)
  return s
end
getmetatable(StringFile).__call = StringFile.new

function StringFile:_init(data, label, size)
  local _size
  if data then
    _size = string.len(data)
    if _size > 125 then
      _size = 125
      self._data = string.sub(data, 1, 125)
    else
      self._data = data
    end
  else
    _size = 32
    self._data = ""
  end

  local _label = label or "1"

  if size then
    if size > 125 then
      _size = 125
    elseif not data or size > _size then
      _size = size
    end
  end

  FileCommand._init(self, Commands.WRITE_STRING, _label, _size)
end

function StringFile:call()
  return ControlCodes.CALL_STRING_PREFIX..self:label()
end

function StringFile:out()
  return FileCommand.out(self, self._data)
end

P.StringFile = StringFile

-------------------------------------------------------------------------------

local TextFileData = classes.inheritsFrom(nil)

function TextFileData:new(message, position, mode)
  local am = TextFileData:_create()
  am:_init(message, position, mode)
  return am
end

function TextFileData:_init(message, position, mode)
  local _position = position or Positions.MIDDLE_LINE
  local _mode = mode or Modes.HOLD
  if message then
    self._data = Chars.ESC.._position.._mode..message
  else
    self._data = Chars.ESC.._position.._mode
  end
  self._size = string.len(self._data)
end
setmetatable(TextFileData, { __call = TextFileData.new })

function TextFileData:size()
  return self._size
end

function TextFileData:out()
  return self._data
end

P.TextFileData = TextFileData

-------------------------------------------------------------------------------

local TextFile = classes.inheritsFrom(FileCommand)

function TextFile:new(label, size)
  local t = TextFile:_create()
  t:_init(label, size)
  return t
end
getmetatable(TextFile).__call = TextFile.new

function TextFile:_init(label, size)
  local _label = label or "A"
  local _size = size or 64
  if _size < 1 then
    _size = 1
  end
  self._len = 0
  self._data = {}

  FileCommand._init(self, Commands.WRITE_TEXT, _label, _size)
end

function TextFile:add(data)
  table.insert(self._data, data:out())
  self._len = self._len + data:size()
  if self._len > self:size() then
    self:size(self._len)
  end
  return self
end

function TextFile:out()
  if #(self._data) > 0 then
    return FileCommand.out(self, table.concat(self._data))
  else
    return FileCommand.out(self)
  end
end

P.TextFile = TextFile

-------------------------------------------------------------------------------

local SpecialFunction = classes.inheritsFrom(FileCommand)

function SpecialFunction:new(label, data)
  local sf = SpecialFunction:_create()
  sf:_init(label, data)
  return sf
end
getmetatable(SpecialFunction).__call = SpecialFunction.new

function SpecialFunction:_init(label, data)
  self._data = data
  FileCommand._init(self, Commands.WRITE_SPECIAL, label, (data and string.len(data) or 0))
end

function SpecialFunction:out()
  return FileCommand.out(self, self._data)
end

P.SpecialFunction = SpecialFunction

-------------------------------------------------------------------------------

local Date = {}

function Date.call(format)
  local _format = format or 0
  if _format < 0 or _format > 8 then
    _format = 0
  end
  return ControlCodes.CALL_DATE_PREFIX.._format
end

P.Date = Date

-------------------------------------------------------------------------------

local Time = {}

function Time.call()
  return ControlCodes.CALL_TIME
end

function Time.setFormat(format)
  local _format = format or 1
  return SpecialFunction("'", (format == 0 and "S" or "M"))
end

function Time.setTimeOfDay(hour, minute)
  return SpecialFunction(" ", string.format("%02d%02d", hour,  minute))
end

function Time.setDayOfWeek(day)
  local _day = day or 1
  if _day < 1 or _day > 7 then
    _day = 1
  end
  return SpecialFunction("&", tostring(day))
end

function Time.callDayOfWeek()
  return ControlCodes.CALL_DATE_PREFIX..9
end

P.Time = Time

-------------------------------------------------------------------------------

local Sign = classes.inheritsFrom(nil)

function Sign:new(type, address)
  local s = Sign:_create()
  s:_init(type, address)
  return s
end
setmetatable(Sign, { __call = Sign.new })

function Sign:_init(type, address)
  self._type = type or Types.ALL
  self._address = address or "00"
end

function Sign:packet(command)
  return string.rep(Chars.NUL, 5)..Chars.SOH..self._type..self._address..Chars.STX..(command:out())..Chars.EOT
--   return Chars.SOH..self._type..self._address..Chars.STX..(command:out())..Chars.EOT
end

function Sign:packets(commands)
  local _sequence = {}
  for _, command in ipairs(commands) do
    table.insert(_sequence, Chars.STX..(command:out())..Chars.ETX)
  end
  return string.rep(Chars.NUL, 5)..Chars.SOH..self._type..self._address..table.concat(_sequence)..Chars.EOT
--  return Chars.SOH..self._type..self._address..table.concat(_sequence)..Chars.EOT
end

function Sign:clearMemory()
  return self:packet(SpecialFunction("$"))
end

function Sign:softReset()
  return self:packet(SpecialFunction(","))
end

function Sign:tone(frequency, duration, count)
  local _frequency = frequency or 0
  if _frequency < 0 then
    _frequency = 0
  elseif _frequency > 254 then
    _frequency = 254
  end

  local _duration = duration or 1
  if _duration < 1 then
    _duration = 1
  elseif _duration > 15 then
    _duration = 15
  end

  local _count = count or 0
  if _count < 0 then
    _count = 0
  elseif _count > 15 then
    _count = 15
  end

  return self:packet(SpecialFunction("(2", string.format("%02X%X%X",_frequency, _duration, _count)))
end

function Sign:allocate(files)
  local _sequence = {}
  for _, file in ipairs(files) do
    local _size = string.format("%04X", file:size())

    local _qqqq
    local _lock
    if file.isA(StringFile) then
      _qqqq = "0000"
      _lock = Constants.LOCKED
    else -- TextFile
      _qqqq = "FFFF"
      _lock = Constants.UNLOCKED
    end

    table.insert(_sequence, file:label()..file:code().._lock.._size.._qqqq)
  end

  return self:packet(SpecialFunction("$", table.concat(_sequence)))
end

function Sign:writeText(message, label)
  return self:packet(TextFile(label):add(TextFileData(message)))
end

function Sign:writeString(message, label)
  return self:packet(StringFile(message, label))
end

P.Sign = Sign

-------------------------------------------------------------------------------

local MP_UART = classes.inheritsFrom(nil)

function MP_UART:new(id)
  local u = MP_UART:_create()
  u._init(id)
  return u
end
setmetatable(MP_UART, { __call = MP_UART.new })

function MP_UART:_init(id)
  if id < 0 or id > 1 then
    self._id = 1
  else
    self._id = id
  end
end

function MP_UART:setup()
  uart.setup(self._id, 4800, 7, uart.PARITY_EVEN, 2, 0)
end

function MP_UART:write(data)
  uart.write(self._id, data)
end

P.MP_UART = MP_UART

-------------------------------------------------------------------------------

local DebugInterface = classes.inheritsFrom(nil)

function DebugInterface:new()
  return DebugInterface:_create()
end
setmetatable(DebugInterface, { __call = DebugInterface.new })

function DebugInterface:write(data)
  print(data)
end

P.DebugInterface = DebugInterface

-------------------------------------------------------------------------------

P.writeText = function(t, l) return Sign():writeText(t, l) end
P.writeString = function(s, l) return Sign():writeString(s, l) end
P.writeSpecial = function(s) return Sign():packet(s) end

-------------------------------------------------------------------------------

return P

