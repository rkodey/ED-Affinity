# ED-Affinity
Sets process affinity for Elite Dangerous / Oculus VR processes, for maximum smoothness

The rather buggy Oculus v1.13 driver seemed to be quite sensative to CPU usage, causing flashes, grey-outs and/or poor head tracking.  Just as an experiment, I tried setting process affinity to separate the main Elite Dangerous process from the Oculus binaries, and it worked like magic!

Even though Oculus v1.14 seems to have fixed the core problem, I find using the affinity still makes for a cmoother VR experience.  So...  I wrote this script to automate it.

I'm using AutoHotkey here ... because it's simple!
I will release compiled versions as I update as well.  See the releases tab.

The basic idea:
1) The script will look and wait for the Oculus service processes to start
2) It detects the number of Cores your CPU has (included hyperthreaded cores)
3) It will show you a VERY rough GUI to show you the default setup
4) Click "Ok/Start" to let it do its thing
5) The script will remain in your Tray, waiting for ED to launch.  When it does, it will set the affinity for you.  Even on re-launch.

TODO:
- Allow saving of any settings you may change
- Add command-line switch to auto-start without the GUI
- Add control over process priority (some people say this helps too)
- Maybe add control over core parking

Suggestions and contributions welcome, including moving away from AutoHotkey.
