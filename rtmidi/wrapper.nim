when defined(windows):
  when defined rtMidiAlsa:
    {.error: "ALSA is not supported on Windows".}
  when defined rtMidiJack:
    {.error: "JACK is not supported on Windows".}
  when defined rtMidiCore:
    {.error: "CoreMIDI is not supported on Windows".}

  {.passC: "-D__WINDOWS_MM__", passL: "-lstdc++ -lwinmm",
    compile: "src/RtMidi.cpp",
    compile: "src/rtmidi_c.cpp".}

elif defined(macosx):
  when defined rtMidiCore:
    {.passC: "-D__MACOSX_CORE__ ",
      passL: "-framework CoreMIDI -framework CoreAudio -framework CoreFoundation".}
  when defined rtMidiJack:
    {.passC: "-D__UNIX_JACK__", passL: "-ljack".}
  when defined rtMidiAlsa:
    {.error: "ALSA is not supported on OS X".}

  {.passL: "-lstdc++",
    compile: "rtmidi/src/RtMidi.cpp",
    compile: "rtmidi/src/rtmidi_c.cpp".}

elif defined(linux):
  when defined rtMidiCore:
    {.error: "CoreMIDI is not supported on Linux".}
  when defined(rtMidiAlsa):
    {.passC: "-D__LINUX_ALSA__", passL: "-lasound -lpthread".}
  elif defined(rtMidiJack):
    {.passC: "-D__UNIX_JACK__", passL: "-ljack".}
  else:
    {.error: "define rtMidiAlsa or rtMidiJack (pass -d:... to compile)".}

  {.passL: "-lstdc++",
    compile: "rtmidi/src/RtMidi.cpp",
    compile: "rtmidi/src/rtmidi_c.cpp".}

{.pragma: rtMIdiImport.}


type
  RtMidiWrapper* {.bycopy.} = object
    rtMidiPtr*: pointer
    data*:      pointer
    ok*:        bool
    msg*:       cstring

  RtMidiWrapperPtr* = ptr RtMidiWrapper

type
  MidiApi* = enum
    maUnspecified = (0, "unspecified"),
    maCoreMidi    = (1, "core"),
    maAlsa        = (2, "alsa"),
    maJack        = (3, "jack"),
    maWindows     = (4, "winmm"),
    maDummy       = (5, "dummy")

type
  MidiError* = enum
    meWarning,
    meDebugWarning,
    meUnspecified,
    meNoDevicesFound,
    meInvalidDevice,
    meMemoryError,
    meInvalidParameter,
    meInvalidUse,
    meDriverError,
    meSystemError,
    meThreadError


type
  RtMidiCallback* = proc (deltaTime: cdouble, message: ptr UncheckedArray[byte],
                          messageSize: csize_t, userData: pointer) {.cdecl.}

proc getCompiledApi*(apis: ptr MidiApi, apisSize: cuint): cint
  {.rtMidiImport, cdecl, importc: "rtmidi_get_compiled_api".}

proc name*(api: MidiApi): cstring
  {.rtMidiImport, cdecl, importc: "rtmidi_api_name".}

proc displayName*(api: MidiApi): cstring
  {.rtMidiImport, cdecl, importc: "rtmidi_api_display_name".}

proc getCompiledApiByName*(name: cstring): MidiApi
  {.rtMidiImport, cdecl, importc: "rtmidi_compiled_api_by_name".}

proc rtMidiError*(`type`: MidiError, errorString: cstring)
  {.rtMidiImport, cdecl, importc: "rtmidi_error".}


# Midi In functions

proc createDefaultMidiIn*(): RtMidiWrapperPtr
  {.rtMidiImport, cdecl, importc: "rtmidi_in_create_default".}

proc createMidiIn*(api: MidiApi, clientName: cstring,
                   queueSizeLimit: cuint): RtMidiWrapperPtr
  {.rtMidiImport, cdecl, importc: "rtmidi_in_create".}

proc freeMidiIn*(device: RtMidiWrapperPtr)
  {.rtMidiImport, cdecl, importc: "rtmidi_in_free".}

proc getCurrentMidiInApi*(device: RtMidiWrapperPtr): MidiApi
  {.rtMidiImport, cdecl, importc: "rtmidi_in_get_current_api".}

proc setCallback*(device: RtMidiWrapperPtr, callback: RtMidiCallback,
                  userData: pointer)
  {.rtMidiImport, cdecl, importc: "rtmidi_in_set_callback".}

proc cancelCallback*(device: RtMidiWrapperPtr)
  {.rtMidiImport, cdecl, importc: "rtmidi_in_cancel_callback".}

proc ignoreTypes*(device: RtMidiWrapperPtr, midiSysEx: bool, midiTime: bool,
                  midiSense: bool)
  {.rtMidiImport, cdecl, importc: "rtmidi_in_ignore_types".}

proc getMessage*(device: RtMidiWrapperPtr, message: ptr byte,
                 size: ptr csize_t): cdouble
  {.rtMidiImport, cdecl, importc: "rtmidi_in_get_message".}


# Midi Out functions

proc createDefaultMidiOut*(): RtMidiWrapperPtr
  {.rtMidiImport, cdecl, importc: "rtmidi_out_create_default".}

proc createMidiOut*(api: MidiApi, clientName: cstring): RtMidiWrapperPtr
  {.rtMidiImport, cdecl, importc: "rtmidi_out_create".}

proc freeMidiOut*(device: RtMidiWrapperPtr)
  {.rtMidiImport, cdecl, importc: "rtmidi_out_free".}

proc getCurrentMidiOutApi*(device: RtMidiWrapperPtr): MidiApi
  {.rtMidiImport, cdecl, importc: "rtmidi_out_get_current_api".}

proc sendMessage*(device: RtMidiWrapperPtr, message: ptr byte,
                  length: cint): cint
  {.rtMidiImport, cdecl, importc: "rtmidi_out_send_message".}


# Common Midi In/Out functions

proc openPort*(device: RtMidiWrapperPtr, portNumber: cuint, portName: cstring)
  {.rtMidiImport, cdecl, importc: "rtmidi_open_port".}

proc openVirtualPort*(device: RtMidiWrapperPtr, portName: cstring)
  {.rtMidiImport, cdecl, importc: "rtmidi_open_virtual_port".}

proc closePort*(device: RtMidiWrapperPtr)
  {.rtMidiImport, cdecl, importc: "rtmidi_close_port".}

proc portCount*(device: RtMidiWrapperPtr): cuint
  {.rtMidiImport, cdecl, importc: "rtmidi_get_port_count".}

proc portName*(device: RtMidiWrapperPtr, portNumber: cuint): cstring
  {.rtMidiImport, cdecl, importc: "rtmidi_get_port_name".}

