{{
  serial.c - Low level functions for sending and recieving bytes via the serial port
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
#include "con.serial.spin"

CON

    RX_RING_BUFFER                          = (RX_BUFFER_SIZE + 1)
    TX_RING_BUFFER                          = (TX_BUFFER_SIZE + 1)
    
'    F_CPU = 1
VAR
    byte {uint8_t} serial_rx_buffer[RX_RING_BUFFER]
    byte {uint8_t} serial_rx_buffer_head ':= 0              ' DAT vars instead? initialized values...
    byte {volatile uint8_t} serial_rx_buffer_tail ':= 0

    byte {uint8_t} serial_tx_buffer[TX_RING_BUFFER]
    byte {uint8_t} serial_tx_buffer_head ' := 0
    byte {volatile uint8_t} serial_tx_buffer_tail ':= 0

' Returns the number of bytes available in the RX serial buffer.
PUB{uint8_t} serial_get_rx_buffer_available | {uint8_t} rtail

    rtail := serial_rx_buffer_tail ' Copy to limit multiple calls to {CHECK_SCOPE} 
    if (serial_rx_buffer_head => rtail)
        return(RX_BUFFER_SIZE - (serial_rx_buffer_head-rtail))
    return((rtail-serial_rx_buffer_head-1))

' Returns the number of bytes used in the RX serial buffer.
' NOTE: Deprecated. Not used unless classic status reports are enabled in config.h.
PUB{uint8_t} serial_get_rx_buffer_count | {uint8_t} rtail

    rtail := serial_rx_buffer_tail ' Copy to limit multiple calls to volatile
    if (serial_rx_buffer_head => rtail)
        return(serial_rx_buffer_head-rtail)
    return (RX_BUFFER_SIZE - (rtail-serial_rx_buffer_head))

' Returns the number of bytes used in the TX serial buffer.
' NOTE: Not used except for debugging and ensuring no TX bottlenecks.
PUB serial_get_tx_buffer_count | {uint8_t} ttail

    ttail := serial_tx_buffer_tail ' Copy to limit multiple calls to volatile
    if (serial_tx_buffer_head => ttail)
        return(serial_tx_buffer_head-ttail)
    return (TX_RING_BUFFER - (ttail-serial_tx_buffer_head))

PUB serial_init | {uint16_t} UBRR0_value, UCSR0A, UBRR0H, UBRR0L, UCSR0B, RXEN0, TXEN0, RXCIE0, U2X0
'XXX hardware specific bits
    ' Set baud rate
    if BAUD_RATE < 57600
        UBRR0_value := ((F_CPU / (8{L} * BAUD_RATE)) - 1)/2
        UCSR0A &= !(1 << U2X0) ' baud doubler off  - Only needed on Uno XXX
    else
        UBRR0_value := ((F_CPU / (4{L} * BAUD_RATE)) - 1)/2
        UCSR0A |= (1 << U2X0)  ' baud doubler on for high baud rates, i.e. 115200

    UBRR0H:= UBRR0_value >> 8
    UBRR0L:= UBRR0_value

    ' enable rx, tx, and interrupt on complete reception of a byte
    UCSR0B |= (1<<RXEN0 | 1<<TXEN0 | 1<<RXCIE0)

    ' defaults to 8-bit, no parity, 1 stop bit

' Writes one byte to the TX serial buffer. Called by main program.
PUB serial_write({uint8_t} data) | {uint8_t} next_head, UCSR0B, UDRIE0

    ' Calculate next head
    next_head := serial_tx_buffer_head + 1
    if (next_head == TX_RING_BUFFER)
        next_head := 0

    ' Wait until there is space in the buffer
    repeat while (next_head == serial_tx_buffer_tail)
        ' TODO: Restructure st_prep_buffer calls to be executed here during a long print.
        if (sys_rt_exec_state & EXEC_RESET)
            return  ' Only check for abort to a an endless loop.

    ' Store data and advance head
    serial_tx_buffer[serial_tx_buffer_head] := data
    serial_tx_buffer_head := next_head

    ' Enable Data Register Empty Interrupt to make sure tx-streaming is running
    UCSR0B |=  (1 << UDRIE0)

' Data Register Empty Interrupt handler
PUB ISR_DRE(SERIAL_UDRE) | {uint8_t} tail, UCSR0B, UDR0, UDRIE0

    tail := serial_tx_buffer_tail ' Temporary serial_tx_buffer_tail (to optimize for {CHECK_SCOPE} )

    ' Send a byte from the buffer
    UDR0 := serial_tx_buffer[tail]

    ' Update tail position
    tail++
    if (tail == TX_RING_BUFFER) 
        tail := 0

    serial_tx_buffer_tail := tail

    ' Turn off Data Register Empty Interrupt to stop tx-streaming if this concludes the transfer
    if (tail == serial_tx_buffer_head)
        UCSR0B &= !(1 << UDRIE0)

' Fetches the first byte in the serial read buffer. Called by main program.
PUB serial_read | {uint8_t} tail, data

    tail := serial_rx_buffer_tail ' Temporary serial_rx_buffer_tail (to optimize for {CHECK_SCOPE} )
    if (serial_rx_buffer_head == tail)
        return SERIAL_NO_DATA
    else
        data := serial_rx_buffer[tail]

    tail++
    if (tail == RX_RING_BUFFER)
        tail := 0
    serial_rx_buffer_tail := tail

    return data

PUB ISR_SRX(SERIAL_RX) | {uint8_t} data, next_head, sreg, UDR0

    data := UDR0 'XXX hardware specific
    ' Pick off realtime command characters directly from the serial stream. These characters are
    ' not passed into the main buffer, but these set system state flag bits for realtime execution.
    case (data) 
        CMD_RESET:         mc_reset ' Call motion control reset routine.
        CMD_STATUS_REPORT: system_set_exec_state_flag(EXEC_STATUS_REPORT) ' Set as true
        CMD_CYCLE_START:   system_set_exec_state_flag(EXEC_CYCLE_START) ' Set as true
        CMD_FEED_HOLD:     system_set_exec_state_flag(EXEC_FEED_HOLD) ' Set as true
        OTHER:
            if (data > $7F)
                ' Real-time control characters are extended ACSII only.
                case(data) 
                    CMD_SAFETY_DOOR:   system_set_exec_state_flag(EXEC_SAFETY_DOOR) ' Set as true
                    CMD_JOG_CANCEL:   
                        if (sys.state & STATE_JOG) 
                            ' Block all other states from invoking motion cancel.
                            system_set_exec_state_flag(EXEC_MOTION_CANCEL) 
#ifdef DEBUG
            CMD_DEBUG_REPORT: 'XXX hardware specific
                sreg := SREG
                cli
                bit_true(sys_rt_exec_debug, EXEC_DEBUG_REPORT)
                SREG = sreg
#endif
                    CMD_FEED_OVR_RESET: system_set_exec_motion_override_flag(EXEC_FEED_OVR_RESET)
                    CMD_FEED_OVR_COARSE_PLUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_COARSE_PLUS)
                    CMD_FEED_OVR_COARSE_MINUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_COARSE_MINUS)
                    CMD_FEED_OVR_FINE_PLUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_FINE_PLUS)
                    CMD_FEED_OVR_FINE_MINUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_FINE_MINUS)
                    CMD_RAPID_OVR_RESET: system_set_exec_motion_override_flag(EXEC_RAPID_OVR_RESET)
                    CMD_RAPID_OVR_MEDIUM: system_set_exec_motion_override_flag(EXEC_RAPID_OVR_MEDIUM)
                    CMD_RAPID_OVR_LOW: system_set_exec_motion_override_flag(EXEC_RAPID_OVR_LOW)
                    CMD_SPINDLE_OVR_RESET: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_RESET)
                    CMD_SPINDLE_OVR_COARSE_PLUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_COARSE_PLUS)
                    CMD_SPINDLE_OVR_COARSE_MINUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_COARSE_MINUS)
                    CMD_SPINDLE_OVR_FINE_PLUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_FINE_PLUS)
                    CMD_SPINDLE_OVR_FINE_MINUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_FINE_MINUS)
                    CMD_SPINDLE_OVR_STOP: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_STOP)
                    CMD_COOLANT_FLOOD_OVR_TOGGLE: system_set_exec_accessory_override_flag(EXEC_COOLANT_FLOOD_OVR_TOGGLE)
#ifdef ENABLE_M7
                    CMD_COOLANT_MIST_OVR_TOGGLE: system_set_exec_accessory_override_flag(EXEC_COOLANT_MIST_OVR_TOGGLE)
#endif
            ' Throw away any unfound extended-ASCII character by not passing it to the serial buffer.
            else ' Write character to buffer
                next_head := serial_rx_buffer_head + 1
                if (next_head == RX_RING_BUFFER)
                    next_head := 0

                ' Write data to buffer unless it is full.
                if (next_head <> serial_rx_buffer_tail)
                    serial_rx_buffer[serial_rx_buffer_head] := data
                    serial_rx_buffer_head := next_head

PUB serial_reset_read_buffer

    serial_rx_buffer_tail := serial_rx_buffer_head

