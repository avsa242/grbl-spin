{{
  defaults.h - defaults settings configuration file
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

{{ The defaults.h file serves as a central default settings selector for different machine
   types, from DIY CNC mills to CNC conversions of off-the-shelf machines. The settings
   files listed here are supplied by users, so your results may vary. However, this should
   give you a good starting point as you get to know your machine and tweak the settings for
   your nefarious needs.
   NOTE: Ensure one and only one of these DEFAULTS_XXX values is defined in config.h }}

#ifndef defaults_h
#define defaults_h

CON
#ifdef DEFAULTS_GENERIC
  ' Grbl generic default settings. Should work across different machines.
    DEFAULT_X_STEPS_PER_MM                  = 250.0
    DEFAULT_Y_STEPS_PER_MM                  = 250.0
    DEFAULT_Z_STEPS_PER_MM                  = 250.0
    DEFAULT_X_MAX_RATE                      = 500.0 ' mm/min
    DEFAULT_Y_MAX_RATE                      = 500.0 ' mm/min
    DEFAULT_Z_MAX_RATE                      = 500.0 ' mm/min
    DEFAULT_X_ACCELERATION                  = (10.0*60.0*60.0) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_Y_ACCELERATION                  = (10.0*60.0*60.0) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_Z_ACCELERATION                  = (10.0*60.0*60.0) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_X_MAX_TRAVEL                    = 200.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL                    = 200.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL                    = 200.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX                 = 1000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN                 = 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS         = 10
    DEFAULT_STEPPING_INVERT_MASK            = 0
    DEFAULT_DIRECTION_INVERT_MASK           = 0
    DEFAULT_STEPPER_IDLE_LOCK_TIME          = 25 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK              = 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION              = 0.01 ' mm
    DEFAULT_ARC_TOLERANCE                   = 0.002 ' mm
    DEFAULT_REPORT_INCHES                   = 0 ' false
    DEFAULT_INVERT_ST_ENABLE                = 0 ' false
    DEFAULT_INVERT_LIMIT_PINS               = 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE               = 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE               = 0  ' false
    DEFAULT_INVERT_PROBE_PIN                = 0 ' false
    DEFAULT_LASER_MODE                      = 0 ' false
    DEFAULT_HOMING_ENABLE                   = 0  ' false
    DEFAULT_HOMING_DIR_MASK                 = 0 ' move positive dir
    DEFAULT_HOMING_FEED_RATE                = 25.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE                = 500.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY           = 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF                  = 1.0 ' mm
#endif

#ifdef DEFAULTS_SHERLINE_5400
' Description: Sherline 5400 mill with three NEMA 23 Keling  KL23H256-21-8B 185 oz-in stepper motors,
' driven by three Pololu A4988 stepper drivers with a 30V, 6A power supply at 1.5A per winding.
    MICROSTEPS                              = 2
    STEPS_PER_REV                           = 200.0
    MM_PER_REV                              = (0.050*MM_PER_INCH) ' 0.050 inch/rev leadscrew
    DEFAULT_X_STEPS_PER_MM                  = (STEPS_PER_REV*MICROSTEPS/MM_PER_REV)
    DEFAULT_Y_STEPS_PER_MM                  = (STEPS_PER_REV*MICROSTEPS/MM_PER_REV)
    DEFAULT_Z_STEPS_PER_MM                  = (STEPS_PER_REV*MICROSTEPS/MM_PER_REV)
    DEFAULT_X_MAX_RATE                      = 635.0 ' mm/min (25 ipm)
    DEFAULT_Y_MAX_RATE                      = 635.0 ' mm/min
    DEFAULT_Z_MAX_RATE                      = 635.0 ' mm/min
    DEFAULT_X_ACCELERATION                  = (50.0*60*60) ' 50*60*60 mm/min^2:= 50 mm/sec^2
    DEFAULT_Y_ACCELERATION                  = (50.0*60*60) ' 50*60*60 mm/min^2:= 50 mm/sec^2
    DEFAULT_Z_ACCELERATION                  = (50.0*60*60) ' 50*60*60 mm/min^2:= 50 mm/sec^2
    DEFAULT_X_MAX_TRAVEL                    = 225.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL                    = 125.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL                    = 170.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX                 = 2800.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN                 = 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS         = 10
    DEFAULT_STEPPING_INVERT_MASK            = 0
    DEFAULT_DIRECTION_INVERT_MASK           = ((1<<Y_AXIS)|(1<<Z_AXIS))
    DEFAULT_STEPPER_IDLE_LOCK_TIME          = 25 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK              = 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION              = 0.01 ' mm
    DEFAULT_ARC_TOLERANCE                   = 0.002 ' mm
    DEFAULT_REPORT_INCHES                   = 0 ' true
    DEFAULT_INVERT_ST_ENABLE                = 0 ' false
    DEFAULT_INVERT_LIMIT_PINS               = 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE               = 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE               = 0  ' false
    DEFAULT_INVERT_PROBE_PIN                = 0 ' false
    DEFAULT_LASER_MODE                      = 0 ' false
    DEFAULT_HOMING_ENABLE                   = 0  ' false
    DEFAULT_HOMING_DIR_MASK                 = 0 ' move positive dir
    DEFAULT_HOMING_FEED_RATE                = 50.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE                = 635.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY           = 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF                  = 1.0 ' mm
#endif

#ifdef DEFAULTS_POCKETNC_FR4
' Description: Pocket NC FR4 CNC mill.
    DEFAULT_X_STEPS_PER_MM                  = 800.0
    DEFAULT_Y_STEPS_PER_MM                  = 800.0
    DEFAULT_Z_STEPS_PER_MM                  = 800.0
    DEFAULT_X_MAX_RATE                      = 300.0 ' mm/min
    DEFAULT_Y_MAX_RATE                      = 300.0 ' mm/min
    DEFAULT_Z_MAX_RATE                      = 300.0 ' mm/min
    DEFAULT_X_ACCELERATION                  = (30.0*60*60) ' 15*60*60 mm/min^2:= 15 mm/sec^2
    DEFAULT_Y_ACCELERATION                  = (30.0*60*60) ' 15*60*60 mm/min^2:= 15 mm/sec^2
    DEFAULT_Z_ACCELERATION                  = (30.0*60*60) ' 15*60*60 mm/min^2:= 15 mm/sec^2
    DEFAULT_X_MAX_TRAVEL                    = 225.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL                    = 125.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL                    = 170.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX                 = 7000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN                 = 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS         = 10
    DEFAULT_STEPPING_INVERT_MASK            = 0
    DEFAULT_DIRECTION_INVERT_MASK           = ((1<<Y_AXIS)|(1<<Z_AXIS))
    DEFAULT_STEPPER_IDLE_LOCK_TIME          = 250 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK              = 3 ' WPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.01 ' mm
    DEFAULT_ARC_TOLERANCE 0.002 ' mm
    DEFAULT_REPORT_INCHES 0 ' false
    DEFAULT_INVERT_ST_ENABLE 1 ' false
    DEFAULT_INVERT_LIMIT_PINS 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 1  ' false
    DEFAULT_HOMING_DIR_MASK 1 ' move positive dir
    DEFAULT_HOMING_FEED_RATE 100.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 300.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 3.0 ' mm
#endif

#ifdef DEFAULTS_SHAPEOKO
' Description: Shapeoko CNC mill with three NEMA 17 stepper motors, driven by Synthetos
' grblShield with a 24V, 4.2A power supply.
    MICROSTEPS_XY 8
    STEP_REVS_XY 400
    MM_PER_REV_XY (0.08*18*MM_PER_INCH) ' 0.08 in belt pitch, 18 pulley teeth
    MICROSTEPS_Z 2
    STEP_REVS_Z 400
    MM_PER_REV_Z 1.250 ' 1.25 mm/rev leadscrew
    DEFAULT_X_STEPS_PER_MM (MICROSTEPS_XY*STEP_REVS_XY/MM_PER_REV_XY)
    DEFAULT_Y_STEPS_PER_MM (MICROSTEPS_XY*STEP_REVS_XY/MM_PER_REV_XY)
    DEFAULT_Z_STEPS_PER_MM (MICROSTEPS_Z*STEP_REVS_Z/MM_PER_REV_Z)
    DEFAULT_X_MAX_RATE 1000.0 ' mm/min
    DEFAULT_Y_MAX_RATE 1000.0 ' mm/min
    DEFAULT_Z_MAX_RATE 1000.0 ' mm/min
    DEFAULT_X_ACCELERATION (15.0*60*60) ' 15*60*60 mm/min^2:= 15 mm/sec^2
    DEFAULT_Y_ACCELERATION (15.0*60*60) ' 15*60*60 mm/min^2:= 15 mm/sec^2
    DEFAULT_Z_ACCELERATION (15.0*60*60) ' 15*60*60 mm/min^2:= 15 mm/sec^2
    DEFAULT_X_MAX_TRAVEL 200.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL 200.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL 200.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX 10000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS 10
    DEFAULT_STEPPING_INVERT_MASK 0
    DEFAULT_DIRECTION_INVERT_MASK ((1<<Y_AXIS)|(1<<Z_AXIS))
    DEFAULT_STEPPER_IDLE_LOCK_TIME 255 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.02 ' mm
    DEFAULT_ARC_TOLERANCE 0.002 ' mm
    DEFAULT_REPORT_INCHES 0 ' false
    DEFAULT_INVERT_ST_ENABLE 0 ' false
    DEFAULT_INVERT_LIMIT_PINS 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 0  ' false
    DEFAULT_HOMING_DIR_MASK 0 ' move positive dir
    DEFAULT_HOMING_FEED_RATE 25.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 250.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 1.0 ' mm
#endif

#ifdef DEFAULTS_SHAPEOKO_2
' Description: Shapeoko CNC mill with three NEMA 17 stepper motors, driven by Synthetos
' grblShield at 28V.
    MICROSTEPS_XY 8
    STEP_REVS_XY 200
    MM_PER_REV_XY (2.0*20) ' 2mm belt pitch, 20 pulley teeth
    MICROSTEPS_Z 2
    STEP_REVS_Z 200
    MM_PER_REV_Z 1.250 ' 1.25 mm/rev leadscrew
    DEFAULT_X_STEPS_PER_MM (MICROSTEPS_XY*STEP_REVS_XY/MM_PER_REV_XY)
    DEFAULT_Y_STEPS_PER_MM (MICROSTEPS_XY*STEP_REVS_XY/MM_PER_REV_XY)
    DEFAULT_Z_STEPS_PER_MM (MICROSTEPS_Z*STEP_REVS_Z/MM_PER_REV_Z)
    DEFAULT_X_MAX_RATE 5000.0 ' mm/min
    DEFAULT_Y_MAX_RATE 5000.0 ' mm/min
    DEFAULT_Z_MAX_RATE 500.0 ' mm/min
    DEFAULT_X_ACCELERATION (250.0*60*60) ' 25*60*60 mm/min^2:= 25 mm/sec^2
    DEFAULT_Y_ACCELERATION (250.0*60*60) ' 25*60*60 mm/min^2:= 25 mm/sec^2
    DEFAULT_Z_ACCELERATION (50.0*60*60) ' 25*60*60 mm/min^2:= 25 mm/sec^2
    DEFAULT_X_MAX_TRAVEL 290.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL 290.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL 100.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX 10000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS 10
    DEFAULT_STEPPING_INVERT_MASK 0
    DEFAULT_DIRECTION_INVERT_MASK ((1<<X_AXIS)|(1<<Z_AXIS))
    DEFAULT_STEPPER_IDLE_LOCK_TIME 255 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.02 ' mm
    DEFAULT_ARC_TOLERANCE 0.002 ' mm
    DEFAULT_REPORT_INCHES 0 ' false
    DEFAULT_INVERT_ST_ENABLE 0 ' false
    DEFAULT_INVERT_LIMIT_PINS 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 0  ' false
    DEFAULT_HOMING_DIR_MASK 0 ' move positive dir
    DEFAULT_HOMING_FEED_RATE 25.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 250.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 1.0 ' mm
#endif

#ifdef DEFAULTS_SHAPEOKO_3
' Description: Shapeoko CNC mill with three NEMA 23 stepper motors, driven by CarbideMotion
    MICROSTEPS_XY 8
    STEP_REVS_XY 200
    MM_PER_REV_XY (2.0*20) ' 2mm belt pitch, 20 pulley teeth
    MICROSTEPS_Z 8
    STEP_REVS_Z 200
    MM_PER_REV_Z (2.0*20) ' 2mm belt pitch, 20 pulley teeth
    DEFAULT_X_STEPS_PER_MM (MICROSTEPS_XY*STEP_REVS_XY/MM_PER_REV_XY)
    DEFAULT_Y_STEPS_PER_MM (MICROSTEPS_XY*STEP_REVS_XY/MM_PER_REV_XY)
    DEFAULT_Z_STEPS_PER_MM (MICROSTEPS_Z*STEP_REVS_Z/MM_PER_REV_Z)
    DEFAULT_X_MAX_RATE 5000.0 ' mm/min
    DEFAULT_Y_MAX_RATE 5000.0 ' mm/min
    DEFAULT_Z_MAX_RATE 5000.0 ' mm/min
    DEFAULT_X_ACCELERATION (400.0*60*60) ' 400*60*60 mm/min^2:= 400 mm/sec^2
    DEFAULT_Y_ACCELERATION (400.0*60*60) ' 400*60*60 mm/min^2:= 400 mm/sec^2
    DEFAULT_Z_ACCELERATION (400.0*60*60) ' 400*60*60 mm/min^2:= 400 mm/sec^2
    DEFAULT_X_MAX_TRAVEL 425.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL 465.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL 80.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX 10000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS 10
    DEFAULT_STEPPING_INVERT_MASK 0
    DEFAULT_DIRECTION_INVERT_MASK ((1<<X_AXIS)|(1<<Z_AXIS))
    DEFAULT_STEPPER_IDLE_LOCK_TIME 255 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.02 ' mm
    DEFAULT_ARC_TOLERANCE 0.01 ' mm
    DEFAULT_REPORT_INCHES 0 ' false
    DEFAULT_INVERT_ST_ENABLE 0 ' false
    DEFAULT_INVERT_LIMIT_PINS 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 0  ' false
    DEFAULT_HOMING_DIR_MASK 0 ' move positive dir
    DEFAULT_HOMING_FEED_RATE 100.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 1000.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 25 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 5.0 ' mm
#endif

#ifdef DEFAULTS_X_CARVE_500MM
' Description: X-Carve 3D Carver CNC mill with three 200 step/rev motors driven by Synthetos
' grblShield at 24V.
    MICROSTEPS_XY 8
    STEP_REVS_XY 200
    MM_PER_REV_XY (2.0*20) ' 2mm belt pitch, 20 pulley teeth
    MICROSTEPS_Z 2
    STEP_REVS_Z 200
    MM_PER_REV_Z 2.117 ' ACME 3/8-12 Leadscrew
    DEFAULT_X_STEPS_PER_MM (MICROSTEPS_XY*STEP_REVS_XY/MM_PER_REV_XY)
    DEFAULT_Y_STEPS_PER_MM (MICROSTEPS_XY*STEP_REVS_XY/MM_PER_REV_XY)
    DEFAULT_Z_STEPS_PER_MM (MICROSTEPS_Z*STEP_REVS_Z/MM_PER_REV_Z)
    DEFAULT_X_MAX_RATE 8000.0 ' mm/min
    DEFAULT_Y_MAX_RATE 8000.0 ' mm/min
    DEFAULT_Z_MAX_RATE 500.0 ' mm/min
    DEFAULT_X_ACCELERATION (500.0*60*60) ' 25*60*60 mm/min^2:= 25 mm/sec^2
    DEFAULT_Y_ACCELERATION (500.0*60*60) ' 25*60*60 mm/min^2:= 25 mm/sec^2
    DEFAULT_Z_ACCELERATION (50.0*60*60) ' 25*60*60 mm/min^2:= 25 mm/sec^2
    DEFAULT_X_MAX_TRAVEL 290.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL 290.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL 100.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX 10000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS 10
    DEFAULT_STEPPING_INVERT_MASK 0
    DEFAULT_DIRECTION_INVERT_MASK ((1<<X_AXIS)|(1<<Y_AXIS))
    DEFAULT_STEPPER_IDLE_LOCK_TIME 255 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.02 ' mm
    DEFAULT_ARC_TOLERANCE 0.002 ' mm
    DEFAULT_REPORT_INCHES 0 ' false
    DEFAULT_INVERT_ST_ENABLE 0 ' false
    DEFAULT_INVERT_LIMIT_PINS 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 0  ' false
    DEFAULT_HOMING_DIR_MASK 3 ' move positive dir
    DEFAULT_HOMING_FEED_RATE 25.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 750.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 1.0 ' mm
#endif

#ifdef DEFAULTS_X_CARVE_1000MM
' Description: X-Carve 3D Carver CNC mill with three 200 step/rev motors driven by Synthetos
' grblShield at 24V.
    MICROSTEPS_XY 8
    STEP_REVS_XY 200
    MM_PER_REV_XY (2.0*20) ' 2mm belt pitch, 20 pulley teeth
    MICROSTEPS_Z 2
    STEP_REVS_Z 200
    MM_PER_REV_Z 2.117 ' ACME 3/8-12 Leadscrew
    DEFAULT_X_STEPS_PER_MM (MICROSTEPS_XY*STEP_REVS_XY/MM_PER_REV_XY)
    DEFAULT_Y_STEPS_PER_MM (MICROSTEPS_XY*STEP_REVS_XY/MM_PER_REV_XY)
    DEFAULT_Z_STEPS_PER_MM (MICROSTEPS_Z*STEP_REVS_Z/MM_PER_REV_Z)
    DEFAULT_X_MAX_RATE 8000.0 ' mm/min
    DEFAULT_Y_MAX_RATE 8000.0 ' mm/min
    DEFAULT_Z_MAX_RATE 500.0 ' mm/min
    DEFAULT_X_ACCELERATION (500.0*60*60) ' 25*60*60 mm/min^2:= 25 mm/sec^2
    DEFAULT_Y_ACCELERATION (500.0*60*60) ' 25*60*60 mm/min^2:= 25 mm/sec^2
    DEFAULT_Z_ACCELERATION (50.0*60*60) ' 25*60*60 mm/min^2:= 25 mm/sec^2
    DEFAULT_X_MAX_TRAVEL 740.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL 790.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL 100.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX 10000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS 10
    DEFAULT_STEPPING_INVERT_MASK 0
    DEFAULT_DIRECTION_INVERT_MASK ((1<<X_AXIS)|(1<<Y_AXIS))
    DEFAULT_STEPPER_IDLE_LOCK_TIME 255 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.02 ' mm
    DEFAULT_ARC_TOLERANCE 0.002 ' mm
    DEFAULT_REPORT_INCHES 0 ' false
    DEFAULT_INVERT_ST_ENABLE 0 ' false
    DEFAULT_INVERT_LIMIT_PINS 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 0  ' false
    DEFAULT_HOMING_DIR_MASK 3 ' move positive dir
    DEFAULT_HOMING_FEED_RATE 25.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 750.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 1.0 ' mm
#endif

#ifdef DEFAULTS_BOBSCNC_E3
' Grbl settings for Bob's CNC E3 Machine
' https://www.bobscnc.com/products/e3-cnc-engraving-kit
    DEFAULT_X_STEPS_PER_MM 80.0
    DEFAULT_Y_STEPS_PER_MM 80.0
    DEFAULT_Z_STEPS_PER_MM 2267.717
    DEFAULT_X_MAX_RATE 10000.0 ' mm/min
    DEFAULT_Y_MAX_RATE 10000.0 ' mm/min
    DEFAULT_Z_MAX_RATE 500.0 ' mm/min
    DEFAULT_X_ACCELERATION (500.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_Y_ACCELERATION (500.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_Z_ACCELERATION (300.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_X_MAX_TRAVEL 450.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL 390.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL 85.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX 1000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS 5
    DEFAULT_STEPPING_INVERT_MASK 0
    DEFAULT_DIRECTION_INVERT_MASK 0
    DEFAULT_STEPPER_IDLE_LOCK_TIME 25 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.01 ' mm
    DEFAULT_ARC_TOLERANCE 0.002 ' mm
    DEFAULT_REPORT_INCHES 1 ' true
    DEFAULT_INVERT_ST_ENABLE 0 ' false
    DEFAULT_INVERT_LIMIT_PINS 1 ' true
    DEFAULT_SOFT_LIMIT_ENABLE 1 ' true
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 1  ' true
    DEFAULT_HOMING_DIR_MASK 3 ' move xy -dir, z dir
    DEFAULT_HOMING_FEED_RATE 500.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 4000.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 5.0 ' mm
#endif

#ifdef DEFAULTS_BOBSCNC_E4
' Grbl settings for Bob's CNC E4 Machine
' https://www.bobscnc.com/products/e4-cnc-router
    DEFAULT_X_STEPS_PER_MM 80.0
    DEFAULT_Y_STEPS_PER_MM 80.0
    DEFAULT_Z_STEPS_PER_MM 2267.717
    DEFAULT_X_MAX_RATE 10000.0 ' mm/min
    DEFAULT_Y_MAX_RATE 10000.0 ' mm/min
    DEFAULT_Z_MAX_RATE 500.0 ' mm/min
    DEFAULT_X_ACCELERATION (500.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_Y_ACCELERATION (500.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_Z_ACCELERATION (300.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_X_MAX_TRAVEL 610.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL 610.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL 85.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX 1000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS 5
    DEFAULT_STEPPING_INVERT_MASK 0
    DEFAULT_DIRECTION_INVERT_MASK 0
    DEFAULT_STEPPER_IDLE_LOCK_TIME 25 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.01 ' mm
    DEFAULT_ARC_TOLERANCE 0.002 ' mm
    DEFAULT_REPORT_INCHES 1 ' true
    DEFAULT_INVERT_ST_ENABLE 0 ' false
    DEFAULT_INVERT_LIMIT_PINS 1 ' true
    DEFAULT_SOFT_LIMIT_ENABLE 1 ' true
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 1  ' true
    DEFAULT_HOMING_DIR_MASK 3 ' move xy -dir, z dir
    DEFAULT_HOMING_FEED_RATE 500.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 4000.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 5.0 ' mm
#endif

#ifdef DEFAULTS_ZEN_TOOLWORKS_7x7
' Description: Zen Toolworks 7x7 mill with three Shinano SST43D2121 65oz-in NEMA 17 stepper motors.
' Leadscrew is different from some ZTW kits, where most are 1.25mm/rev rather than 8.0mm/rev here.
' Driven by 30V, 6A power supply and TI DRV8811 stepper motor drivers.
    MICROSTEPS 8
    STEPS_PER_REV 200.0
    MM_PER_REV 8.0 ' 8 mm/rev leadscrew
    DEFAULT_X_STEPS_PER_MM (STEPS_PER_REV*MICROSTEPS/MM_PER_REV)
    DEFAULT_Y_STEPS_PER_MM (STEPS_PER_REV*MICROSTEPS/MM_PER_REV)
    DEFAULT_Z_STEPS_PER_MM (STEPS_PER_REV*MICROSTEPS/MM_PER_REV)
    DEFAULT_X_MAX_RATE 6000.0 ' mm/min
    DEFAULT_Y_MAX_RATE 6000.0 ' mm/min
    DEFAULT_Z_MAX_RATE 6000.0 ' mm/min
    DEFAULT_X_ACCELERATION (600.0*60*60) ' 600*60*60 mm/min^2:= 600 mm/sec^2
    DEFAULT_Y_ACCELERATION (600.0*60*60) ' 600*60*60 mm/min^2:= 600 mm/sec^2
    DEFAULT_Z_ACCELERATION (600.0*60*60) ' 600*60*60 mm/min^2:= 600 mm/sec^2
    DEFAULT_X_MAX_TRAVEL 190.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL 180.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL 150.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX 10000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS 10
    DEFAULT_STEPPING_INVERT_MASK 0
    DEFAULT_DIRECTION_INVERT_MASK ((1<<Y_AXIS))
    DEFAULT_STEPPER_IDLE_LOCK_TIME 25 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.02 ' mm
    DEFAULT_ARC_TOLERANCE 0.002 ' mm
    DEFAULT_REPORT_INCHES 0 ' false
    DEFAULT_INVERT_ST_ENABLE 0 ' false
    DEFAULT_INVERT_LIMIT_PINS 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 0  ' false
    DEFAULT_HOMING_DIR_MASK 0 ' move positive dir
    DEFAULT_HOMING_FEED_RATE 25.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 250.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 1.0 ' mm
#endif

#ifdef DEFAULTS_OXCNC
' Grbl settings for OpenBuilds OX CNC Machine
' http://www.openbuilds.com/builds/openbuilds-ox-cnc-machine.341/
    DEFAULT_X_STEPS_PER_MM 26.670
    DEFAULT_Y_STEPS_PER_MM 26.670
    DEFAULT_Z_STEPS_PER_MM 50
    DEFAULT_X_MAX_RATE 500.0 ' mm/min
    DEFAULT_Y_MAX_RATE 500.0 ' mm/min
    DEFAULT_Z_MAX_RATE 500.0 ' mm/min
    DEFAULT_X_ACCELERATION (10.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_Y_ACCELERATION (10.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_Z_ACCELERATION (10.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_X_MAX_TRAVEL 500.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL 750.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL 80.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX 1000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS 10
    DEFAULT_STEPPING_INVERT_MASK 0
    DEFAULT_DIRECTION_INVERT_MASK 0
    DEFAULT_STEPPER_IDLE_LOCK_TIME 25 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.02 ' mm
    DEFAULT_ARC_TOLERANCE 0.002 ' mm
    DEFAULT_REPORT_INCHES 0 ' false
    DEFAULT_INVERT_ST_ENABLE 0 ' false
    DEFAULT_INVERT_LIMIT_PINS 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 0  ' false
    DEFAULT_HOMING_DIR_MASK 0 ' move positive dir
    DEFAULT_HOMING_FEED_RATE 25.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 500.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 1.0 ' mm
#endif

#ifdef DEFAULTS_SIMULATOR
' Settings only for Grbl Simulator (www.github.com/grbl/grbl-sim)
' Grbl generic default settings. Should work across different machines.
    DEFAULT_X_STEPS_PER_MM 1000.0
    DEFAULT_Y_STEPS_PER_MM 1000.0
    DEFAULT_Z_STEPS_PER_MM 1000.0
    DEFAULT_X_MAX_RATE 1000.0 ' mm/min
    DEFAULT_Y_MAX_RATE 1000.0 ' mm/min
    DEFAULT_Z_MAX_RATE 1000.0 ' mm/min
    DEFAULT_X_ACCELERATION (100.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_Y_ACCELERATION (100.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_Z_ACCELERATION (100.0*60*60) ' 10*60*60 mm/min^2:= 10 mm/sec^2
    DEFAULT_X_MAX_TRAVEL 1000.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Y_MAX_TRAVEL 1000.0 ' mm NOTE: Must be a positive value.
    DEFAULT_Z_MAX_TRAVEL 1000.0 ' mm NOTE: Must be a positive value.
    DEFAULT_SPINDLE_RPM_MAX 1000.0 ' rpm
    DEFAULT_SPINDLE_RPM_MIN 0.0 ' rpm
    DEFAULT_STEP_PULSE_MICROSECONDS 10
    DEFAULT_STEPPING_INVERT_MASK 0
    DEFAULT_DIRECTION_INVERT_MASK 0
    DEFAULT_STEPPER_IDLE_LOCK_TIME 25 ' msec (0-254, 255 keeps steppers enabled)
    DEFAULT_STATUS_REPORT_MASK 1 ' MPos enabled
    DEFAULT_JUNCTION_DEVIATION 0.01 ' mm
    DEFAULT_ARC_TOLERANCE 0.002 ' mm
    DEFAULT_REPORT_INCHES 0 ' false
    DEFAULT_INVERT_ST_ENABLE 0 ' false
    DEFAULT_INVERT_LIMIT_PINS 0 ' false
    DEFAULT_SOFT_LIMIT_ENABLE 0 ' false
    DEFAULT_HARD_LIMIT_ENABLE 0  ' false
    DEFAULT_INVERT_PROBE_PIN 0 ' false
    DEFAULT_LASER_MODE 0 ' false
    DEFAULT_HOMING_ENABLE 0  ' false
    DEFAULT_HOMING_DIR_MASK 0 ' move positive dir
    DEFAULT_HOMING_FEED_RATE 25.0 ' mm/min
    DEFAULT_HOMING_SEEK_RATE 500.0 ' mm/min
    DEFAULT_HOMING_DEBOUNCE_DELAY 250 ' msec (0-65k)
    DEFAULT_HOMING_PULLOFF 1.0 ' mm
#endif

#endif
