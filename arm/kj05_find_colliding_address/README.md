y2q:/ $ for i in /sys/devices/system/cpu/cpu[0-9]*; do
>     echo -n "$i: "
 >     cat $i/cpufreq/cpuinfo_max_freq 2>/dev/null
> done
/sys/devices/system/cpu/cpu0: 1804800
/sys/devices/system/cpu/cpu1: 1804800
/sys/devices/system/cpu/cpu2: 1804800
/sys/devices/system/cpu/cpu3: 1804800
/sys/devices/system/cpu/cpu4: 2419200
/sys/devices/system/cpu/cpu5: 2419200
/sys/devices/system/cpu/cpu6: 2419200
/sys/devices/system/cpu/cpu7: 2841600

[+] Running experiment NOP_REPEAT(719105) ...
[+] Inserted: b1=0x40fa30, b2=0x6dd8fc, da=0x2d22cc, hit=8851.63, miss=9758.57, arch=Snapdragon865-1

[+] Running experiment NOP_REPEAT(719123) ...
[+] Inserted: b1=0x40fa30, b2=0x6dd944, da=0x2d2374, hit=8919.37, miss=9519.03, arch=Snapdragon865-1