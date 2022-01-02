from lifxlan import LifxLAN
import time

print('Initializing Light Control..')

MAX_CONNECTION_RETRIES = 5

lifx = LifxLAN(1)
print("Connecting...")

light = None
for i in range(MAX_CONNECTION_RETRIES):
    try:
        # get lights
        #devices = Lifx.get_lights()
        #light = devices[0]
        light = lifx.get_device_by_name("mini_1")
        break
    except:
        print("Retrying...")
        time.sleep(1)

if light is None:
    raise Exception("Failed to connect to LIFX device! Please try again.")

print("Connected!")

# get original settings
#original_power = light.get_power()
#original_color = light.get_color()

#print(original_power)
#print(original_color)

#light.set_power("on")

toggle_light = True

toggle_light = not toggle_light
if toggle_light:
    light.set_power("on")
else:
    light.set_power("off")