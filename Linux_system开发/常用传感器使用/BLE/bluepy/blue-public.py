from bluepy import btle
import time
import binascii
 
print "Connecting..."
dev = btle.Peripheral("EA:B6:0B:B3:17:D3",  btle.ADDR_TYPE_PUBLIC)

print "Services..."
for svc in dev.services:
    print str(svc)

lightSensor = btle.UUID("0000fff0-0000-1000-8000-00805f9b34fb")

lightService = dev.getServiceByUUID(lightSensor)
for ch in lightService.getCharacteristics():
    print str(ch)

uuidConfig = btle.UUID("0000fff2-0000-1000-8000-00805f9b34fb")
lightSensorConfig = lightService.getCharacteristics(uuidConfig)[0]
# Enable the sensor
lightSensorConfig.write(bytes("123456"))

print "Read handle..."
time.sleep(3.0) # Allow sensor to stabilise

uuidValue  = btle.UUID("0000fff1-0000-1000-8000-00805f9b34fb")
lightSensorValue = lightService.getCharacteristics(uuidValue)[0]
# Read the sensor
val = lightSensorValue.read()
print "Light sensor raw value", binascii.b2a_hex(val)