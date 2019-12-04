# What is ChucK?
"ChucK is a programming language for real-time sound synthesis and music creation. It is open-source and freely available on MacOS X, Windows, and Linux. ChucK presents a unique time-based, concurrent programming model that's precise and expressive (we call this strongly-timed), dynamic control rates, and the ability to add and modify code on-the-fly. In addition, ChucK supports MIDI, OpenSoundControl, HID device, and multi-channel audio. It's fun and easy to learn, and offers composers, researchers, and performers a powerful programming tool for building and experimenting with complex audio synthesis/analysis programs, and real-time interactive music."
- https://chuck.cs.princeton.edu
---
# About this project

This interactive program leverages ChucK's built in analog-to-digital converter (ADC) to detect claps and respond accordingly.

---
# How it works
By recursively analyzing the amplitude analog input signal the program is able to discern the number of times an individual claps.
This in turn allows the program to be interactively controlled based on the number claps it detects.  

---
# Clap Controls 
- 1 clap - Toggle composition playback
- 2 claps - Decrease melody volume
- 3 claps - Increase melody volume
- 4 claps - Play a sweep sound
- 6 claps Play a screech sound
