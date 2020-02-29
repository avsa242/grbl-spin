{{
  system.h - Header for system level commands and real-time processes
  Part of Grbl

  Copyright (c) 2014-2016 Sungeun K. Jeon for Gnea Research LLC

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

'#ifndef system_h
'#define system_h

'#include "core.con.grbl.spin"

CON
' Define system executor bit map. Used internally by realtime protocol as realtime command flags,
' which notifies the main program to execute the specified realtime command asynchronously.
' NOTE: The system executor uses an unsigned 8-bit {void}  variable (8 flag limit.) The default
' flags are always false, so the realtime protocol only needs to check for a non-zero value to
' know when there is a realtime command to execute.
    EXEC_STATUS_REPORT                      = 1 << 0 ' bitmask 00000001
    EXEC_CYCLE_START                        = 1 << 1 ' bitmask 00000010
    EXEC_CYCLE_STOP                         = 1 << 2 ' bitmask 00000100
    EXEC_FEED_HOLD                          = 1 << 3 ' bitmask 00001000
    EXEC_RESET                              = 1 << 4 ' bitmask 00010000
    EXEC_SAFETY_DOOR                        = 1 << 5 ' bitmask 00100000
    EXEC_MOTION_CANCEL                      = 1 << 6 ' bitmask 01000000
    EXEC_SLEEP                              = 1 << 7 ' bitmask 10000000

' Alarm executor codes. Valid values (1-255). Zero is reserved.
    EXEC_ALARM_HARD_LIMIT                   = 1
    EXEC_ALARM_SOFT_LIMIT                   = 2
    EXEC_ALARM_ABORT_CYCLE                  = 3
    EXEC_ALARM_PROBE_FAIL_INITIAL           = 4
    EXEC_ALARM_PROBE_FAIL_CONTACT           = 5
    EXEC_ALARM_HOMING_FAIL_RESET            = 6
    EXEC_ALARM_HOMING_FAIL_DOOR             = 7
    EXEC_ALARM_HOMING_FAIL_PULLOFF          = 8
    EXEC_ALARM_HOMING_FAIL_APPROACH         = 9
    EXEC_ALARM_HOMING_FAIL_DUAL_APPROACH    = 10

' Override bit maps. Realtime bitflags to control feed, rapid, spindle, and coolant overrides.
' Spindle/coolant and feed/rapids are separated into two controlling flag variables.
    EXEC_FEED_OVR_RESET                     = 1 << 0
    EXEC_FEED_OVR_COARSE_PLUS               = 1 << 1
    EXEC_FEED_OVR_COARSE_MINUS              = 1 << 2
    EXEC_FEED_OVR_FINE_PLUS                 = 1 << 3
    EXEC_FEED_OVR_FINE_MINUS                = 1 << 4
    EXEC_RAPID_OVR_RESET                    = 1 << 5
    EXEC_RAPID_OVR_MEDIUM                   = 1 << 6
    EXEC_RAPID_OVR_LOW                      = 1 << 7
' #define EXEC_RAPID_OVR_EXTRA_LOW   1 << *) // *NOT SUPPORTED*

    EXEC_SPINDLE_OVR_RESET                  = 1 << 0
    EXEC_SPINDLE_OVR_COARSE_PLUS            = 1 << 1
    EXEC_SPINDLE_OVR_COARSE_MINUS           = 1 << 2
    EXEC_SPINDLE_OVR_FINE_PLUS              = 1 << 3
    EXEC_SPINDLE_OVR_FINE_MINUS             = 1 << 4
    EXEC_SPINDLE_OVR_STOP                   = 1 << 5
    EXEC_COOLANT_FLOOD_OVR_TOGGLE           = 1 << 6
    EXEC_COOLANT_MIST_OVR_TOGGLE            = 1 << 7

' Define system state bit map. The state variable primarily tracks the individual functions
' of Grbl to manage each without overlapping. It is also used as a messaging flag for
' critical events.
    STATE_IDLE                              = 0      ' Must be zero. No flags.
    STATE_ALARM                             = 1 << 0 ' In alarm state. Locks out all g-code processes. Allows settings access.
    STATE_CHECK_MODE                        = 1 << 1 ' G-code check mode. Locks out planner and motion only.
    STATE_HOMING                            = 1 << 2 ' Performing homing cycle
    STATE_CYCLE                             = 1 << 3 ' Cycle is running or motions are being executed.
    STATE_HOLD                              = 1 << 4 ' Active feed hold
    STATE_JOG                               = 1 << 5 ' Jogging mode.
    STATE_SAFETY_DOOR                       = 1 << 6 ' Safety door is ajar. Feed holds and de-energizes system.
    STATE_SLEEP                             = 1 << 7 ' Sleep state.

' Define system suspend flags. Used in various ways to manage suspend states and procedures.
    SUSPEND_DISABLE                         = 0      ' Must be zero.
    SUSPEND_HOLD_COMPLETE                   = 1 << 0 ' Indicates initial feed hold is complete.
    SUSPEND_RESTART_RETRACT                 = 1 << 1 ' Flag to indicate a retract from a restore parking motion.
    SUSPEND_RETRACT_COMPLETE                = 1 << 2 ' (Safety door only) Indicates retraction and de-energizing is complete.
    SUSPEND_INITIATE_RESTORE                = 1 << 3 ' (Safety door only) Flag to initiate resume procedures from a cycle start.
    SUSPEND_RESTORE_COMPLETE                = 1 << 4 ' (Safety door only) Indicates ready to resume normal operation.
    SUSPEND_SAFETY_DOOR_AJAR                = 1 << 5 ' Tracks safety door state for resuming.
    SUSPEND_MOTION_CANCEL                   = 1 << 6 ' Indicates a canceled resume motion. Currently used by probing routine.
    SUSPEND_JOG_CANCEL                      = 1 << 7 ' Indicates a jog cancel in process and to reset buffers when complete.

' Define step segment generator state flags.
    STEP_CONTROL_NORMAL_OP                  = 0  ' Must be zero.
    STEP_CONTROL_END_MOTION                 = 1 << 0
    STEP_CONTROL_EXECUTE_HOLD               = 1 << 1
    STEP_CONTROL_EXECUTE_SYS_MOTION         = 1 << 2
    STEP_CONTROL_UPDATE_SPINDLE_PWM         = 1 << 3

' Define control pin index for Grbl internal use. Pin maps may change, but these values don't.
#ifdef ENABLE_SAFETY_DOOR_INPUT_PIN
    N_CONTROL_PIN                           = 4
    CONTROL_PIN_INDEX_SAFETY_DOOR           = 1 << 0
    CONTROL_PIN_INDEX_RESET                 = 1 << 1
    CONTROL_PIN_INDEX_FEED_HOLD             = 1 << 2
    CONTROL_PIN_INDEX_CYCLE_START           = 1 << 3
#else
    N_CONTROL_PIN                           = 3
    CONTROL_PIN_INDEX_RESET                 = 1 << 0
    CONTROL_PIN_INDEX_FEED_HOLD             = 1 << 1
    CONTROL_PIN_INDEX_CYCLE_START           = 1 << 2
#endif

' Define spindle stop override control states.
    SPINDLE_STOP_OVR_DISABLED               = 0  ' Must be zero.
    SPINDLE_STOP_OVR_ENABLED                = 1 << 0
    SPINDLE_STOP_OVR_INITIATE               = 1 << 1
    SPINDLE_STOP_OVR_RESTORE                = 1 << 2
    SPINDLE_STOP_OVR_RESTORE_CYCLE          = 1 << 3


'#ifdef DEBUG
'    EXEC_DEBUG_REPORT               = 1 << 0
'VAR {extern} {void}  byte sys_rt_exec_debug
'#endif

'#endif
