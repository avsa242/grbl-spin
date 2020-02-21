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

#ifndef nuts_bolts_h
#define nuts_bolts_h

'#define false 0    ' Reserved words in spin
'#define true 1     '   and this one is different (-1) - hopefully it won't create a problem...

#define SOME_LARGE_VALUE 1.0E+38

' Axis array index values. Must start with 0 and be continuous.
#define N_AXIS 3 ' Number of axes
#define X_AXIS 0 ' Axis indexing value.
#define Y_AXIS 1
#define Z_AXIS 2
' #define A_AXIS 3

' CoreXY motor assignments. DO NOT ALTER.
' NOTE: If the A and B motor axis bindings are changed, this effects the CoreXY equations.
#ifdef COREXY
#define A_MOTOR X_AXIS ' Must be X_AXIS
#define B_MOTOR Y_AXIS ' Must be Y_AXIS
#endif

' Conversions
#define MM_PER_INCH (25.40)
#define INCH_PER_MM (0.0393701)
#define TICKS_PER_MICROSECOND (F_CPU/1000000)

#define DELAY_MODE_DWELL       0
#define DELAY_MODE_SYS_SUSPEND 1

' Useful macros
#define clear_vector(a) bytefill(a, 0, {sizeof}a)
#define clear_vector_float(a) bytefill(a, 0.0, {sizeof(float)}*N_AXIS)
' #define clear_vector_long(a) bytefill(a, 0.0, {sizeof(long)}*N_AXIS)
#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
#define isequal_position_vector(a,b) !(memcmp(a, b, {sizeof(float)}*N_AXIS))

' Bit field and masking macros
#define bit(n) (1 << n)
#define bit_true(x,mask) (x) |= (mask)
#define bit_false(x,mask) (x) &= !(mask)
#define bit_istrue(x,mask) ((x & mask) <> 0)
#define bit_isfalse(x,mask) ((x & mask) == 0)

#endif
