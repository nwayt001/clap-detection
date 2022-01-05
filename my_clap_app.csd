<CsoundSynthesizer>
<CsOptions>
-iadc
--nosound
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs  = 1

pyinit

instr 1

pyruni {{
import os, sys
sys.path.append(os.getcwd())
sys.path.append('/home/pi/clap-detection/')
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
toggle_light = True
if light is None:
    raise Exception("Failed to connect to LIFX device! Please try again.")

print("Connected!")

print 'Clap detection program started...'
clap_counter = 1

from clap import ClapAnalyzer
#clap_analyzer = ClapAnalyzer(note_lengths=[0.25, 0.125, 0.125, 0.25, 0.25])
clap_analyzer = ClapAnalyzer(note_lengths=[0.25, 0.25, 0.25])

def clap_detected():
	global clap_counter
	print 'Clap # {} detected'.format(clap_counter)
	clap_counter = clap_counter + 1

def clap_sequence_detected():
	global light
	global toggle_light
	print 'Matching clap sequence detected!'
	toggle_light = not toggle_light
	if toggle_light:
    		light.set_power("on")
	else:
    		light.set_power("off")

clap_analyzer.on_clap(clap_detected)
clap_analyzer.on_clap_sequence(clap_sequence_detected)
}}

kLastRms init 0
kLastAttack init 0
iRmsDiffThreshold init .1

kTime times

aIn in

kRmsOrig rms aIn

kSmoothingFreq linseg 5, 1, 0.01 ;quicker smoothing to start with
kSmoothRms tonek kRmsOrig, kSmoothingFreq
kSmoothRms max kSmoothRms, 0.001

aNorm = 0.1 * aIn / a(kSmoothRms)

kRms rms aNorm
kRmsDiff = kRms - kLastRms

if (kRmsDiff > iRmsDiffThreshold && kTime - kLastAttack > 0.09) then
	kLastAttack times
	pycall "clap_analyzer.clap", kLastAttack
endif

out aNorm
kLastRms = kRms

endin
</CsInstruments>
<CsScore>

i 1 0 500000000
e
</CsScore>
</CsoundSynthesizer>
