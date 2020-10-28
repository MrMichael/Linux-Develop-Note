from bluepy import btle
import time
import binascii
 
print "Connecting..."
dev = btle.Peripheral("f4:52:53:51:f5:39", btle.ADDR_TYPE_RANDOM)

print "Services..."
for svc in dev.services:
    print str(svc)

lightSensor = btle.UUID("6e400001-b5a3-f393-e0a9-e50e24dcca9e")

lightService = dev.getServiceByUUID(lightSensor)
for ch in lightService.getCharacteristics():
    print str(ch)

uuidConfig = btle.UUID("6e400002-b5a3-f393-e0a9-e50e24dcca9e")
lightSensorConfig = lightService.getCharacteristics(uuidConfig)[0]
# Enable the sensor
lightSensorConfig.write(bytes(b'\xFF\xFF\xFF\xFF\xFF\x0B\x01\x08\x01\x01\x02\x01\x03\x01\x01\x01\x03'))

print "Read handle..."
time.sleep(3.0) # Allow sensor to stabilise

uuidValue  = btle.UUID("6e400003-b5a3-f393-e0a9-e50e24dcca9e")
lightSensorValue = lightService.getCharacteristics(uuidValue)[0]
# Read the sensor
val = lightSensorValue.read()
print "Light sensor raw value", binascii.b2a_hex(val)