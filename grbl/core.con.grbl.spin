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
#include "con.config.spin"
'#include "con.nuts_bolts.spin"
'#include "con.settings.spin"
'#include "con.system.spin"
'#include "con.defaults.spin"
'#include "con.cpu_map.spin"
'#include "con.planner.spin"
'#include "con.coolant_control.spin"
'#include "con.eeprom.spin"
'#include "con.gcode.spin"
'#include "con.limits.spin"
'#include "con.motion_control.spin"
'#include "con.print.spin"
'#include "con.probe.spin"
'#include "con.protocol.spin"
'#include "con.report.spin"
'#include "con.serial.spin"
'#include "con.spindle_control.spin"
'#include "con.stepper.spin"
'#include "con.jog.spin"

' ---------------------------------------------------------------------------------------
' COMPILE-TIME ERROR CHECKING OF DEFINE VALUES:
#define F_CPU clkfreq
#define TICKS_PER_MICROSECOND (clkfreq / 1000000)

#ifndef HOMING_CYCLE_0
#error "Required HOMING_CYCLE_0 not defined."
#endif

#ifdef USE_SPINDLE_DIR_AS_ENABLE_PIN
#ifndef VARIABLE_SPINDLE
#error "USE_SPINDLE_DIR_AS_ENABLE_PIN may only be used with VARIABLE_SPINDLE enabled"
#endif
#endif

#ifdef USE_SPINDLE_DIR_AS_ENABLE_PIN
#ifndef CPU_MAP_ATMEGA328P
#error "USE_SPINDLE_DIR_AS_ENABLE_PIN may only be used with a 328p processor"
#endif
#endif

#ifndef USE_SPINDLE_DIR_AS_ENABLE_PIN
#ifdef SPINDLE_ENABLE_OFF_WITH_ZERO_SPEED
#error "SPINDLE_ENABLE_OFF_WITH_ZERO_SPEED may only be used with USE_SPINDLE_DIR_AS_ENABLE_PIN enabled"
#endif
#endif

#ifdef PARKING_ENABLE
#ifdef HOMING_FORCE_SET_ORIGIN
#error "HOMING_FORCE_SET_ORIGIN is not supported with PARKING_ENABLE at this time."
#endif
#endif

#ifdef ENABLE_PARKING_OVERRIDE_CONTROL
#ifndef PARKING_ENABLE
#error "ENABLE_PARKING_OVERRIDE_CONTROL must be enabled with PARKING_ENABLE."
#endif
#endif

'#ifdef SPINDLE_PWM_MIN_VALUE
'#if SPINDLE_PWM_MIN_VALUE == 0
'#error "SPINDLE_PWM_MIN_VALUE must be greater than zero."
'#endif
'#endif

'#if REPORT_WCO_REFRESH_BUSY_COUNT < REPORT_WCO_REFRESH_IDLE_COUNT
'#error "WCO busy refresh is less than idle refresh."
'#endif
'#if REPORT_OVR_REFRESH_BUSY_COUNT < REPORT_OVR_REFRESH_IDLE_COUNT
'#error "Override busy refresh is less than idle refresh."
'#endif
'#if REPORT_WCO_REFRESH_IDLE_COUNT < 2
'#error "WCO refresh must be greater than one."
'#endif
'#if REPORT_OVR_REFRESH_IDLE_COUNT < 1
'#error "Override refresh must be greater than zero."
'#endif

#ifdef ENABLE_DUAL_AXIS
'#if !((DUAL_AXIS_SELECT == X_AXIS) || (DUAL_AXIS_SELECT == Y_AXIS))
'#error "Dual axis currently supports X or Y axes only."
'#endif
#ifdef DUAL_AXIS_CONFIG_CNC_SHIELD_CLONE
#ifdef VARIABLE_SPINDLE
#error "VARIABLE_SPINDLE not supported with DUAL_AXIS_CNC_SHIELD_CLONE."
#endif
#endif

#ifdef DUAL_AXIS_CONFIG_CNC_SHIELD_CLONE
#ifdef DUAL_AXIS_CONFIG_PROTONEER_V3_51
#error "More than one dual axis configuration found. Select one."
#endif
#endif

#ifndef DUAL_AXIS_CONFIG_CNC_SHIELD_CLONE
#ifndef DUAL_AXIS_CONFIG_PROTONEER_V3_51
#error "No supported dual axis configuration found. Select one."
#endif
#endif

#ifdef COREXY
#error "CORE XY not supported with dual axis feature."
#endif

#ifdef USE_SPINDLE_DIR_AS_ENABLE_PIN
#error "USE_SPINDLE_DIR_AS_ENABLE_PIN not supported with dual axis feature."
#endif

#ifdef ENABLE_M7
#error "ENABLE_M7 not supported with dual axis feature."
#endif

#endif

' ---------------------------------------------------------------------------------------

#endif
