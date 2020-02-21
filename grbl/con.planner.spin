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
#endif

' The number of linear motions that can be in the plan at any give time
#ifndef BLOCK_BUFFER_SIZE
#ifdef USE_LINE_NUMBERS
#define BLOCK_BUFFER_SIZE 15
#else
#define BLOCK_BUFFER_SIZE 16
#endif
#endif

' Returned status message from planner.
#define PLAN_OK true
#define PLAN_EMPTY_BLOCK false

' Define planner data condition flags. Used to denote running conditions of a block.
#define PL_COND_FLAG_RAPID_MOTION      bit(0)
#define PL_COND_FLAG_SYSTEM_MOTION     bit(1) ' Single motion. Circumvents planner state. Used by home/park.
#define PL_COND_FLAG_NO_FEED_OVERRIDE  bit(2) ' Motion does not honor feed override.
#define PL_COND_FLAG_INVERSE_TIME      bit(3) ' Interprets feed rate value as inverse time when set.
#define PL_COND_FLAG_SPINDLE_CW        bit(4)
#define PL_COND_FLAG_SPINDLE_CCW       bit(5)
#define PL_COND_FLAG_COOLANT_FLOOD     bit(6)
#define PL_COND_FLAG_COOLANT_MIST      bit(7)
#define PL_COND_MOTION_MASK    (PL_COND_FLAG_RAPID_MOTION|PL_COND_FLAG_SYSTEM_MOTION|PL_COND_FLAG_NO_FEED_OVERRIDE)
#define PL_COND_SPINDLE_MASK   (PL_COND_FLAG_SPINDLE_CW|PL_COND_FLAG_SPINDLE_CCW)
#define PL_COND_ACCESSORY_MASK (PL_COND_FLAG_SPINDLE_CW|PL_COND_FLAG_SPINDLE_CCW|PL_COND_FLAG_COOLANT_FLOOD|PL_COND_FLAG_COOLANT_MIST)


' This struct stores a linear movement of a g-code block motion with its critical "nominal" values
' are as specified in the source g-code.
DAT'struct

    plan_block_t
        steps[N_AXIS]           long
        step_event_count        long
        direction_bits          byte
        condition               byte
#ifdef USE_LINE_NUMBERS
        line_number             long
#endif
        entry_speed_sqr         long
        max_entry_speed_sqr     long
        acceleration            long
        millimeters             long
        max_junction_speed_sqr  long
        rapid_rate              long
        programmed_rate         long
#ifdef VARIABLE_SPINDLE
        spindle_speed           long
#endif
{{
typedef struct 
  ' Fields used by the bresenham algorithm for tracing the line
  ' NOTE: Used by stepper algorithm to execute the block correctly. Do not alter these values.
  ulong steps[N_AXIS]    ' Step count along each axis
  ulong step_event_count ' The maximum step axis count and number of steps required to complete this block.
  byte direction_bits    ' The direction bit set for this block (refers to *_DIRECTION_BIT in config.h)

  ' Block condition data to ensure correct execution depending on states and overrides.
  byte condition      ' Block bitflag variable defining block run conditions. Copied from pl_line_data.
  #ifdef USE_LINE_NUMBERS
    long line_number  ' Block line number for real-time reporting. Copied from pl_line_data.
  #endif

  ' Fields used by the motion planner to manage acceleration. Some of these values may be updated
  ' by the stepper module during execution of special motion cases for replanning purposes.
  {float} entry_speed_sqr     ' The current planned entry speed at block junction in (mm/min)^2
  {float} max_entry_speed_sqr ' Maximum allowable entry speed based on the minimum of junction limit and
                             '   neighboring nominal speeds with overrides in (mm/min)^2
  {float} acceleration        ' Axis-limit adjusted line acceleration in (mm/min^2). Does not change.
  {float} millimeters         ' The remaining distance for this block to be executed in (mm).
                             ' NOTE: This value may be altered by stepper algorithm during execution.

  ' Stored rate limiting data used by planner when changes occur.
  {float} max_junction_speed_sqr ' Junction entry speed limit based on direction vectors in (mm/min)^2
  {float} rapid_rate             ' Axis-limit adjusted maximum rate for this block direction in (mm/min)
  {float} programmed_rate        ' Programmed rate of this block (mm/min).

#ifdef VARIABLE_SPINDLE
    ' Stored spindle speed data used by spindle overrides and resuming methods.
    {float} spindle_speed    ' Block spindle speed. Copied from pl_line_data.
#endif
 plan_block_t
}}
' Planner data prototype. Must be used when passing new motions to the planner.

    plan_line_data_t
        feed_rate           long{float} ' Desired feed rate for line motion. Value is ignored, if rapid motion.
        spindle_speed       long{float} ' Desired spindle speed through line motion.
        condition           byte        ' Bitflag variable to indicate planner conditions. See defines above.
#ifdef USE_LINE_NUMBERS
        line_number         long        ' Desired line number to report when executing.
#endif

{{
' Planner data prototype. Must be used when passing new motions to the planner.
typedef struct 
    
  {float} feed_rate          ' Desired feed rate for line motion. Value is ignored, if rapid motion.
  {float} spindle_speed      ' Desired spindle speed through line motion.
  byte condition        ' Bitflag variable to indicate planner conditions. See defines above.
#ifdef USE_LINE_NUMBERS
    long line_number    ' Desired line number to report when executing.
#endif
 plan_line_data_t
#endif
}}
