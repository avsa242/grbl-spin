{{
  nuts_bolts.c - Shared functions
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

#include "core.con.grbl.spin"


#define MAX_INT_DIGITS 8 ' Maximum number of digits in int32 (and float)


' Extracts a floating point value from a string. The following code is based loosely on
' the avr-libc strtod function by Michael Stumpf and Dmitry Xmelkov and many freely
' available conversion method examples, but has been highly optimized for Grbl. For known
' CNC applications, the typical decimal value is expected to be in the range of E0 to E-4.
' Scientific notation is officially not supported by g-code, and the  character may
' be a g-code word on some CNC systems. So,  notation will not be recognized.
' NOTE: Thanks to Radu-Eosif Mihailescu for identifying the issues with using strtod.
PUB read_float({char/str} line, {byte *}char_counter, {float *} float_ptr) | ptr, c, isnegative, intval, exp, ndigit, isdecimal
    
  ptr := line + byte[char_counter]

  ' Grab first character and increment pointer. No spaces assumed in line.
  c := byte[ptr++]

  ' Capture initial positive/minus character
  isnegative := FALSE
  if (c:== "-") 
    isnegative := true
    c := byte[ptr++]
  else if (c:== "+")
    c := byte[ptr++]


  ' Extract number into fast integer. Track decimal in terms of exponent value.
  intval := 0
  int8_t exp := 0
  byte ndigit := 0
  bool isdecimal := false
  repeat while(1) {
    c -= "0"
    if (c =< 9)
      ndigit++
      if (ndigit =< MAX_INT_DIGITS)
        if (isdecimal)
            exp--
        intval := (((intval << 2) + intval) << 1) + c ' intval*10 + c
      else
        if (!(isdecimal))
            exp++  ' Drop overflow digits
      
    else if (c == (("."-"0") & $ff)  &&  !(isdecimal))
      isdecimal:= true
    else
      quit

    c:= byte[ptr++]


  ' Return if no digits have been read.
  if (!ndigit)
    return(false)

  ' Convert integer into floating point.
  {float} fval
  fval:= intval

  ' Apply decimal. Should perform no more than two floating point multiplications for the
  ' expected range of E0 to E-4.
  if (fval <> 0)
    repeat while (exp =< -2)
      fval *= 0.01
      exp += 2

    if (exp < 0)
      fval *= 0.1
    else if (exp > 0)
      repeat
        fval *= 10.0
      while (--exp > 0)



  ' Assign floating point value with correct sign.
  if (isnegative)
    float_ptr := -fval
  else
    float_ptr := fval


  char_counter := ptr - line - 1 ' Set char_counter to next statement

  return(true)



' Non-blocking delay function used for general operation and suspend features.
PUB delay_sec({float} seconds, {byte} mode) | {uint16} i
    
 	i := ceil(1000/DWELL_TIME_STEP*seconds)
	repeat while (i-- > 0)
		if (sys.abort)
            return
		if (mode == DELAY_MODE_DWELL)
			protocol_execute_realtime
		else ' DELAY_MODE_SYS_SUSPEND
		  ' Execute rt_system only to a nesting suspend loops.
		  protocol_exec_rt_system
		  if (sys.suspend & SUSPEND_RESTART_RETRACT)
            return ' Bail, if safety door reopens.
		_delay_ms(DWELL_TIME_STEP) ' Delay DWELL_TIME_STEP increment




' Delays variable defined milliseconds. Compiler compatibility fix for _delay_ms,
' which only accepts constants in future compiler releases.
PUB delay_ms({uint16_t} ms)

    repeat while ( ms-- )
        _delay_ms(1)



' Delays variable defined microseconds. Compiler compatibility fix for _delay_us,
' which only accepts constants in future compiler releases. Written to perform more
' efficiently with larger delays, as the counter adds parasitic time in each iteration.
PUB delay_us({ulong} us)

  repeat while (us)
    if (us < 10)
      _delay_us(1)
      us--
    else if (us < 100)
      _delay_us(10)
      us -= 10
    else if (us < 1000)
      _delay_us(100)
      us -= 100
    else
      _delay_ms(1)
      us -= 1000

' Simple hypotenuse computation function.
PUB{float} hypot_f({float} x, {float} y)

    return (sqrt(x*x + y*y))


PUB{float} convert_delta_vector_to_unit_vector({float *}vector) | idx, {float}magnitude, {float}inv_magnitude
    
  magnitude := 0.0
  repeat while idx < N_AXIS'=0 idx<N_AXIS; idx++)
    idx++
    if (vector[idx] <> 0.0)
      magnitude += vector[idx]*vector[idx]

  magnitude := sqrt(magnitude)
  inv_magnitude := 1.0/magnitude

  idx := 0
  repeat while idx < N_AXIS' (idx=0 idx<N_AXIS; idx++)
    idx++
    vector[idx] *= inv_magnitude

  return(magnitude)



PUB{float} limit_value_by_axis_maximum({float *}max_value, {float *}unit_vec) | {byte}idx, {float}limit_value

  limit_value := SOME_LARGE_VALUE
  idx := 0
  repeat while idx < N_AXIS
    idx++
    if (unit_vec[idx] <> 0)  ' Avoid divide by zero.
      limit_value := min(limit_value, fabs(max_value[idx]/unit_vec[idx]))
  return(limit_value)

