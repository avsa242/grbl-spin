{{
  motion_control.h - high level interface for issuing motion commands
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

#ifndef motion_control_h
#define motion_control_h

CON
' System motion commands must have a line number of zero.
    HOMING_CYCLE_LINE_NUMBER    = 0
    PARKING_MOTION_LINE_NUMBER  = 0

    HOMING_CYCLE_ALL            = 0  ' Must be zero.
    HOMING_CYCLE_X              = 1 << X_AXIS
    HOMING_CYCLE_Y              = 1 << Y_AXIS
    HOMING_CYCLE_Z              = 1 << Z_AXIS

#endif
