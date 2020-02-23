{{
  report.h - reporting and messaging methods
  Part of Grbl

  Copyright (c) 2012-2016 Sungeun K. Jeon for Gnea Research LLC

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
#ifndef report_h
#define report_h

CON
' Define Grbl status codes. Valid values (0-255)
    STATUS_OK                               = 0
    STATUS_EXPECTED_COMMAND_LETTER          = 1
    STATUS_BAD_NUMBER_FORMAT                = 2
    STATUS_INVALID_STATEMENT                = 3
    STATUS_NEGATIVE_VALUE                   = 4
    STATUS_SETTING_DISABLED                 = 5
    STATUS_SETTING_STEP_PULSE_MIN           = 6
    STATUS_SETTING_READ_FAIL                = 7
    STATUS_IDLE_ERROR                       = 8
    STATUS_SYSTEM_GC_LOCK                   = 9
    STATUS_SOFT_LIMIT_ERROR                 = 10
    STATUS_OVERFLOW                         = 11
    STATUS_MAX_STEP_RATE_EXCEEDED           = 12
    STATUS_CHECK_DOOR                       = 13
    STATUS_LINE_LENGTH_EXCEEDED             = 14
    STATUS_TRAVEL_EXCEEDED                  = 15
    STATUS_INVALID_JOG_COMMAND              = 16
    STATUS_SETTING_DISABLED_LASER           = 17

    STATUS_GCODE_UNSUPPORTED_COMMAND        = 20
    STATUS_GCODE_MODAL_GROUP_VIOLATION      = 21
    STATUS_GCODE_UNDEFINED_FEED_RATE        = 22
    STATUS_GCODE_COMMAND_VALUE_NOT_INTEGER  = 23
    STATUS_GCODE_AXIS_COMMAND_CONFLICT      = 24
    STATUS_GCODE_WORD_REPEATED              = 25
    STATUS_GCODE_NO_AXIS_WORDS              = 26
    STATUS_GCODE_INVALID_LINE_NUMBER        = 27
    STATUS_GCODE_VALUE_WORD_MISSING         = 28
    STATUS_GCODE_UNSUPPORTED_COORD_SYS      = 29
    STATUS_GCODE_G53_INVALID_MOTION_MODE    = 30
    STATUS_GCODE_AXIS_WORDS_EXIST           = 31
    STATUS_GCODE_NO_AXIS_WORDS_IN_PLANE     = 32
    STATUS_GCODE_INVALID_TARGET             = 33
    STATUS_GCODE_ARC_RADIUS_ERROR           = 34
    STATUS_GCODE_NO_OFFSETS_IN_PLANE        = 35
    STATUS_GCODE_UNUSED_WORDS               = 36
    STATUS_GCODE_G43_DYNAMIC_AXIS_ERROR     = 37
    STATUS_GCODE_MAX_VALUE_EXCEEDED         = 38

' Define Grbl alarm codes. Valid values (1-255). 0 is reserved.
    ALARM_HARD_LIMIT_ERROR                  = EXEC_ALARM_HARD_LIMIT
    ALARM_SOFT_LIMIT_ERROR                  = EXEC_ALARM_SOFT_LIMIT
    ALARM_ABORT_CYCLE                       = EXEC_ALARM_ABORT_CYCLE
    ALARM_PROBE_FAIL_INITIAL                = EXEC_ALARM_PROBE_FAIL_INITIAL
    ALARM_PROBE_FAIL_CONTACT                = EXEC_ALARM_PROBE_FAIL_CONTACT
    ALARM_HOMING_FAIL_RESET                 = EXEC_ALARM_HOMING_FAIL_RESET
    ALARM_HOMING_FAIL_DOOR                  = EXEC_ALARM_HOMING_FAIL_DOOR
    ALARM_HOMING_FAIL_PULLOFF               = EXEC_ALARM_HOMING_FAIL_PULLOFF
    ALARM_HOMING_FAIL_APPROACH              = EXEC_ALARM_HOMING_FAIL_APPROACH

' Define Grbl feedback message codes. Valid values (0-255).
    MESSAGE_CRITICAL_EVENT                  = 1
    MESSAGE_ALARM_LOCK                      = 2
    MESSAGE_ALARM_UNLOCK                    = 3
    MESSAGE_ENABLED                         = 4
    MESSAGE_DISABLED                        = 5
    MESSAGE_SAFETY_DOOR_AJAR                = 6
    MESSAGE_CHECK_LIMITS                    = 7
    MESSAGE_PROGRAM_END                     = 8
    MESSAGE_RESTORE_DEFAULTS                = 9
    MESSAGE_SPINDLE_RESTORE                 = 10
    MESSAGE_SLEEP_MODE                      = 11

#endif
