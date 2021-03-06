{
  main.c - An embedded CNC Controller with rs274/ngc (g-code) support
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
#define CPU_MAP_P8X32A

CON

    _clkmode    = xtal1 + pll16x
    _xinfreq    = 5_000_000

'    CLK_FREQ    = (_clkmode >> 6) * _xinfreq
    'F_CPU       = CLK_FREQ

#include "core.con.grbl.spin"
'#include "system_t.spin"

OBJ

    coolant         : "coolant_control.spin"
    eeprom          : "eeprom.spin"
    gcode           : "gcode.spin"
    jog             : "jog.spin"
    limits          : "limits.spin"
    motion_control  : "motion_control.spin"
    nuts_bolts      : "nuts_bolts.spin"
    planner         : "planner.spin"
    print           : "print.spin"
    probe           : "probe.spin"
    protocol        : "protocol.spin"
    report          : "report.spin"
    serial          : "serial.spin"
    settings        : "settings.spin"
    spindle_control : "spindle_control.spin"
    stepper         : "stepper.spin"
    system          : "system.spin"

VAR

    byte    sys[sizeof_system_t]                'system_t struct
    byte    pl_data[sizeof_plan_line_data_t]    'plan_line_data_t struct
    byte    gc_block[sizeof_parser_block_t]     'parser_block_t struct
    byte    values[sizeof_gc_values_t]          'gc_values_t struct

VAR

    ' Declare system global variable structure
'    system_t sys
    long sys_position[N_AXIS]      ' Real-time machine (aka home) position vector in steps.
    long sys_probe_position[N_AXIS] ' Last probe position in machine coordinates and steps.
    {void}  byte sys_probe_state   ' Probing state value.  Used to coordinate the probing cycle with stepper ISR.
    {void}  byte sys_rt_exec_state   ' Global realtime executor bitflag variable for state management. See EXEC bitmasks.
    {void}  byte sys_rt_exec_alarm   ' Global realtime executor bitflag variable for setting various alarms.
    {void}  byte sys_rt_exec_motion_override ' Global realtime executor bitflag variable for motion-based overrides.
    {void}  byte sys_rt_exec_accessory_override ' Global realtime executor bitflag variable for spindle/coolant overrides.
#ifdef DEBUG
    {void}  byte sys_rt_exec_debug
#endif

PUB Main | {uint8_t} prior_state

    ' Initialize system upon power-up.
    serial.serial_init   ' Setup serial baud rate and interrupts
    settings.settings_init ' Load Grbl settings from EEPROM
    stepper.stepper_init  ' Configure stepper pins and interrupt timers
    system.system_init   ' Configure pinout pins and pin-change interrupt

    bytefill(sys_position, 0, {sizeof}sys_position) ' Clear machine position.
    sei ' Enable interrupts       'XXX check how to implement this

    ' Initialize system state.
#ifdef FORCE_INITIALIZATION_ALARM
    ' Force Grbl into an ALARM state upon a power-cycle or hard reset.
    sys.state := STATE_ALARM
#else
    sys.state := STATE_IDLE
#endif
  
    ' Check for power-up and set system alarm if homing is enabled to force homing cycle
    ' by setting Grbl's alarm state. Alarm locks out all g-code commands, including the
    ' startup scripts, but allows access to settings and internal commands. Only a homing
    ' cycle '$H' or kill alarm locks '$X' will disable the alarm.
    ' NOTE: The startup script will run after successful completion of the homing cycle, but
    ' not after disabling the alarm locks. Prevents motion startup blocks from crashing into
    ' things uncontrollably. Very bad.
#ifdef HOMING_INIT_LOCK
    if (bit_istrue(settings.flags, BITFLAG_HOMING_ENABLE))
        sys.state := STATE_ALARM
#endif

    ' Grbl initialization loop upon power-up or a system abort. For the latter, all processes
    ' will return to this loop to be cleanly re-initialized.
    repeat

    ' Reset system variables.
        prior_state := sys.state
        bytefill(@sys, 0, {sizeof}system_t) ' Clear system struct variable.
        sys.state := prior_state
        sys.f_override := DEFAULT_FEED_OVERRIDE  ' Set to 100%
        sys.r_override := DEFAULT_RAPID_OVERRIDE ' Set to 100%
        sys.spindle_speed_ovr := DEFAULT_SPINDLE_SPEED_OVERRIDE ' Set to 100%
        bytefill(sys_probe_position, 0, {sizeof}sys_probe_position) ' Clear probe position.
        sys_probe_state := 0
        sys_rt_exec_state := 0
        sys_rt_exec_alarm := 0
        sys_rt_exec_motion_override := 0
        sys_rt_exec_accessory_override := 0

        ' Reset Grbl primary systems.
        serial_reset_read_buffer ' Clear serial read buffer
        gc_init ' Set g-code parser to default state
        spindle_init
        coolant.coolant_init
        limits_init
        probe_init
        plan_reset ' Clear block buffer and planner variables
        st_reset ' Clear stepper subsystem variables.

        ' Sync cleared gcode and planner positions to current system position.
        plan_sync_position
        gc_sync_position

        ' Print welcome message. Indicates an initialization has occured at power-up or with a reset.
        report_init_message

        ' Start Grbl main loop. Processes program inputs and executes them.
        protocol_main_loop

'    return 0   { Never reached }

