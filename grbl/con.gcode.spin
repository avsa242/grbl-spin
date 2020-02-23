{{
  gcode.h - rs274/ngc parser.
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

#ifndef gcode_h
#define gcode_h

CON
' Define modal group internal numbers for checking multiple command violations and tracking the
' type of command that is called in the block. A modal group is a group of g-code commands that are
' mutually exclusive, or cannot exist on the same line, because they each toggle a state or execute
' a unique motion. These are defined in the NIST RS274-NGC v3 g-code standard, available online,
' and are similar/identical to other g-code interpreters by manufacturers (Haas,Fanuc,Mazak,etc).
' NOTE: Modal group define values must be sequential and starting from zero.
    MODAL_GROUP_G0                      = 0 ' [G4,G10,G28,G28.1,G30,G30.1,G53,G92,G92.1] Non-modal
    MODAL_GROUP_G1                      = 1 ' [G0,G1,G2,G3,G38.2,G38.3,G38.4,G38.5,G80] Motion
    MODAL_GROUP_G2                      = 2 ' [G17,G18,G19] Plane selection
    MODAL_GROUP_G3                      = 3 ' [G90,G91] Distance mode
    MODAL_GROUP_G4                      = 4 ' [G91.1] Arc IJK distance mode
    MODAL_GROUP_G5                      = 5 ' [G93,G94] Feed rate mode
    MODAL_GROUP_G6                      = 6 ' [G20,G21] Units
    MODAL_GROUP_G7                      = 7 ' [G40] Cutter radius compensation mode. G41/42 NOT SUPPORTED.
    MODAL_GROUP_G8                      = 8 ' [G43.1,G49] Tool length offset
    MODAL_GROUP_G12                     = 9 ' [G54,G55,G56,G57,G58,G59] Coordinate system selection
    MODAL_GROUP_G13                     = 10 ' [G61] Control mode

    MODAL_GROUP_M4                      = 11  ' [M0,M1,M2,M30] Stopping
    MODAL_GROUP_M7                      = 12 ' [M3,M4,M5] Spindle turning
    MODAL_GROUP_M8                      = 13 ' [M7,M8,M9] Coolant control
    MODAL_GROUP_M9                      = 14 ' [M56] Override control

' Define command actions for within execution-type modal groups (motion, stopping, non-modal). Used
' internally by the parser to know which command to execute.
' NOTE: Some macro values are assigned specific values to make g-code state reporting and parsing 
' compile a litte smaller. Necessary due to being completely out of flash on the 328p. Although not
' ideal, just be careful with values that state  and check both report.c and gcode.c 
' to see how they are used, if you need to alter them.

' Modal Group G0: Non-modal actions
    NON_MODAL_NO_ACTION                 = 0 ' (Default: Must be zero)
    NON_MODAL_DWELL                     = 4 ' G4 (Do not alter value)
    NON_MODAL_SET_COORDINATE_DATA       = 10 ' G10 (Do not alter value)
    NON_MODAL_GO_HOME_0                 = 28 ' G28 (Do not alter value)
    NON_MODAL_SET_HOME_0                = 38 ' G28.1 (Do not alter value)
    NON_MODAL_GO_HOME_1                 = 30 ' G30 (Do not alter value)
    NON_MODAL_SET_HOME_1                = 40 ' G30.1 (Do not alter value)
    NON_MODAL_ABSOLUTE_OVERRIDE         = 53 ' G53 (Do not alter value)
    NON_MODAL_SET_COORDINATE_OFFSET     = 92 ' G92 (Do not alter value)
    NON_MODAL_RESET_COORDINATE_OFFSET   = 102 'G92.1 (Do not alter value)

' Modal Group G1: Motion modes
    MOTION_MODE_SEEK                    = 0 ' G0 (Default: Must be zero)
    MOTION_MODE_LINEAR                  = 1 ' G1 (Do not alter value)
    MOTION_MODE_CW_ARC                  = 2  ' G2 (Do not alter value)
    MOTION_MODE_CCW_ARC                 = 3  ' G3 (Do not alter value)
    MOTION_MODE_PROBE_TOWARD            = 140 ' G38.2 (Do not alter value)
    MOTION_MODE_PROBE_TOWARD_NO_ERROR   = 141 ' G38.3 (Do not alter value)
    MOTION_MODE_PROBE_AWAY              = 142 ' G38.4 (Do not alter value)
    MOTION_MODE_PROBE_AWAY_NO_ERROR     = 143 ' G38.5 (Do not alter value)
    MOTION_MODE_NONE                    = 80 ' G80 (Do not alter value)

' Modal Group G2: Plane select
    PLANE_SELECT_XY                     = 0 ' G17 (Default: Must be zero)
    PLANE_SELECT_ZX                     = 1 ' G18 (Do not alter value)
    PLANE_SELECT_YZ                     = 2 ' G19 (Do not alter value)

' Modal Group G3: Distance mode
    DISTANCE_MODE_ABSOLUTE              = 0 ' G90 (Default: Must be zero)
    DISTANCE_MODE_INCREMENTAL           = 1 ' G91 (Do not alter value)

' Modal Group G4: Arc IJK distance mode
    DISTANCE_ARC_MODE_INCREMENTAL       = 0 ' G91.1 (Default: Must be zero)

' Modal Group M4: Program flow
    PROGRAM_FLOW_RUNNING                = 0 ' (Default: Must be zero)
    PROGRAM_FLOW_PAUSED                 = 3 ' M0
    PROGRAM_FLOW_OPTIONAL_STOP          = 1 ' M1 NOTE: Not supported, but valid and ignored.
    PROGRAM_FLOW_COMPLETED_M2           = 2 ' M2 (Do not alter value)
    PROGRAM_FLOW_COMPLETED_M30          = 30 ' M30 (Do not alter value)

' Modal Group G5: Feed rate mode
    FEED_RATE_MODE_UNITS_PER_MIN        = 0 ' G94 (Default: Must be zero)
    FEED_RATE_MODE_INVERSE_TIME         = 1 ' G93 (Do not alter value)

' Modal Group G6: Units mode
    UNITS_MODE_MM                       = 0 ' G21 (Default: Must be zero)
    UNITS_MODE_INCHES                   = 1 ' G20 (Do not alter value)

' Modal Group G7: Cutter radius compensation mode
    CUTTER_COMP_DISABLE                 = 0 ' G40 (Default: Must be zero)

' Modal Group G13: Control mode
    CONTROL_MODE_EXACT_PATH             = 0 ' G61 (Default: Must be zero)

' Modal Group M7: Spindle control
    SPINDLE_DISABLE                     = 0 ' M5 (Default: Must be zero)
    SPINDLE_ENABLE_CW                   = PL_COND_FLAG_SPINDLE_CW ' M3 (NOTE: Uses planner condition bit flag)
    SPINDLE_ENABLE_CCW                  = PL_COND_FLAG_SPINDLE_CCW ' M4 (NOTE: Uses planner condition bit flag)

' Modal Group M8: Coolant control
    COOLANT_DISABLE                     = 0 ' M9 (Default: Must be zero)
    COOLANT_FLOOD_ENABLE                = PL_COND_FLAG_COOLANT_FLOOD ' M8 (NOTE: Uses planner condition bit flag)
    COOLANT_MIST_ENABLE                 = PL_COND_FLAG_COOLANT_MIST  ' M7 (NOTE: Uses planner condition bit flag)

' Modal Group G8: Tool length offset
    TOOL_LENGTH_OFFSET_CANCEL           = 0 ' G49 (Default: Must be zero)
    TOOL_LENGTH_OFFSET_ENABLE_DYNAMIC   = 1 ' G43.1

' Modal Group M9: Override control
#ifdef DEACTIVATE_PARKING_UPON_INIT
    OVERRIDE_DISABLED                   = 0 ' (Default: Must be zero)
    OVERRIDE_PARKING_MOTION             = 1 ' M56
#else
    OVERRIDE_PARKING_MOTION             = 0 ' M56 (Default: Must be zero)
    OVERRIDE_DISABLED                   = 1 ' Parking disabled.
#endif

' Modal Group G12: Active work coordinate system
' N/A: Stores coordinate system value (54-59) to change to.

' Define parameter word mapping.
    WORD_F                              = 0
    WORD_I                              = 1
    WORD_J                              = 2
    WORD_K                              = 3
    WORD_L                              = 4
    WORD_N                              = 5
    WORD_P                              = 6
    WORD_R                              = 7
    WORD_S                              = 8
    WORD_T                              = 9
    WORD_X                              = 10
    WORD_Y                              = 11
    WORD_Z                              = 12

' Define g-code parser position updating flags
    GC_UPDATE_POS_TARGET                = 0 ' Must be zero
    GC_UPDATE_POS_SYSTEM                = 1
    GC_UPDATE_POS_NONE                  = 2

' Define probe cycle exit states and assign proper position updating.
    GC_PROBE_FOUND                      = GC_UPDATE_POS_SYSTEM
    GC_PROBE_ABORT                      = GC_UPDATE_POS_NONE
    GC_PROBE_FAIL_INIT                  = GC_UPDATE_POS_NONE
    GC_PROBE_FAIL_END                   = GC_UPDATE_POS_TARGET
#ifdef SET_CHECK_MODE_PROBE_TO_START
    GC_PROBE_CHECK_MODE                 = GC_UPDATE_POS_NONE  
#else
    GC_PROBE_CHECK_MODE                 = GC_UPDATE_POS_TARGET
#endif

' Define gcode parser flags for handling special cases.
    GC_PARSER_NONE                      = 0 ' Must be zero.
    GC_PARSER_JOG_MOTION                = 1 << 0
    GC_PARSER_CHECK_MANTISSA            = 1 << 1
    GC_PARSER_ARC_IS_CLOCKWISE          = 1 << 2
    GC_PARSER_PROBE_IS_AWAY             = 1 << 3
    GC_PARSER_PROBE_IS_NO_ERROR         = 1 << 4
    GC_PARSER_LASER_FORCE_SYNC          = 1 << 5
    GC_PARSER_LASER_DISABLE             = 1 << 6
    GC_PARSER_LASER_ISMOTION            = 1 << 7

{{
' NOTE: When this struct is zeroed, the above defines set the defaults for the system.
typedef struct 
    
  byte motion          ' 
    G0,G1,G2,G3,G38.2,G80
  byte feed_rate       ' 
    G93,G94
  byte units           ' 
    G20,G21
  byte distance        ' 
    G90,G91
  ' byte distance_arc // 
    G91.1 NOTE: Don't track. Only default supported.
  byte plane_select    ' 
    G17,G18,G19
  ' byte cutter_comp  // 
    G40 NOTE: Don't track. Only default supported.
  byte tool_length     ' 
    G43.1,G49
  byte coord_select    ' 
    G54,G55,G56,G57,G58,G59
  ' byte control      // 
    G61 NOTE: Don't track. Only default supported.
  byte program_flow    ' 
    M0,M1,M2,M30
  byte coolant         ' 
    M7,M8,M9
  byte spindle         ' 
    M3,M4,M5
  byte override        ' 
    M56
 gc_modal_t
}}

{{
typedef struct 
    
  {float} f         ' Feed
  {float} ijk[3]    ' I,J,K Axis arc offsets
  byte l       ' G10 or canned cycles parameters
  long n       ' Line number
  {float} p         ' G10 or dwell parameters
  ' {float} q      // G82 peck drilling
  {float} r         ' Arc radius
  {float} s         ' Spindle speed
  byte t       ' Tool selection
  {float} xyz[3]    ' X,Y,Z Translational axes
 gc_values_t
}}

{{
typedef struct 
    
  gc_modal_t modal

  {float} spindle_speed          ' RPM
  {float} feed_rate              ' Millimeters/min
  byte tool                 ' Tracks tool number. NOT USED.
  long line_number          ' Last line number sent

  {float} position[N_AXIS]       ' Where the interpreter considers the tool to be at this point in the code

  {float} coord_system[N_AXIS]    ' Current work coordinate system (G54+). Stores offset from absolute machine
                                 ' position in mm. Loaded from EEPROM when called.
  {float} coord_offset[N_AXIS]    ' Retains the G92 coordinate offset (work coordinates) relative to
                                 ' machine zero in mm. Non-persistent. Cleared upon reset and boot.
  {float} tool_length_offset      ' Tracks tool length offset value when enabled.
 parser_state_t
}}
'extern parser_state_t gc_state

{{
typedef struct 
    
  byte non_modal_command
  gc_modal_t modal
  gc_values_t values
 parser_block_t
}}

#endif
