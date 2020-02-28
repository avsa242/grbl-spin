{{
  jog.h - Jogging methods
  Part of Grbl

  Copyright (c) 2016 Sungeun K. Jeon for Gnea Research LLC

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

#include "core.con.grbl.spin"

VAR

    long ptr_sys        'pointer to the system_t struct defined in main
    long ptr_pl_data    'pointer to the pl_data struct defined in main
    long ptr_gc_block   'pointer to the gc_block struct defined in main
    long ptr_values     'pointer to the gc_values struct defined in main

PUB Init(sys_addr, pl_data_addr, gc_block_addr, values_addr)
' Set the ptr_ VARs to the addresses of the structures, defined in the main object
    longmove(@ptr_sys, @sys_addr, 4)

' Sets up valid jog motion received from g-code parser, checks for soft-limits, and executes the jog.
PUB{uint8_t} jog_execute({plan_line_data_t *}pl_data, {parser_block_t *}gc_block)

    ' Initialize planner data struct for jogging motions.
    ' NOTE: Spindle and coolant are allowed to fully function with overrides during a jog.
    pl_data->feed_rate := gc_block->values.f
    pl_data->condition |= PL_COND_FLAG_NO_FEED_OVERRIDE
#ifdef USE_LINE_NUMBERS
    pl_data->line_number := gc_block->values.n
#endif

    if (bit_istrue(settings.flags, BITFLAG_SOFT_LIMIT_ENABLE))
        if (system_check_travel_limits(gc_block->values.xyz))
            return(STATUS_TRAVEL_EXCEEDED)

    ' Valid jog command. Plan, set state, and execute.
    mc_line(gc_block->values.xyz,pl_data)
    if (sys.state == STATE_IDLE)
        if (plan_get_current_block <> NULL)
            ' Check if there is a block to execute.
            sys.state:= STATE_JOG
            st_prep_buffer
            st_wake_up  ' NOTE: Manual start. No state machine required.
    return(STATUS_OK)

