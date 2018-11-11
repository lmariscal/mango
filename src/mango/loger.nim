# Written by Leonardo Mariscal <leo@cav.bz>, 2018

import strformat, os, times, strutils, terminal
export strformat

type
  MangoAssert = object of Exception
  LogLevel* {.pure.} = enum
    llMango   = "mngo" # mango specific calls
    llDebug   = "dbug" # debug
    llInfo    = "info" # info
    llWarning = "warn" # warning
    llError   = "eror" # error
    llCrash   = "crax" # crash
  LogData* = object
    level*: LogLevel
    msg*: string
    time*: DateTime
  ErrorData* = object
    msg*: string
    code*: int32
  LogProc* = proc(data: LogData)
  ErrorProc* = proc(error: ErrorData): bool

var
  logData*: seq[LogData] = @[]
  logDisableConsole*: bool = false
  logMinLevel*: LogLevel = llDebug
  logProc: LogProc = nil
  errorProc: ErrorProc = nil

proc getColor(level: LogLevel): ForegroundColor =
  case level:
    of llMango:
      result = fgDefault
    of llDebug:
      result = fgCyan
    of llInfo:
      result = fgDefault
    of llWarning:
      result = fgYellow
    of llError:
      result = fgRed
    of llCrash:
      result = fgWhite

proc log*(data: LogData) =
  logData.add(data)
  if not logDisableConsole and data.level.ord >= logMinLevel.ord:
    setForegroundColor(data.level.getColor())
    when defined(mangoNoTimeLog):
      writeStyled("[{data.level}] {data.msg}\n".fmt)
    else:
      let time = data.time.format("HH:mm:ss")
      writeStyled("""{time} [{data.level}] {data.msg}""".fmt & "\n")
    resetAttributes()
  if logProc != nil:
    logProc(data)

proc log*(msg: string, level: LogLevel = llInfo) =
  log(LogData(level: level, msg: msg, time: now()))

proc log*(msg: varargs[string, `$`]) =
  var joined = ""
  for m in msg:
    joined.add(m)
  log(LogData(level: llInfo, msg: joined, time: now()))

proc debug*(msg: string) =
  log(LogData(level: llDebug, msg: msg, time: now()))

proc warning*(system: string, msg: string) =
  log(LogData(level: llWarning, msg: "{system}: {msg}".fmt, time: now()))

proc error*(system: string, msg: string) =
  log(LogData(level: llError, msg: "{system}: {msg}".fmt, time: now()))

proc mlog*(system: string, msg: string) =
  ## Mango Log
  ## Exposed for utility reasons, not recommended to use directly nor the level Mango as it is reserved to the library.
  log(LogData(level: llMango, msg: "{system}: {msg}".fmt, time: now()))

proc mlog*(system: string, msg: varargs[string, `$`]) =
  ## Mango Log
  ## Exposed for utility reasons, not recommended to use directly nor the level Mango as it is reserved to the library.
  var joined = ""
  for m in msg:
    joined.add(m)
  log(LogData(level: llMango, msg: "{system}: {joined}".fmt, time: now()))

proc crash*(msg: string, code: int32 = 1, close: bool = true) =
  let data = LogData(level: llCrash, msg: "{msg} [{code}]".fmt, time: now())
  setBackgroundColor(bgRed)
  log(data)
  if errorProc != nil:
    if errorProc(ErrorData(msg: msg, code: code)):
      return

  var output = ""
  for log in logData:
    output.add("{log.time} {log.level}: {log.msg}\n".fmt)
  if not dirExists("logs"):
    createDir("logs")
  let time = now().format("ddMMYYYY HHMMss").replace(" ", "_")
  writeFile("logs/mango_{time}.log".fmt, output)
  if close:
    quit(code)

template lassert*(conditional: bool, msg: string = "", level: LogLevel = llCrash) =
  if not conditional:
    if level == llCrash:
      crash(msg, -1, false)
      raise newException(MangoAssert, msg)
    else:
      log(msg, level)

proc setLogProc*(back: LogProc) =
  if back != nil:
    logProc = back
  else:
    log("not able to set nil proc to logProc", llError)
