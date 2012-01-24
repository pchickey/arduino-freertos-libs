// -*- Mode: C++; c-basic-offset: 8; indent-tabs-mode: nil -*-

//
// Example code for the RTOSSerial driver.
//
// This code is placed into the public domain.
//

// Each sketch using the RTOSSerial library must also include
// the ArduinoFreeRTOS library, and use the RTOSSerial library
// only after the scheduler has been started.
#include <ArduinoFreeRTOS.h>

//
// Include the RTOSSerial library header.
//
// Note that this causes the standard Arduino Serial* driver to be
// disabled.
//
#include <RTOSSerial.h>

//
// Create a RTOSSerial driver that looks just like the stock Arduino
// driver.
//
RTOSSerialPort0(Serial);

//
// To create a driver for a different serial port, on a board that
// supports more than one, use the appropriate macro:
//
//RTOSSerialPort2(Serial2);

void *maintask_handle;

void setup () {
  /* Create maintask with a stack size of 200, no arguments, priority level 1.*/
  xTaskCreate(maintask_func, (signed char *)"main", 200,
              NULL, 1, &maintask_handle);
  /* Start the scheduler. This call will never return.*/
  vTaskStartScheduler();
}
void loop () { /* stub - loop is never reached. */ }

// Serial.begin and and other setup code must run from inside a task.
// maintask is a trivial task that acts just like the Arduino setup and loop.
void maintask_func (void * params) {
  maintask_setup();
  for(;;)
    maintask_loop();
}

void maintask_setup(void)
{
        //
        // Set the speed for our replacement serial port.
        //
	Serial.begin(115200);

        //
        // Test printing things
        //
        Serial.print("test");
        Serial.println(" begin");
        Serial.println(1000);
        Serial.println(1000, 8);
        Serial.println(1000, 10);
        Serial.println(1000, 16);
        Serial.println_P(PSTR("progmem"));
        Serial.printf("printf %d %u %#x %p %f %S\n", -1000, 1000, 1000, 1000, 1.2345, PSTR("progmem"));
        Serial.printf_P(PSTR("printf_P %d %u %#x %p %f %S\n"), -1000, 1000, 1000, 1000, 1.2345, PSTR("progmem"));
        Serial.println("done");
}

void
maintask_loop(void)
{
    int    c;

    //
    // Perform a simple loopback operation.
    //
    c = Serial.read();
    if (-1 != c)
        Serial.write(c);
}

