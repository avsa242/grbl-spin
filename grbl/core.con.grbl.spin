{
  grbl.h - main Grbl include file
  Part of Grbl

  Copyright (c) 2015-2016 Sungeun K. Jeon for Gnea Research LLC

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
}

#ifndef grbl_h
#define grbl_h

' Grbl versioning system
#define GRBL_VERSION "1.1h"
#define GRBL_VERSION_BUILD "20190830"

' Define standard libraries used by Grbl.
'#include <avr/io.h>
'#include <avr/pgmspace.h>
'#include <avr/interrupt.h>
'#include <avr/wdt.h>
'#include <util/delay.h>        'time?
'#include <math.h>              'math.float?
'#include <inttypes.h>          'string.integer?
'#include <string.h>            'string.types?
'#include <stdlib.h>
'#include <stdint.h>
'#include <stdbool.h>

' Define the Grbl system include files. NOTE: Do not alter organization.
#include "config.h"             '1 2 3
#include "nuts_bolts.h"         '1 2 3 4
#include "settings.h"           '1 2 3 4
#include "system.h"             '1 2 3 4
#include "defaults.h"           '1 2 (contains preprocessor code only)
#include "cpu_map.h"            '1 2 (contains preprocessor code only)
#include "planner.h"            '1 2 3
#include "coolant_control.h"    '1 2 3
#include "eeprom.h"             '1 2 3
#include "gcode.h"              '1 2 3
#include "limits.h"             '1 2 3
#include "motion_control.h"     '1 2 3
#include "print.h"              '1 2 3
#include "probe.h"              '1 2 3
#include "protocol.h"           '1 2 3
#include "report.h"             '1 2 3
#include "serial.h"             '1 2 3  'XXX hardware specific bits in here
#include "spindle_control.h"    '1 2 3
#include "stepper.h"            '1 2 3
#include "jog.h"                '1 2 3

' ---------------------------------------------------------------------------------------
' COMPILE-TIME ERROR CHECKING OF DEFINE VALUES:

#ifndef HOMING_CYCLE_0
  #error "Required HOMING_CYCLE_0 not defined."
#endif

#if defined(USE_SPINDLE_DIR_AS_ENABLE_PIN) && !defined(VARIABLE_SPINDLE)
  #error "USE_SPINDLE_DIR_AS_ENABLE_PIN may only be used with VARIABLE_SPINDLE enabled"
#endif

#if defined(USE_SPINDLE_DIR_AS_ENABLE_PIN) && !defined(CPU_MAP_ATMEGA328P)
  #error "USE_SPINDLE_DIR_AS_ENABLE_PIN may only be used with a 328p processor"
#endif

#if !defined(USE_SPINDLE_DIR_AS_ENABLE_PIN) && defined(SPINDLE_ENABLE_OFF_WITH_ZERO_SPEED)
  #error "SPINDLE_ENABLE_OFF_WITH_ZERO_SPEED may only be used with USE_SPINDLE_DIR_AS_ENABLE_PIN enabled"
#endif

#if defined(PARKING_ENABLE)
  #if defined(HOMING_FORCE_SET_ORIGIN)
    #error "HOMING_FORCE_SET_ORIGIN is not supported with PARKING_ENABLE at this time."
  #endif
#endif

#if defined(ENABLE_PARKING_OVERRIDE_CONTROL)
  #if !defined(PARKING_ENABLE)
    #error "ENABLE_PARKING_OVERRIDE_CONTROL must be enabled with PARKING_ENABLE."
  #endif
#endif

#if defined(SPINDLE_PWM_MIN_VALUE)
  #if !(SPINDLE_PWM_MIN_VALUE > 0)
    #error "SPINDLE_PWM_MIN_VALUE must be greater than zero."
  #endif
#endif

#if (REPORT_WCO_REFRESH_BUSY_COUNT < REPORT_WCO_REFRESH_IDLE_COUNT)
  #error "WCO busy refresh is less than idle refresh."
#endif
#if (REPORT_OVR_REFRESH_BUSY_COUNT < REPORT_OVR_REFRESH_IDLE_COUNT)
  #error "Override busy refresh is less than idle refresh."
#endif
#if (REPORT_WCO_REFRESH_IDLE_COUNT < 2)
  #error "WCO refresh must be greater than one."
#endif
#if (REPORT_OVR_REFRESH_IDLE_COUNT < 1)
  #error "Override refresh must be greater than zero."
#endif

#if defined(ENABLE_DUAL_AXIS)
  #if !((DUAL_AXIS_SELECT :== X_AXIS) || (DUAL_AXIS_SELECT == Y_AXIS))
    #error "Dual axis currently supports X or Y axes only."
  #endif
  #if defined(DUAL_AXIS_CONFIG_CNC_SHIELD_CLONE) && defined(VARIABLE_SPINDLE)
    #error "VARIABLE_SPINDLE not supported with DUAL_AXIS_CNC_SHIELD_CLONE."
  #endif
  #if defined(DUAL_AXIS_CONFIG_CNC_SHIELD_CLONE) && defined(DUAL_AXIS_CONFIG_PROTONEER_V3_51)
    #error "More than one dual axis configuration found. Select one."
  #endif
  #if !defined(DUAL_AXIS_CONFIG_CNC_SHIELD_CLONE) && !defined(DUAL_AXIS_CONFIG_PROTONEER_V3_51)
    #error "No supported dual axis configuration found. Select one."
  #endif
  #if defined(COREXY)
    #error "CORE XY not supported with dual axis feature."
  #endif
  #if defined(USE_SPINDLE_DIR_AS_ENABLE_PIN)
    #error "USE_SPINDLE_DIR_AS_ENABLE_PIN not supported with dual axis feature."
  #endif
  #if defined(ENABLE_M7)
    #error "ENABLE_M7 not supported with dual axis feature."
  #endif
#endif

' ---------------------------------------------------------------------------------------

#endif
