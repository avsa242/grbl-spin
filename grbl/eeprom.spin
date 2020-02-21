' This file has been prepared for Doxygen automatic documentation generation.
{{! \file ********************************************************************
*
* Atmel Corporation
*
* \li File:               eeprom.c
* \li Compiler:           IAR EWAAVR 3.10c
* \li Support mail:       avr@atmel.com
*
* \li Supported devices:  All devices with split EEPROM erase/write
*                         capabilities can be used.
*                         The example is written for ATmega48.
*
* \li AppNote:            AVR103 - Using the EEPROM Programming Modes.
*
* \li Description:        Example on how to use the split EEPROM erase/write
*                         capabilities in e.g. ATmega48. All EEPROM
*                         programming modes are tested, i.e. Erase+Write,
*                         Erase-only and Write-only.
*
*                         $Revision: 1.6 $
*                         $Date: Friday, February 11, 2005 07:16:44 UTC $
***************************************************************************}}
'#include <avr/io.h>
'#include <avr/interrupt.h>

{{ These EEPROM bits have different names on different devices. }}
#ifndef EEPE
#define EEPE  EEWE  '!< EEPROM program/write enable.
#define EEMPE EEMWE '!< EEPROM master program/write enable.
#endif

{{ These two are unfortunately not defined in the device include files. }}
#define EEPM1 5 '!< EEPROM Programming Mode Bit 1.
#define EEPM0 4 '!< EEPROM Programming Mode Bit 0.

{{ Define to reduce code size. }}
#define EEPROM_IGNORE_SELFPROG '!< Remove SPM flag polling.

{{! \brief  Read byte from EEPROM.
 *
 *  This function reads one byte from a given EEPROM address.
 *
 *  \note  The CPU is halted for 4 clock cycles during EEPROM read.
 *
 *  \param  addr  EEPROM address to read from.
 *  \return  The byte read from the EEPROM address.
 }}
PUB{unsigned char} eeprom_get_char({unsigned int} addr)

	repeat while( EECR & (1<<EEPE) ) ' Wait for completion of previous write.
	EEAR := addr ' Set EEPROM address register.
	EECR := (1<<EERE) ' Start EEPROM read operation.
	return EEDR ' Return the byte read from EEPROM.

{{! \brief  Write byte to EEPROM.
 *
 *  This function writes one byte to a given EEPROM address.
 *  The differences between the existing byte and the new value is used
 *  to select the most efficient EEPROM programming mode.
 *
 *  \note  The CPU is halted for 2 clock cycles during EEPROM programming.
 *
 *  \note  When this function returns, the new EEPROM value is not available
 *         until the EEPROM programming time has passed. The EEPE bit in EECR
 *         should be polled to check whether the programming is finished.
 *
 *  \note  The EEPROM_GetChar function checks the EEPE bit automatically.
 *
 *  \param  addr  EEPROM address to write to.
 *  \param  new_value  New EEPROM value.
 }}
PUB eeprom_put_char({unsigned int}addr, {unsigned char} new_value ) | {char}old_value, {char}diff_mask

	'char old_value ' Old EEPROM value.
	'char diff_mask ' Difference mask, i.e. old value XOR new value.

	'cli ' Ensure atomic operation for the write operation.
	
	repeat while( EECR & (1<<EEPE) ) ' Wait for completion of previous write.
#ifndef EEPROM_IGNORE_SELFPROG
    repeat while( SPMCSR & (1<<SELFPRGEN) ) ' Wait for completion of SPM.
#endif
	EEAR := addr ' Set EEPROM address register.
	EECR := (1<<EERE) ' Start EEPROM read operation.
	old_value := EEDR ' Get old EEPROM value.
	diff_mask := old_value ^ new_value ' Get bit differences.
	
	' Check if any bits are changed to  in the new value.
	if( diff_mask & new_value ) 
		' Now we know that _some_ bits need to be erased to .
		' Check if any bits in the new value are .
		if( new_value <> $ff ) 
			' Now we know that some bits need to be programmed to  also.
			EEDR := new_value ' Set EEPROM data register.
			EECR := (1<<EEMPE) | (0<<EEPM1) | (0<<EEPM0) ' Set Master Write Enalbe bit and Erase+Write mode.
			EECR |= (1<<EEPE)  ' Start Erase+Write operation.
		else 
			' Now we know that all bits should be erased.
			EECR:= (1<<EEMPE) | (1<<EEPM0) ' Set Master Write Enable bit and Erase-only mode.
			EECR |= (1<<EEPE)  ' Start Erase-only operation.
	else 
		' Now we know that _no_ bits need to be erased to .
		' Check if any bits are changed from  in the old value.
		if( diff_mask ) 
			' Now we know that _some_ bits need to the programmed to .
			EEDR:= new_value   ' Set EEPROM data register.
			EECR:= (1<<EEMPE) | (1<<EEPM1)  ' Set Master Write Enable bit and Write-only mode.
			EECR |= (1<<EEPE)  ' Start Write-only operation.
	sei ' Restore interrupt flag state.

' Extensions added as part of Grbl 
PUB memcpy_to_eeprom_with_checksum({unsigned int}destination, {char *}source, {unsigned int}size) | {unsigned char}checksum

    checksum := 0
    repeat
        checksum:= (checksum << 1) || (checksum >> 7)
        checksum += byte[source] '*source
        eeprom_put_char(destination++, byte[source++])'*(source++)) 
        size--
    while size > 0
    eeprom_put_char(destination, checksum)

PUB{int} memcpy_from_eeprom_with_checksum({char *}destination, {unsigned int} source, {unsigned int}size) | {unsigned char}data, checksum

    data := checksum := 0
    repeat'for( size > 0; size--)
        data := eeprom_get_char(source++)
        checksum := (checksum << 1) || (checksum >> 7)
        checksum += data    
        byte[destination++] := data'*(destination++):= data 
        size--
    while size > 0
    return(checksum == eeprom_get_char(source))

' end of file
