{{
  protocol.c - controls Grbl execution protocol and procedures
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

'#include "core.con.grbl.spin"
#include "con.protocol.spin"

' Define line flags. Includes comment type tracking and line overflow detection.
#define LINE_FLAG_OVERFLOW bit(0)
#define LINE_FLAG_COMMENT_PARENTHESES bit(1)
#define LINE_FLAG_COMMENT_SEMICOLON bit(2)

OBJ

    util    : "nuts_bolts.spin"

VAR

    byte {static char} line[LINE_BUFFER_SIZE] ' Line to be executed. Zero-terminated.
    'static  protocol_exec_rt_suspend   '???????

{{
  GRBL PRIMARY LOOP:
}}
PUB protocol_main_loop | {uint8_t} line_flags, char_counter, c

    ' Perform some machine checks to make sure everything is good to go.
#ifdef CHECK_LIMITS_AT_INIT
    if (util.bit_istrue(settings.flags, BITFLAG_HARD_LIMIT_ENABLE)) 
        if (limits_get_state) 
            sys.state := STATE_ALARM ' Ensure alarm state is active.
            report_feedback_message(MESSAGE_CHECK_LIMITS)
      
    
#endif
    ' Check for and report alarm state after a reset, error, or an initial power up.
    ' NOTE: Sleep mode disables the stepper drivers and position can't be guaranteed.
    ' Re-initialize the sleep state as an ALARM mode to ensure user homes or acknowledges.
    if (sys.state & (STATE_ALARM | STATE_SLEEP))
        report_feedback_message(MESSAGE_ALARM_LOCK)
        sys.state := STATE_ALARM ' Ensure alarm state is set.
    else 
        ' Check if the safety door is open.
        sys.state := STATE_IDLE
        if (system_check_safety_door_ajar) 
            bit_true(sys_rt_exec_state, EXEC_SAFETY_DOOR)
            protocol_execute_realtime ' Enter safety door mode. Should return as IDLE state.
        ' All systems go!
        system_execute_startup(line) ' Execute startup script.

  ' ---------------------------------------------------------------------------------
  ' Primary loop! Upon a system abort, this exits back to main to reset the system.
  ' This is also where Grbl idles repeat while waiting for something to do.
  ' ---------------------------------------------------------------------------------

    line_flags := 0
    char_counter := 0
    repeat

        ' Process one line of incoming serial data, as the data becomes available. Performs an
        ' initial filtering by removing spaces and comments and capitalizing all letters.
        repeat while((c := serial_read) <> SERIAL_NO_DATA)
            if ((c == 10) OR (c == 13)) ' End of line reached
                protocol_execute_realtime ' Runtime command check point.
                if (sys.abort)
                    return  ' Bail to calling function upon system abort
                line[char_counter] := 0 ' Set string termination character.
#ifdef REPORT_ECHO_LINE_RECEIVED
                report_echo_line_received(line)
#endif

        ' Direct and execute one line of formatted input, and report status of execution.
                if (line_flags & LINE_FLAG_OVERFLOW)
                    ' Report line overflow error.
                    report_status_message(STATUS_OVERFLOW)
                elseif (line[0] == 0)
                    ' Empty or comment line. For syncing purposes.
                    report_status_message(STATUS_OK)
                elseif (line[0] == "$")
                    ' Grbl  system command
                    report_status_message(system_execute_line(line))
                elseif (sys.state & (STATE_ALARM | STATE_JOG))
                    ' Everything else is gcode. Block if in alarm or jog mode.
                    report_status_message(STATUS_SYSTEM_GC_LOCK)
                else
                    ' Parse and execute g-code block.
                    report_status_message(gc_execute_line(line))
                ' Reset tracking data for next line.
                line_flags := 0
                char_counter := 0
            else
                if (line_flags)
                    ' Throw away all (except EOL) comment characters and overflow characters.
                    if (c == ")")
                        ' End of  comment. Resume line allowed.
                        if (line_flags & LINE_FLAG_COMMENT_PARENTHESES) 
                            line_flags &= !(LINE_FLAG_COMMENT_PARENTHESES) 
                else 
                    if (c =< " ")
                        ' Throw away whitepace and control characters
                    elseif (c == "/")
                        ' Block delete NOT SUPPORTED. Ignore character.
                        ' NOTE: If supported, would simply need to check the system if block delete is enabled.
                    elseif (c == "(")
                        ' Enable comments flag and ignore all characters until  or EOL.
                        ' NOTE: This doesn't follow the NIST definition exactly, but is good enough for now.
                        ' In the future, we could simply remove the items within the comments, but retain the
                        ' comment control characters, so that the g-code parser can error-check it.
                        line_flags |= LINE_FLAG_COMMENT_PARENTHESES
                    elseif (c == ";")
                        ' NOTE:  comment to EOL is a LinuxCNC definition. Not NIST.
                        line_flags |= LINE_FLAG_COMMENT_SEMICOLON
                    ' TODO: Install  feature
                    '  else if (c == "%") 
                    ' Program start-end percent sign NOT SUPPORTED.
                    ' NOTE: This maybe installed to tell Grbl when a program is running vs manual input,
                    ' where, during a program, the system auto-cycle start will continue to execute
                    ' everything until the next  sign. This will help fix resuming issues with certain
                    ' functions that empty the planner buffer to execute its task on-time.
                    elseif (char_counter => (LINE_BUFFER_SIZE-1))
                        ' Detect line buffer overflow and set flag.
                        line_flags |= LINE_FLAG_OVERFLOW
                    elseif (c => "a" AND c =< "z")  ' Upcase lowercase
                        line[char_counter++] := c-"a" + "A"
                    else
                        line[char_counter++] := c
            ' If there are no more characters in the serial read buffer to be processed and executed,
            ' this indicates that g-code streaming has either filled the planner buffer or has
            ' completed. In either case, auto-cycle start, if enabled, any queued moves.
        protocol_auto_cycle_start

        protocol_execute_realtime  ' Runtime command check point.
        if (sys.abort)
            return  ' Bail to main program loop to reset system.

    return {{ Never reached }}

' Block until all buffered steps are executed or in a cycle state. Works with feed hold
' during a synchronize call, if it should happen. Also, waits for clean cycle end.
PUB protocol_buffer_synchronize

    ' If system is queued, ensure cycle resumes if the auto start flag is present.
    protocol_auto_cycle_start
    repeat
        protocol_execute_realtime   ' Check and execute run-time commands
        if (sys.abort) 
            return  ' Check for system abort
    while (plan_get_current_block OR (sys.state == STATE_CYCLE))

' Auto-cycle start triggers when there is a motion ready to execute and if the main program is not
' actively parsing commands.
' NOTE: This function is called from the main loop, buffer sync, and mc_line only and executes
' when one of these conditions exist respectively: There are no more blocks sent (i.e. streaming
' is finished, single commands), a command that needs to wait for the motions in the buffer to
' execute calls a buffer sync, or the planner buffer is full and ready to go.
PUB protocol_auto_cycle_start

    if (plan_get_current_block <> NULL) 
        ' Check if there are any blocks in the buffer.
        system_set_exec_state_flag(EXEC_CYCLE_START) ' If so, execute them!

' This function is the general interface to Grbl's real-time command execution system. It is called
' from various check points in the main program, primarily where there may be a repeat while loop waiting
' for a buffer to clear space or any point where the execution time from the last check point may
' be more than a fraction of a second. This is a way to execute realtime commands asynchronously
' (aka multitasking) with grbl's g-code parsing and planning functions. This function also serves
' as an interface for the interrupts to set the system realtime flags, where only the main program
' handles them, removing the need to define more computationally-expensive {CHECK_SCOPE}  variables. This
' also provides a controlled way to execute certain tasks without having two or more instances of
' the same task, such as the planner recalculating the buffer upon a feedhold or overrides.
' NOTE: The sys_rt_exec_state variable flags are set by any process, step or serial interrupts, pinouts,
' limit casees, or the main program.
PUB protocol_execute_realtime

    protocol_exec_rt_system
    if (sys.suspend) 
        protocol_exec_rt_suspend 

' Executes run-time commands, when required. This function primarily operates as Grbl's state
' machine and controls the various real-time features Grbl has to offer.
' NOTE: Do not alter this unless you know exactly what you are doing!
PUB protocol_exec_rt_system | {uint8_t} rt_exec, {uint8_t} new_f_override, new_r_override, last_s_override, coolant_state

    'byte rt_exec ' Temp variable to avoid calling volatile multiple times.
    rt_exec := sys_rt_exec_alarm ' Copy volatile sys_rt_exec_alarm.
    if (rt_exec)
        ' Enter only if any bit flag is true
        ' System alarm. Everything has shutdown by something that has gone severely wrong. Report
        ' the source of the error to the user. If critical, Grbl disables by entering an infinite
        ' loop until system reset/abort.
        sys.state := STATE_ALARM ' Set system alarm state
        report_alarm_message(rt_exec)
        ' Halt everything upon a critical event flag. Currently hard and soft limits flag this.
        if ((rt_exec == EXEC_ALARM_HARD_LIMIT) OR (rt_exec == EXEC_ALARM_SOFT_LIMIT)) 
            report_feedback_message(MESSAGE_CRITICAL_EVENT)
            system_clear_exec_state_flag(EXEC_RESET) ' Disable any existing reset
            repeat  'do 
            ' Block everything, except reset and status reports, until user issues reset or power
            ' cycles. Hard limits typically occur repeat while unattended or not paying attention. Gives
            ' the user and a GUI time to do what is needed before resetting, like killing the
            ' incoming stream. The same could be said about soft limits. While the position is not
            ' lost, continued streaming could cause a serious crash if by chance it gets executed.
            while (bit_isfalse(sys_rt_exec_state, EXEC_RESET))
        system_clear_exec_alarm ' Clear alarm

    rt_exec := sys_rt_exec_state ' Copy volatile sys_rt_exec_state.
    if (rt_exec)

        ' Execute system abort.
        if (rt_exec & EXEC_RESET) 
            sys.abort := true  ' Only place this is set true.
            return ' Nothing else to do but exit.

        ' Execute and serial print status
        if (rt_exec & EXEC_STATUS_REPORT) 
            report_realtime_status
            system_clear_exec_state_flag(EXEC_STATUS_REPORT)

        ' NOTE: Once hold is initiated, the system immediately enters a suspend state to block all
        ' main program processes until either reset or resumed. This ensures a hold completes safely.
        if (rt_exec & (EXEC_MOTION_CANCEL | EXEC_FEED_HOLD | EXEC_SAFETY_DOOR | EXEC_SLEEP)) 

            ' State check for allowable states for hold methods.
            if (NOT (sys.state & (STATE_ALARM | STATE_CHECK_MODE))) 
      
            ' If in CYCLE or JOG states, immediately initiate a motion HOLD.
                if (sys.state & (STATE_CYCLE | STATE_JOG)) 
                    if (NOT(sys.suspend & (SUSPEND_MOTION_CANCEL | SUSPEND_JOG_CANCEL))) 
                        ' Block, if already holding.
                        st_update_plan_block_parameters ' Notify stepper module to recompute for hold deceleration.
                        sys.step_control := STEP_CONTROL_EXECUTE_HOLD ' Initiate suspend state with active flag.
                        if (sys.state == STATE_JOG) 
                            ' Jog cancelled upon any hold event, except for sleeping.
                            if (NOT (rt_exec & EXEC_SLEEP)) 
                                sys.suspend |= SUSPEND_JOG_CANCEL  
                ' If IDLE, Grbl is not in motion. Simply indicate suspend state and hold is complete.
                if (sys.state == STATE_IDLE) 
                    sys.suspend := SUSPEND_HOLD_COMPLETE 

                ' Execute and flag a motion cancel with deceleration and return to idle. Used primarily by probing cycle
                ' to halt and cancel the remainder of the motion.
                if (rt_exec & EXEC_MOTION_CANCEL)    
                    ' MOTION_CANCEL only occurs during a CYCLE, but a HOLD and SAFETY_DOOR may been initiated beforehand
                    ' to hold the CYCLE. Motion cancel is valid for a single planner block motion only, repeat while jog cancel
                    ' will handle and clear multiple planner block motions.
                    if (NOT(sys.state & STATE_JOG)) 
                        sys.suspend |= SUSPEND_MOTION_CANCEL  ' NOTE: State is STATE_CYCLE.

            ' Execute a feed hold with deceleration, if required. Then, suspend system.
                if (rt_exec & EXEC_FEED_HOLD)
                    ' Block SAFETY_DOOR, JOG, and SLEEP states from changing to HOLD state.
                    if (NOT(sys.state & (STATE_SAFETY_DOOR | STATE_JOG | STATE_SLEEP))) 
                        sys.state := STATE_HOLD 

                ' Execute a safety door stop with a feed hold and disable spindle/coolant.
                ' NOTE: Safety door differs from feed holds by stopping everything no matter state, disables powered
                ' devices (spindle/coolant), and blocks resuming until case is re-engaged.
                if (rt_exec & EXEC_SAFETY_DOOR) 
                    report_feedback_message(MESSAGE_SAFETY_DOOR_AJAR)
                    ' If jogging, block safety door methods until jog cancel is complete. Just flag that it happened.
                    if (NOT(sys.suspend & SUSPEND_JOG_CANCEL)) 
                        ' Check if the safety re-opened during a restore parking motion only. Ignore if
                        ' already retracting, parked or in sleep state.
                        if (sys.state == STATE_SAFETY_DOOR) 
                            if (sys.suspend & SUSPEND_INITIATE_RESTORE) ' Actively restoring
#ifdef PARKING_ENABLE
                                ' Set hold and reset appropriate control flags to restart parking sequence.
                                if (sys.step_control & STEP_CONTROL_EXECUTE_SYS_MOTION) 
                                    st_update_plan_block_parameters ' Notify stepper module to recompute for hold deceleration.
                                    sys.step_control := (STEP_CONTROL_EXECUTE_HOLD | STEP_CONTROL_EXECUTE_SYS_MOTION)
                                    sys.suspend &= !(SUSPEND_HOLD_COMPLETE)
                                    ' else NO_MOTION is active.
#endif
                            sys.suspend &= !(SUSPEND_RETRACT_COMPLETE | SUSPEND_INITIATE_RESTORE | SUSPEND_RESTORE_COMPLETE)
                            sys.suspend |= SUSPEND_RESTART_RETRACT

                        if (sys.state <> STATE_SLEEP) 
                            sys.state:= STATE_SAFETY_DOOR 
                    ' NOTE: This flag doesn't change when the door closes, unlike sys.state. Ensures any parking motions
                    ' are executed if the door case closes and the state returns to HOLD.
                    sys.suspend |= SUSPEND_SAFETY_DOOR_AJAR

            if (rt_exec & EXEC_SLEEP) 
                if (sys.state == STATE_ALARM) 
                    sys.suspend |= (SUSPEND_RETRACT_COMPLETE|SUSPEND_HOLD_COMPLETE) 
                    sys.state := STATE_SLEEP 

            system_clear_exec_state_flag((EXEC_MOTION_CANCEL | EXEC_FEED_HOLD | EXEC_SAFETY_DOOR | EXEC_SLEEP))

        ' Execute a cycle start by starting the stepper interrupt to begin executing the blocks in queue.
        if (rt_exec & EXEC_CYCLE_START) 
            ' Block if called at same time as the hold commands: feed hold, motion cancel, and safety door.
            ' Ensures auto-cycle-start doesn't resume a hold without an explicit user-input.
            if (NOT(rt_exec & (EXEC_FEED_HOLD | EXEC_MOTION_CANCEL | EXEC_SAFETY_DOOR))) 
                ' Resume door state when parking motion has retracted and door has been closed.
                if ((sys.state == STATE_SAFETY_DOOR) AND NOT(sys.suspend & SUSPEND_SAFETY_DOOR_AJAR)) 
                    if (sys.suspend & SUSPEND_RESTORE_COMPLETE) 
                        sys.state := STATE_IDLE ' Set to IDLE to immediately resume the cycle.
                    elseif (sys.suspend & SUSPEND_RETRACT_COMPLETE) 
                        ' Flag to re-energize powered components and restore original position, if disabled by SAFETY_DOOR.
                        ' NOTE: For a safety door to resume, the case must be closed, as indicated by HOLD state, and
                        ' the retraction execution is complete, which implies the initial feed hold is not active. To
                        ' restore normal operation, the restore procedures must be initiated by the following flag. Once,
                        ' they are complete, it will call CYCLE_START automatically to resume and exit the suspend.
                        sys.suspend |= SUSPEND_INITIATE_RESTORE
                ' Cycle start only when IDLE or when a hold is complete and ready to resume.
                if ((sys.state == STATE_IDLE) OR ((sys.state & STATE_HOLD) AND (sys.suspend & SUSPEND_HOLD_COMPLETE))) 
                    if (sys.state == STATE_HOLD AND sys.spindle_stop_ovr)
                        sys.spindle_stop_ovr |= SPINDLE_STOP_OVR_RESTORE_CYCLE ' Set to restore in suspend routine and cycle start after.
                    else
                        ' Start cycle only if queued motions exist in planner buffer and the motion is not canceled.
                        sys.step_control := STEP_CONTROL_NORMAL_OP ' Restore step control to normal operation
                        if (plan_get_current_block AND bit_isfalse(sys.suspend,SUSPEND_MOTION_CANCEL)) 
                            sys.suspend := SUSPEND_DISABLE ' Break suspend state.
                            sys.state:= STATE_CYCLE
                            st_prep_buffer ' Initialize step segment buffer before beginning cycle.
                            st_wake_up
                        else 
                            ' Otherwise, do nothing. Set and resume IDLE state.
                            sys.suspend:= SUSPEND_DISABLE ' Break suspend state.
                            sys.state:= STATE_IDLE

            system_clear_exec_state_flag(EXEC_CYCLE_START)

        if (rt_exec & EXEC_CYCLE_STOP)
            ' Reinitializes the cycle plan and stepper system after a feed hold for a resume. Called by
            ' realtime command execution in the main program, ensuring that the planner re-plans safely.
            ' NOTE: Bresenham algorithm variables are still maintained through both the planner and stepper
            ' cycle reinitializations. The stepper path should continue exactly as if nothing has happened.
            ' NOTE: EXEC_CYCLE_STOP is set by the stepper subsystem when a cycle or feed hold completes.
            if ((sys.state & (STATE_HOLD|STATE_SAFETY_DOOR|STATE_SLEEP)) AND NOT(sys.soft_limit) AND NOT(sys.suspend & SUSPEND_JOG_CANCEL))
                ' Hold complete. Set to indicate ready to resume.  Remain in HOLD or DOOR states until user
                ' has issued a resume command or reset.
                plan_cycle_reinitialize
                if (sys.step_control & STEP_CONTROL_EXECUTE_HOLD) 
                    sys.suspend |= SUSPEND_HOLD_COMPLETE 
                bit_false(sys.step_control,(STEP_CONTROL_EXECUTE_HOLD | STEP_CONTROL_EXECUTE_SYS_MOTION))
            else 
                ' Motion complete. Includes CYCLE/JOG/HOMING states and jog cancel/motion cancel/soft limit events.
                ' NOTE: Motion and jog cancel both immediately return to idle after the hold completes.
                if (sys.suspend & SUSPEND_JOG_CANCEL) 
                    ' For jog cancel, flush buffers and sync positions.
                    sys.step_control:= STEP_CONTROL_NORMAL_OP
                    plan_reset
                    st_reset
                    gc_sync_position
                    plan_sync_position
                if (sys.suspend & SUSPEND_SAFETY_DOOR_AJAR) 
                    ' Only occurs when safety door opens during jog.
                    sys.suspend &= !(SUSPEND_JOG_CANCEL)
                    sys.suspend |= SUSPEND_HOLD_COMPLETE
                    sys.state := STATE_SAFETY_DOOR
                else 
                    sys.suspend := SUSPEND_DISABLE
                    sys.state := STATE_IDLE
            system_clear_exec_state_flag(EXEC_CYCLE_STOP)

    ' Execute overrides.
    rt_exec := sys_rt_exec_motion_override ' Copy volatile sys_rt_exec_motion_override
    if (rt_exec) 
        system_clear_exec_motion_overrides ' Clear all motion override flags.

        new_f_override := sys.f_override
        if (rt_exec & EXEC_FEED_OVR_RESET) 
            new_f_override := DEFAULT_FEED_OVERRIDE 
        if (rt_exec & EXEC_FEED_OVR_COARSE_PLUS) 
            new_f_override += FEED_OVERRIDE_COARSE_INCREMENT 
        if (rt_exec & EXEC_FEED_OVR_COARSE_MINUS) 
            new_f_override -= FEED_OVERRIDE_COARSE_INCREMENT 
        if (rt_exec & EXEC_FEED_OVR_FINE_PLUS) 
            new_f_override += FEED_OVERRIDE_FINE_INCREMENT 
        if (rt_exec & EXEC_FEED_OVR_FINE_MINUS) 
            new_f_override -= FEED_OVERRIDE_FINE_INCREMENT 
        new_f_override := min(new_f_override, MAX_FEED_RATE_OVERRIDE)
        new_f_override := max(new_f_override, MIN_FEED_RATE_OVERRIDE)

        new_r_override := sys.r_override
        if (rt_exec & EXEC_RAPID_OVR_RESET) 
            new_r_override:= DEFAULT_RAPID_OVERRIDE 
        if (rt_exec & EXEC_RAPID_OVR_MEDIUM) 
            new_r_override:= RAPID_OVERRIDE_MEDIUM 
        if (rt_exec & EXEC_RAPID_OVR_LOW) 
            new_r_override:= RAPID_OVERRIDE_LOW 

        if ((new_f_override <> sys.f_override) OR (new_r_override <> sys.r_override)) 
            sys.f_override := new_f_override
            sys.r_override := new_r_override
            sys.report_ovr_counter := 0 ' Set to report change immediately
            plan_update_velocity_profile_parameters
            plan_cycle_reinitialize

    rt_exec := sys_rt_exec_accessory_override
    if (rt_exec)
        system_clear_exec_accessory_overrides ' Clear all accessory override flags.

        ' NOTE: Unlike motion overrides, spindle overrides do not require a planner reinitialization.
        last_s_override := sys.spindle_speed_ovr
        if (rt_exec & EXEC_SPINDLE_OVR_RESET) 
            last_s_override:= DEFAULT_SPINDLE_SPEED_OVERRIDE 
        if (rt_exec & EXEC_SPINDLE_OVR_COARSE_PLUS) 
            last_s_override += SPINDLE_OVERRIDE_COARSE_INCREMENT 
        if (rt_exec & EXEC_SPINDLE_OVR_COARSE_MINUS) 
            last_s_override -= SPINDLE_OVERRIDE_COARSE_INCREMENT 
        if (rt_exec & EXEC_SPINDLE_OVR_FINE_PLUS) 
            last_s_override += SPINDLE_OVERRIDE_FINE_INCREMENT 
        if (rt_exec & EXEC_SPINDLE_OVR_FINE_MINUS) 
            last_s_override -= SPINDLE_OVERRIDE_FINE_INCREMENT 
        last_s_override := min(last_s_override,MAX_SPINDLE_SPEED_OVERRIDE)
        last_s_override := max(last_s_override,MIN_SPINDLE_SPEED_OVERRIDE)

        if (last_s_override <> sys.spindle_speed_ovr) 
            sys.spindle_speed_ovr := last_s_override
            ' NOTE: Spindle speed overrides during HOLD state are taken care of by suspend function.
            if (sys.state == STATE_IDLE) 
                spindle_set_state(gc_state.modal.spindle, gc_state.spindle_speed) 
			else 
                bit_true(sys.step_control, STEP_CONTROL_UPDATE_SPINDLE_PWM) 
            sys.report_ovr_counter := 0 ' Set to report change immediately

        if (rt_exec & EXEC_SPINDLE_OVR_STOP) 
            ' Spindle stop override allowed only repeat while in HOLD state.
            ' NOTE: Report counters are set in spindle_set_state when spindle stop is executed.
            if (sys.state== STATE_HOLD) 
                if (NOT (sys.spindle_stop_ovr)) 
                    sys.spindle_stop_ovr := SPINDLE_STOP_OVR_INITIATE 
                elseif (sys.spindle_stop_ovr & SPINDLE_STOP_OVR_ENABLED) 
                    sys.spindle_stop_ovr |= SPINDLE_STOP_OVR_RESTORE 

    ' NOTE: Since coolant state always performs a planner sync whenever it changes, the current
    ' run state can be determined by checking the parser state.
    ' NOTE: Coolant overrides only operate during IDLE, CYCLE, HOLD, and JOG states. Ignored otherwise.
        if (rt_exec & (EXEC_COOLANT_FLOOD_OVR_TOGGLE | EXEC_COOLANT_MIST_OVR_TOGGLE)) 
            if ((sys.state == STATE_IDLE) OR (sys.state & (STATE_CYCLE | STATE_HOLD | STATE_JOG))) 
                coolant_state := gc_state.modal.coolant
#ifdef ENABLE_M7
                if (rt_exec & EXEC_COOLANT_MIST_OVR_TOGGLE) 
                    if (coolant_state & COOLANT_MIST_ENABLE) 
                        bit_false(coolant_state,COOLANT_MIST_ENABLE) 
                    else 
                        coolant_state |= COOLANT_MIST_ENABLE 
                if (rt_exec & EXEC_COOLANT_FLOOD_OVR_TOGGLE) 
                    if (coolant_state & COOLANT_FLOOD_ENABLE) 
                        bit_false(coolant_state,COOLANT_FLOOD_ENABLE) 
                    else
                        coolant_state |= COOLANT_FLOOD_ENABLE 
#else
                if (coolant_state & COOLANT_FLOOD_ENABLE) 
                    bit_false(coolant_state,COOLANT_FLOOD_ENABLE) 
                else
                    coolant_state |= COOLANT_FLOOD_ENABLE
#endif
                coolant_set_state(coolant_state) ' Report counter set in coolant_set_state.
                gc_state.modal.coolant := coolant_state

#ifdef DEBUG
    if (sys_rt_exec_debug) 
        report_realtime_debug
        sys_rt_exec_debug := 0
#endif

    ' Reload step segment buffer
    if (sys.state & (STATE_CYCLE | STATE_HOLD | STATE_SAFETY_DOOR | STATE_HOMING | STATE_SLEEP| STATE_JOG)) 
        st_prep_buffer

' Handles Grbl system suspend procedures, such as feed hold, safety door, and parking motion.
' The system will enter this loop, create local variables for suspend tasks, and return to
' whatever function that invoked the suspend, such that Grbl resumes normal operation.
' This function is written in a way to promote custom parking motions. Simply use this as a
' template
PUB {static void} protocol_exec_rt_suspend | {float} restore_target[N_AXIS], parking_target[N_AXIS], retract_waypoint, {plan_block_t *} block, {uint8_t} restore_condition

#ifdef PARKING_ENABLE
    ' Declare and initialize parking local variables
    retract_waypoint := PARKING_PULLOUT_INCREMENT
'    plan_line_data_t plan_data
'    plan_line_data_t *pl_data:= @plan_data
    bytefill(pl_data, 0, {sizeof}plan_line_data_t)
    pl_data->condition := (PL_COND_FLAG_SYSTEM_MOTION|PL_COND_FLAG_NO_FEED_OVERRIDE)
#ifdef USE_LINE_NUMBERS
    pl_data->line_number := PARKING_MOTION_LINE_NUMBER
#endif
#endif

    {plan_block_t *}block:= plan_get_current_block
#ifdef VARIABLE_SPINDLE
    if (block == NULL)
        restore_condition := (gc_state.modal.spindle | gc_state.modal.coolant)
        restore_spindle_speed:= gc_state.spindle_speed
    else
        restore_condition := (block->condition & PL_COND_SPINDLE_MASK) | coolant_get_state
        restore_spindle_speed := block->spindle_speed
#ifdef DISABLE_LASER_DURING_HOLD
    if (util.bit_istrue(settings.flags, BITFLAG_LASER_MODE)) 
        system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_STOP)
#endif
#else
    if (block == NULL)
        restore_condition := (gc_state.modal.spindle | gc_state.modal.coolant)
    else
        restore_condition := (block->condition & PL_COND_SPINDLE_MASK) | coolant_get_state
#endif
    repeat while (sys.suspend)
        if (sys.abort)
            return

    ' Block until initial hold is complete and the machine has stopped motion.
        if (sys.suspend & SUSPEND_HOLD_COMPLETE)

            ' Parking manager. Handles de/re-energizing, case state checks, and parking motions for 
            ' the safety door and sleep states.
            if (sys.state & (STATE_SAFETY_DOOR | STATE_SLEEP))
                ' Handles retraction motions and de-energizing.
                if (bit_isfalse(sys.suspend, SUSPEND_RETRACT_COMPLETE))
                    ' Ensure any prior spindle stop override is disabled at start of safety door routine.
                    sys.spindle_stop_ovr := SPINDLE_STOP_OVR_DISABLED
#ifndef PARKING_ENABLE
                    spindle_set_state(SPINDLE_DISABLE, 0.0) ' De-energize
                    coolant_set_state(COOLANT_DISABLE)     ' De-energize
#else
                    ' Get current position and store restore location and spindle retract waypoint.
                    system_convert_array_steps_to_mpos(parking_target, sys_position)
                    if (bit_isfalse(sys.suspend, SUSPEND_RESTART_RETRACT)) 
                        memcpy(restore_target, parking_target, {sizeof(}parking_target)
                        retract_waypoint += restore_target[PARKING_AXIS]
                        retract_waypoint := min(retract_waypoint,PARKING_AXIS_TARGET)

                    ' Execute slow pull-out parking retract motion. Parking requires homing enabled, the
                    ' current location not exceeding the parking target location, and laser mode disabled.
                    ' NOTE: State is will remain DOOR, until the de-energizing and retract is complete.
#ifdef ENABLE_PARKING_OVERRIDE_CONTROL
                    if ((util.bit_istrue(settings.flags, BITFLAG_HOMING_ENABLE)) AND (parking_target[PARKING_AXIS] < PARKING_AXIS_TARGET) AND bit_isfalse(settings.flags,BITFLAG_LASER_MODE) AND (sys.override_ctrl == OVERRIDE_PARKING_MOTION))
#else
                    if ((util.bit_istrue(settings.flags, BITFLAG_HOMING_ENABLE)) AND (parking_target[PARKING_AXIS] < PARKING_AXIS_TARGET) AND bit_isfalse(settings.flags, BITFLAG_LASER_MODE))
#endif
                        ' Retract spindle by pullout distance. Ensure retraction motion moves away from
                        ' the workpiece and waypoint motion doesn't exceed the parking target location.
                        if (parking_target[PARKING_AXIS] < retract_waypoint) 
                            parking_target[PARKING_AXIS] := retract_waypoint
                            pl_data->feed_rate := PARKING_PULLOUT_RATE
                            pl_data->condition |= (restore_condition & PL_COND_ACCESSORY_MASK) ' Retain accessory state
                            pl_data->spindle_speed := restore_spindle_speed
                            mc_parking_motion(parking_target, pl_data)

                        ' NOTE: Clear accessory state after retract and after an aborted restore motion.
                        pl_data->condition := (PL_COND_FLAG_SYSTEM_MOTION|PL_COND_FLAG_NO_FEED_OVERRIDE)
                        pl_data->spindle_speed := 0.0
                        spindle_set_state(SPINDLE_DISABLE, 0.0) ' De-energize
                        coolant_set_state(COOLANT_DISABLE) ' De-energize

                        ' Execute fast parking retract motion to parking target location.
                        if (parking_target[PARKING_AXIS] < PARKING_AXIS_TARGET)
                            parking_target[PARKING_AXIS] := PARKING_AXIS_TARGET
                            pl_data->feed_rate:= PARKING_RATE
                            mc_parking_motion(parking_target, pl_data)
                    else
                            ' Parking motion not possible. Just disable the spindle and coolant.
                            ' NOTE: Laser mode does not start a parking motion to ensure the laser stops immediately.
                        spindle_set_state(SPINDLE_DISABLE,0.0) ' De-energize
                        coolant_set_state(COOLANT_DISABLE)     ' De-energize
#endif

                    sys.suspend &= !(SUSPEND_RESTART_RETRACT)
                    sys.suspend |= SUSPEND_RETRACT_COMPLETE
                else 
                    if (sys.state == STATE_SLEEP) 
                        report_feedback_message(MESSAGE_SLEEP_MODE)
                        ' Spindle and coolant should already be stopped, but do it again just to be sure.
                        spindle_set_state(SPINDLE_DISABLE,0.0) ' De-energize
                        coolant_set_state(COOLANT_DISABLE) ' De-energize
                        st_go_idle ' Disable steppers
                        repeat while (NOT(sys.abort)) 
                            protocol_exec_rt_system  ' Do nothing until reset.
                        return ' Abort received. Return to re-initialize.
          ' Allows resuming from parking/safety door. Actively checks if safety door is closed and ready to resume.
                    if (sys.state == STATE_SAFETY_DOOR) 
                        if (NOT(system_check_safety_door_ajar)) 
                            sys.suspend &= !(SUSPEND_SAFETY_DOOR_AJAR) ' Reset door ajar flag to denote ready to resume.

                    ' Handles parking restore and safety door resume.
                    if (sys.suspend & SUSPEND_INITIATE_RESTORE) 
#ifdef PARKING_ENABLE
                        ' Execute fast restore motion to the pull-out position. Parking requires homing enabled.
                        ' NOTE: State is will remain DOOR, until the de-energizing and retract is complete.
#ifdef ENABLE_PARKING_OVERRIDE_CONTROL
                        if (((settings.flags & (BITFLAG_HOMING_ENABLE|BITFLAG_LASER_MODE)) == BITFLAG_HOMING_ENABLE) AND (sys.override_ctrl == OVERRIDE_PARKING_MOTION))
#else
                        if ((settings.flags & (BITFLAG_HOMING_ENABLE|BITFLAG_LASER_MODE)) == BITFLAG_HOMING_ENABLE)
#endif
                            ' Check to ensure the motion doesn't move below pull-out position.
                            if (parking_target[PARKING_AXIS] =< PARKING_AXIS_TARGET)
                                parking_target[PARKING_AXIS] := retract_waypoint
                                pl_data->feed_rate := PARKING_RATE
                                mc_parking_motion(parking_target, pl_data)
#endif

                        ' Delayed Tasks: Restart spindle and coolant, delay to power-up, then resume cycle.
                        if (gc_state.modal.spindle <> SPINDLE_DISABLE) 
                            ' Block if safety door re-opened during prior restore actions.
                            if (bit_isfalse(sys.suspend,SUSPEND_RESTART_RETRACT)) 
                                if (util.bit_istrue(settings.flags,BITFLAG_LASER_MODE)) 
                                    ' When in laser mode, ignore spindle spin-up delay. Set to turn on laser when cycle starts.
                                    bit_true(sys.tep_control, STEP_CONTROL_UPDATE_SPINDLE_PWM)
                                else
                                    spindle_set_state((restore_condition & (PL_COND_FLAG_SPINDLE_CW | PL_COND_FLAG_SPINDLE_CCW)), restore_spindle_speed)
                                    delay_sec(SAFETY_DOOR_SPINDLE_DELAY, DELAY_MODE_SYS_SUSPEND)
                        if (gc_state.modal.coolant <> COOLANT_DISABLE)
                            ' Block if safety door re-opened during prior restore actions.
                            if (bit_isfalse(sys.suspend,SUSPEND_RESTART_RETRACT)) 
                                ' NOTE: Laser mode will honor this delay. An exhaust system is often controlled by this pin.
                                coolant_set_state((restore_condition & (PL_COND_FLAG_COOLANT_FLOOD | PL_COND_FLAG_COOLANT_MIST)))
                                delay_sec(SAFETY_DOOR_COOLANT_DELAY, DELAY_MODE_SYS_SUSPEND)

#ifdef PARKING_ENABLE
                    ' Execute slow plunge motion from pull-out position to resume position.
#ifdef ENABLE_PARKING_OVERRIDE_CONTROL
                        if (((settings.flags & (BITFLAG_HOMING_ENABLE|BITFLAG_LASER_MODE)) == BITFLAG_HOMING_ENABLE) AND (sys.override_ctrl== OVERRIDE_PARKING_MOTION))
#else
                        if ((settings.flags & (BITFLAG_HOMING_ENABLE|BITFLAG_LASER_MODE)) == BITFLAG_HOMING_ENABLE)
#endif
                            ' Block if safety door re-opened during prior restore actions.
                            if (bit_isfalse(sys.suspend, SUSPEND_RESTART_RETRACT)) 
                                ' Regardless if the retract parking motion was a valid/safe motion or not, the
                                ' restore parking motion should logically be valid, either by returning to the
                                ' original position through valid machine space or by not moving at all.
                                pl_data->feed_rate := PARKING_PULLOUT_RATE
    							pl_data->condition |= (restore_condition & PL_COND_ACCESSORY_MASK) ' Restore accessory state
    							pl_data->spindle_speed:= restore_spindle_speed
                                mc_parking_motion(restore_target, pl_data)
#endif
                    if (bit_isfalse(sys.suspend,SUSPEND_RESTART_RETRACT))
                        sys.suspend |= SUSPEND_RESTORE_COMPLETE
                        system_set_exec_state_flag(EXEC_CYCLE_START) ' Set to resume program.
            else

                ' Feed hold manager. Controls spindle stop override states.
                ' NOTE: Hold ensured as completed by condition check at the beginning of suspend routine.
                if (sys.spindle_stop_ovr)
                    ' Handles beginning of spindle stop
                    if (sys.spindle_stop_ovr & SPINDLE_STOP_OVR_INITIATE)
                        if (gc_state.modal.spindle <> SPINDLE_DISABLE)
                            spindle_set_state(SPINDLE_DISABLE,0.0) ' De-energize
                            sys.spindle_stop_ovr := SPINDLE_STOP_OVR_ENABLED ' Set stop override state to enabled, if de-energized.
                        else
                            sys.spindle_stop_ovr := SPINDLE_STOP_OVR_DISABLED ' Clear stop override state
                    ' Handles restoring of spindle state
                    elseif (sys.spindle_stop_ovr & (SPINDLE_STOP_OVR_RESTORE | SPINDLE_STOP_OVR_RESTORE_CYCLE)) 
                        if (gc_state.modal.spindle <> SPINDLE_DISABLE) 
                            report_feedback_message(MESSAGE_SPINDLE_RESTORE)
                            if (util.bit_istrue(settings.flags, BITFLAG_LASER_MODE)) 
                                ' When in laser mode, ignore spindle spin-up delay. Set to turn on laser when cycle starts.
                                bit_true(sys.step_control, STEP_CONTROL_UPDATE_SPINDLE_PWM)
                            else 
                                spindle_set_state((restore_condition & (PL_COND_FLAG_SPINDLE_CW | PL_COND_FLAG_SPINDLE_CCW)), restore_spindle_speed)
                        if (sys.spindle_stop_ovr & SPINDLE_STOP_OVR_RESTORE_CYCLE) 
                            system_set_exec_state_flag(EXEC_CYCLE_START)  ' Set to resume program.
                        sys.spindle_stop_ovr:= SPINDLE_STOP_OVR_DISABLED ' Clear stop override state
                else
                    ' Handles spindle state during hold. NOTE: Spindle speed overrides may be altered during hold state.
                    ' NOTE: STEP_CONTROL_UPDATE_SPINDLE_PWM is automatically reset upon resume in step generator.
                    if (util.bit_istrue(sys.step_control, STEP_CONTROL_UPDATE_SPINDLE_PWM)) 
                        spindle_set_state((restore_condition & (PL_COND_FLAG_SPINDLE_CW | PL_COND_FLAG_SPINDLE_CCW)), restore_spindle_speed)
                        bit_false(sys.step_control, STEP_CONTROL_UPDATE_SPINDLE_PWM)
            protocol_exec_rt_system

