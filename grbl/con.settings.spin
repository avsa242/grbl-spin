{{
  settings.h - eeprom configuration handling
  Part of Grbl

  Copyright (c) 2011-2016 Sungeun K. Jeon for Gnea Research LLC
  Copyright (c) 2009-2011 Simen Svale Skogsrud

  Grbl is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Grbl is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Grbl.  If not, see <http:'www.gnu.org/licenses/>.
}}

#ifndef settings_h
#define settings_h

'#include "core.con.grbl.spin"


' Version of the EEPROM data. Will be used to migrate existing data from older versions of Grbl
' when firmware is upgraded. Always stored in byte 0 of eeprom

' NOTE: Check settings_reset when moving to next version.
CON

    SETTINGS_VERSION                    = 10
' Define bit flag masks for the boolean settings in settings.flag.
    BIT_REPORT_INCHES                   = 0
    BIT_LASER_MODE                      = 1
    BIT_INVERT_ST_ENABLE                = 2
    BIT_HARD_LIMIT_ENABLE               = 3
    BIT_HOMING_ENABLE                   = 4
    BIT_SOFT_LIMIT_ENABLE               = 5
    BIT_INVERT_LIMIT_PINS               = 6
    BIT_INVERT_PROBE_PIN                = 7

    BITFLAG_REPORT_INCHES               = 1 << BIT_REPORT_INCHES
    BITFLAG_LASER_MODE                  = 1 << BIT_LASER_MODE
    BITFLAG_INVERT_ST_ENABLE            = 1 << BIT_INVERT_ST_ENABLE
    BITFLAG_HARD_LIMIT_ENABLE           = 1 << BIT_HARD_LIMIT_ENABLE
    BITFLAG_HOMING_ENABLE               = 1 << BIT_HOMING_ENABLE
    BITFLAG_SOFT_LIMIT_ENABLE           = 1 << BIT_SOFT_LIMIT_ENABLE
    BITFLAG_INVERT_LIMIT_PINS           = 1 << BIT_INVERT_LIMIT_PINS
    BITFLAG_INVERT_PROBE_PIN            = 1 << BIT_INVERT_PROBE_PIN

' Define status reporting boolean enable bit flags in settings.status_report_mask
    BITFLAG_RT_STATUS_POSITION_TYPE     = 1 << 0
    BITFLAG_RT_STATUS_BUFFER_STATE      = 1 << 1

' Define settings restore bitflags.
    SETTINGS_RESTORE_DEFAULTS           = 1 << 0
    SETTINGS_RESTORE_PARAMETERS         = 1 << 1
    SETTINGS_RESTORE_STARTUP_LINES      = 1 << 2
    SETTINGS_RESTORE_BUILD_INFO         = 1 << 3
#ifndef SETTINGS_RESTORE_ALL
' All bitflags
    SETTINGS_RESTORE_ALL                = $FF
#endif

' Define EEPROM memory address location values for Grbl settings and parameters
' NOTE: The Atmega328p has 1KB EEPROM. The upper half is reserved for parameters and
' the startup script. The lower half contains the global settings and space for future
' developments.
    EEPROM_ADDR_GLOBAL                  = 1
    EEPROM_ADDR_PARAMETERS              = 512
    EEPROM_ADDR_STARTUP_BLOCK           = 768
    EEPROM_ADDR_BUILD_INFO              = 942

' Define EEPROM address indexing for coordinate parameters
    N_COORDINATE_SYSTEM                 = 6  ' Number of supported work coordinate systems (from index 1)

' Total number of system stored (from index 0)
    SETTING_INDEX_NCOORD                = N_COORDINATE_SYSTEM+1
' NOTE: Work coordinate indices are (0=G54, 1=G55, ... , 6=G59)

' Home position 1
    SETTING_INDEX_G28                   = N_COORDINATE_SYSTEM

' Home position 2
    SETTING_INDEX_G30                   = N_COORDINATE_SYSTEM+1
' #define SETTING_INDEX_G92    N_COORDINATE_SYSTEM+2  // Coordinate offset (G92.2,G92.3 not supported)

' Define Grbl axis settings numbering scheme. Starts at START_VAL, every INCREMENT, over N_SETTINGS.
    AXIS_N_SETTINGS                     = 4
' NOTE: Reserving settings values => 100 for axis settings. Up to 255.
    AXIS_SETTINGS_START_VAL             = 100
' Must be greater than the number of axis settings
    AXIS_SETTINGS_INCREMENT             = 10

{{ Global persistent settings (Stored from byte EEPROM_ADDR_GLOBAL onwards)
typedef struct 
    
  ' Axis settings
  long {float} steps_per_mm[N_AXIS]
  long {float} max_rate[N_AXIS]
  long {float} acceleration[N_AXIS]
  long {float} max_travel[N_AXIS]

  ' Remaining Grbl settings
  byte pulse_microseconds
  byte step_invert_mask
  byte dir_invert_mask
  byte stepper_idle_lock_time ' If max value 255, steppers do not disable.
  byte status_report_mask ' Mask to indicate desired report data.
  long {float} junction_deviation
  long {float} arc_tolerance

  long {float} rpm_max
  long {float} rpm_min

  byte flags  ' Contains default boolean settings

  byte homing_dir_mask
  long {float} homing_feed_rate
  long {float} homing_seek_rate
  word uint16_t homing_debounce_delay
  long {float} homing_pulloff
 settings_t
extern settings_t settings
}}
#endif
