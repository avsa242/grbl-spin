{{
  planner.h - buffers movement commands and manages the acceleration profile plan
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

#ifndef planner_h
#define planner_h

CON
' The number of linear motions that can be in the plan at any give time
#ifndef BLOCK_BUFFER_SIZE
#ifdef USE_LINE_NUMBERS
    BLOCK_BUFFER_SIZE               = 15
#else
    BLOCK_BUFFER_SIZE               = 16
#endif
#endif

' Returned status message from planner.
    PLAN_OK                         = TRUE
    PLAN_EMPTY_BLOCK                = FALSE

' Define planner data condition flags. Used to denote running conditions of a block.
    PL_COND_FLAG_RAPID_MOTION       = 1 << 0
    PL_COND_FLAG_SYSTEM_MOTION      = 1 << 1 ' Single motion. Circumvents planner state. Used by home/park.
    PL_COND_FLAG_NO_FEED_OVERRIDE   = 1 << 2 ' Motion does not honor feed override.
    PL_COND_FLAG_INVERSE_TIME       = 1 << 3 ' Interprets feed rate value as inverse time when set.
    PL_COND_FLAG_SPINDLE_CW         = 1 << 4
    PL_COND_FLAG_SPINDLE_CCW        = 1 << 5
    PL_COND_FLAG_COOLANT_FLOOD      = 1 << 6
    PL_COND_FLAG_COOLANT_MIST       = 1 << 7
    PL_COND_MOTION_MASK             = (PL_COND_FLAG_RAPID_MOTION | PL_COND_FLAG_SYSTEM_MOTION | PL_COND_FLAG_NO_FEED_OVERRIDE)
    PL_COND_SPINDLE_MASK            = (PL_COND_FLAG_SPINDLE_CW | PL_COND_FLAG_SPINDLE_CCW)
    PL_COND_ACCESSORY_MASK          = (PL_COND_FLAG_SPINDLE_CW | PL_COND_FLAG_SPINDLE_CCW | PL_COND_FLAG_COOLANT_FLOOD | PL_COND_FLAG_COOLANT_MIST)

#endif
