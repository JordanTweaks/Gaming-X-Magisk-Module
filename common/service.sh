#!/system/bin/sh
sleep 20

# Set small CPU cores (0-3) to performance mode
for cpu in 0 1 2 3; do
    chmod 644 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor
    echo performance > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor
    chmod 444 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor
    chmod 644 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
    echo 1900800 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
    chmod 444 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
    chmod 644 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq
    echo 1900800 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq
    chmod 444 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq
done

# Set big CPU cores (4-7) to performance mode
for cpu in 4 5 6 7; do
    chmod 644 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor
    echo performance > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor
    chmod 444 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor
    chmod 644 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
    echo 2802300 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
    chmod 444 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
    chmod 644 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq
    echo 2802300 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq
    chmod 444 /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq
done

# GPU max power level
echo 1260000000 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq
echo 1260000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq
echo 1260000000 > /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq
echo 1260000000 > /sys/class/kgsl/kgsl-3d0/devfreq/target_freq
echo 0 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel
echo 0 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel
echo 0 > /sys/class/kgsl/kgsl-3d0/default_pwrlevel
echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor
echo 0 > /sys/class/kgsl/kgsl-3d0/thermal_pwrlevel
echo 0 > /sys/class/kgsl/kgsl-3d0/bus_split
echo 1260 > /sys/class/kgsl/kgsl-3d0/clock_mhz
echo 1260 > /sys/class/kgsl/kgsl-3d0/max_clock_mhz
echo 1260 > /sys/class/kgsl/kgsl-3d0/min_clock_mhz
echo 1260000000 > /sys/class/kgsl/kgsl-3d0/max_gpuclk
echo 0 > /sys/class/kgsl/kgsl-3d0/throttling
echo 1 > /sys/class/kgsl/kgsl-3d0/force_bus_on
echo 1 > /sys/class/kgsl/kgsl-3d0/force_rail_on
echo 1 > /sys/class/kgsl/kgsl-3d0/force_clk_on
echo 1 > /sys/class/kgsl/kgsl-3d0/force_no_nap
echo 0 > /sys/class/kgsl/kgsl-3d0/pwrscale

# CPU & kernel boost settings
echo 1 > /sys/devices/system/cpu/cpufreq/interactive/boost
echo 1 > /sys/module/cpu_boost/parameters/boost
echo 1 > /sys/module/cpu_boost/parameters/input_boost_enabled
echo 1 > /sys/module/cpu_boost/parameters/sched_boost
echo 1 > /sys/module/msm_performance/parameters/touchboost
echo 1 > /sys/module/msm_thermal/core_control/enabled

# EAS & power scheduling
echo 1 > /proc/sys/kernel/sched_boost
echo 0 > /sys/module/workqueue/parameters/power_efficient

# Kernel Tweaks
chmod 644 sys/kernel/fpscaps
echo 0 /sys/kernel/fpscaps
chmod 444 sys/kernel/fpscaps
chmod 644 /sys/kernel/gpu/gpu_clock
echo 1260 > /sys/kernel/gpu/gpu_clock
chmod 444 /sys/kernel/gpu/gpu_clock
chmod 644 /sys/kernel/gpu/gpu_min_clock
echo 1260 > /sys/kernel/gpu/gpu_min_clock
chmod 444 /sys/kernel/gpu/gpu_min_clock
chmod 644 /sys/kernel/gpu/gpu_max_clock
echo 1260 > /sys/kernel/gpu/gpu_max_clock
chmod 444 /sys/kernel/gpu/gpu_max_clock

# Ensure all cores online
for cpu in 0 1 2 3 4 5 6 7; do
    echo 1 > /sys/devices/system/cpu/cpu$cpu/online
done

# CMD Tweaks

cmd thermalservice override-status 0
cmd power set-fixed-performance-mode-enabled true
cmd power set-adaptive-power-saver-enabled false
cmd power set-mode 0
cmd display set-match-content-frame-rate-pref 1

# Game Performance & FPS Settings
packages=$(pm list packages -3 | awk -F':' '{print $2}')
for package in $packages; do
    cmd device_config put game_overlay $package mode=2,fps=120,resolution=high,antialiasing=2,cpu_level=high,gpu_level=high,thermal_mode=performance,refresh_rate=120:mode=3,fps=120,resolution=high,antialiasing=2,cpu_level=high,gpu_level=high,thermal_mode=performance,refresh_rate=120
    cmd game set --mode performance --fps 120 $package
done

sleep 15

android_properties="
debug.sf.disable_backpressure=1
debug.sf.latch_unsignaled=1
debug.sf.enable_hwc_vds=0
debug.sf.early_phase_offset_ns=250000
debug.sf.early_app_phase_offset_ns=250000
debug.sf.early_gl_phase_offset_ns=1500000
debug.sf.early_gl_app_phase_offset_ns=7500000
debug.sf.high_fps_early_phase_offset_ns=3000000
debug.sf.high_fps_early_gl_phase_offset_ns=500000
debug.sf.high_fps_late_app_phase_offset_ns=50000
debug.sf.phase_offset_threshold_for_next_vsync_ns=3000000
debug.sf.showupdates=0
debug.sf.showcpu=0
debug.sf.showbackground=0
debug.sf.showfps=0
debug.sf.hw=1
debug.gralloc.gfx_ubwc_disable=0
debug.composition-type=hybrid
persist.sys.composer.preferred_mode=performance
"
echo "$android_properties" | while IFS= read -r prop; do
  prop_name="${prop%%=*}"
  prop_value="${prop#*=}"
  resetprop -n "$prop_name" "$prop_value"
done

