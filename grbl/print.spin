{{
  print.c - Functions for formatting output strings
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


PUB printString({const char *}s)

    repeat while ({*}s)
        serial_write({*}s++)

' Print a string stored in PGM-memory
PUB printPgmString({const char *}s) | {char} c

    repeat while ((c := pgm_read_byte_near(s++)))
        serial_write(c)

'  printIntegerInBase(unsigned long n, unsigned long base)
' 
    
' 	unsigned char buf[8 * sizeof(long)] // Assumes 8-bit chars.
' 	unsigned long i:= 0
'
' 	if (n== 0) 
    
' 		serial_write()
' 		return
' 	
'
' 	repeat while (n > 0) 
    
' 		buf[i++]:= n % base
' 		n /= base
' 	
'
' 	for ( i > 0; i--)
' 		serial_write(buf[i - 1] < 10 ?
' 			 + buf[i - 1] :
' 			 + buf[i - 1] - 10)
' 

' Prints an uint8 variable in base 10.
PUB print_uint8_base10({byte }n) | {byte} digit_a, digit_b

    
    digit_a:= 0
    digit_b:= 0
    if (n => 100) ' 100-255
        digit_a := "0" + n // 10
        n /= 10
  
    if (n => 10) ' 10-99
        digit_b := "0" + n // 10
        n /= 10
  
    serial_write("0" + n)
    if (digit_b) 
        serial_write(digit_b) 
    if (digit_a) 
        serial_write(digit_a) 

' Prints an uint8 variable in base 2 with desired number of desired digits.
PUB print_uint8_base2_ndigit({byte }n, {uint8_t }digits) | {unsigned char } buf[8], {byte} i
    
'  unsigned char buf[digits]    ' Can't do this in SPIN, so we allocate a local var with a capped number of digits, instead: 8 longs/32 bytes/32 digits
    repeat i from 0 to digits-1 
        buf.byte[i] := n // 2
        n /= 2

    repeat
        serial_write("0" + buf.byte[i - 1])
        i--
    while i > 0

PUB print_uint32_base10({ulong }n) | {byte} i, {unsigned char} buf[3]

    if (n== 0) 
        serial_write("0")
        return

    i := 0
    repeat while (n > 0) 
        buf[i++] := n // 10
        n /= 10

    repeat
        serial_write("0" + buf[i-1])
        i--
    while i > 0

PUB printInteger({long }n)

    if (n < 0) 
        serial_write("-")
        print_uint32_base10(-n)
    else 
        print_uint32_base10(n)

' Convert {float} to string by immediately converting to a long integer, which contains
' more digits than a float. Number of decimal places, which are tracked by a counter,
' may be set by the user. The integer is then efficiently converted to a string.
' NOTE: AVR  integer operations are very efficient. Bitshifting speed-up
' techniques are actually just slightly slower. Found this out the hard way.
PUB printFloat({float} n, {byte }decimal_places) | {byte}decimals, {unsigned char} buf[4], i, {ulong} a, {long} n

    if (n < 0)
        serial_write()
        n := -n
    decimals := decimal_places
    repeat while (decimals => 2) 
     ' Quickly convert values expected to be E0 to E-4.
        n *= 100
        decimals -= 2
    if (decimals) 
        n *= 10 
    n += 0.5 ' Add rounding factor. Ensures carryover through entire value.

    ' Generate digits backwards and store in string.
    i := 0
    a := n
    repeat while(a > 0) 
        buf[i++] := (a // 10) + "0" ' Get digit
        a /= 10

    repeat while (i < decimal_places) 
        buf[i++] := "0" ' Fill in zeros to decimal point for (n < 1)

    if (i== decimal_places) ' Fill in leading zero, if needed.
        buf[i++] := "0"

    ' Print the generated string.
    repeat
        if (i== decimal_places) 
            serial_write()  ' Insert decimal point in right place.
        serial_write(buf[i-1])
        i--
    while i > 0

' Floating value printing handlers for special variables types used in Grbl and are defined
' in the config.h.
'  - CoordValue: Handles all position or coordinate values in inches or mm reporting.
'  - RateValue: Handles feed rate and current velocity in inches or mm reporting.
PUB printFloat_CoordValue({float} n)

    if (bit_istrue(settings.flags, BITFLAG_REPORT_INCHES))
        printFloat(n * INCH_PER_MM, N_DECIMAL_COORDVALUE_INCH)
    else 
        printFloat(n, N_DECIMAL_COORDVALUE_MM)

PUB printFloat_RateValue({float} n)

    if (bit_istrue(settings.flags, BITFLAG_REPORT_INCHES)) 
        printFloat(n * INCH_PER_MM, N_DECIMAL_RATEVALUE_INCH)
    else 
        printFloat(n, N_DECIMAL_RATEVALUE_MM)

' Debug tool to print free memory in bytes at the called point.
' NOTE: Keep commented unless using. Part of this function always gets compiled in.
'  printFreeMemory
' 
    
'   extern int __heap_start, *__brkval
'   uint16_t free  // Up to 64k values.
'   free:= (int) &free - (__brkval == 0 ? (int) &__heap_start : (int) __brkval)
'   printInteger((long)free)
'   printString(" ")
' 
