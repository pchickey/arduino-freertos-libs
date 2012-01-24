/* */

#include <ArduinoFreeRTOS.h>

/* Default pins to 12 & 13 for digital readout of current task. */
#define TASK1_PIN (12)
#define TASK2_PIN (13)

#define PRINTING_TIMEOUT ( (portTickType) 25 )

void *task1_handle;
void *task2_handle;
xSemaphoreHandle printing_semphr;

void setup () {
  /* Use the standard Arduino HardwareSerial library for serial. */
  Serial.begin(115200);
 
  pinMode(TASK1_PIN, OUTPUT);
  pinMode(TASK2_PIN, OUTPUT);
  digitalWrite(TASK1_PIN, LOW);
  digitalWrite(TASK2_PIN, LOW);

  /* Create binary semaphore used to protect printing resource.
   * A binary semaphore is acceptable because it is only used from
   * two tasks, and therefore cannot create a priority inversion. */
  vSemaphoreCreateBinary(printing_semphr);
  /* Start task1 and task2 with the a stack size of 200, no arguments,
   * and the same priority level (1). This will allow them to round robin
   * on vPortYield.
   */
  xTaskCreate(task1_func, (signed portCHAR *)"task1", 200,
              NULL, 1, &task1_handle);
  xTaskCreate(task2_func, (signed portCHAR *)"task2", 200,
              NULL, 1, &task2_handle);
  vTaskStartScheduler();
  /* code after vTaskStartScheduler, and code in loop(), is never reached. */
}

void loop () {
  Serial.println("Never reached");
}

/* Task func is a void(void *). We passed NULL for params in xTaskCreate,
 * so we ignore them.
 * task1_func will be entered once after the scheduler begins. It can perform
 * any required setup and then loop indefinitely.
 * If task1_func were to return, you should let the scheduler know by calling
 * vTaskDelete. */
void task1_func(void *params)
{
  /* Ignoring the semaphore used to protect printing for now. */
  Serial.println("1: Entering Task");
  /* In the same way arduino would call loop(), we'll call task1_loop. */
  for(;;)
      task1_loop(); 
}

void task1_loop() {
  /* Take semaphore to use printing resource */
  if ( xSemaphoreTake( printing_semphr, PRINTING_TIMEOUT ) == pdTRUE ) {
    /* Trivial task: set pin high, print, set pin low*/
    digitalWrite(TASK1_PIN, HIGH);
    Serial.println("1: Task Loop");
    digitalWrite(TASK2_PIN, LOW);
    /* Give up semaphore reserving print resource */
    xSemaphoreGive( printing_semphr );
    /* Yield so that task2 can be scheduled */
    vPortYield();
  } else {
    /* If the semaphore take timed out, something has gone wrong. */
    Serial.println("** Task 1 Error: could not take semaphore **");
    /* Hang thread rather than continue. */
    for(;;);
  }
}


void task2_func(void *params)
{
  Serial.println("2: Entering Task");
  for(;;)
      task2_loop(); 
}

void task2_loop() {
  /* Take semaphore to use printing resource */
  if ( xSemaphoreTake( printing_semphr, PRINTING_TIMEOUT ) == pdTRUE ) {
    /* Trivial task: set pin high, print, set pin low*/
    digitalWrite(TASK2_PIN, HIGH);
    Serial.println("2: Task Loop");
    digitalWrite(TASK2_PIN, LOW);
    /* Give up semaphore reserving print resource */
    xSemaphoreGive( printing_semphr );
    /* Yield so that task1 can be scheduled */
    vPortYield();
  } else {
    /* If the semaphore take timed out, something has gone wrong. */
    Serial.println("** Task 2 Error: could not take semaphore **");
    /* Hang thread rather than continue. */
    for(;;);
  }
}
