{
  nuts_bolts.h - Header file for shared definitions, variables, and functions
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
}


CON

    '#define false 0    ' Reserved words in spin
    '#define true 1     '   and this one is different (-1) - hopefully it won't create a problem...

    SOME_LARGE_VALUE        = 1.0E+38

' Axis array index values. Must start with 0 and be continuous.
' Number of axes
'    N_AXIS                  = 3
#define N_AXIS              3
' Axis indexing value
'    X_AXIS                  = 0
'    Y_AXIS                  = 1
'    Z_AXIS                  = 2
#define X_AXIS              0
#define Y_AXIS              1
#define Z_AXIS              2
' #define A_AXIS 3

' CoreXY motor assignments. DO NOT ALTER.
' NOTE: If the A and B motor axis bindings are changed, this effects the CoreXY equations.
#ifdef COREXY
' Must be X_AXIS
    A_MOTOR                 = X_AXIS
' Must be Y_AXIS
    B_MOTOR                 = Y_AXIS
#endif

' Conversions
    MM_PER_INCH             = 25.40
    INCH_PER_MM             = 0.0393701
'    F_CPU                   = clkfreq'(_clkmode >> 6) * _xinfreq
'    TICKS_PER_MICROSECOND   = F_CPU/1000000

    DELAY_MODE_DWELL        = 0
    DELAY_MODE_SYS_SUSPEND  = 1


