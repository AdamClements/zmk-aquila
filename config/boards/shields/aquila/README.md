# Aquila

Aquila is a firmware for a few 34 key keyboards, including Aquila, Hypergolic and Sweep.

## Pin arrangement

Some revisions of the aforementioned PCBs have slightly different pin arrangements compared to what's defined in [`aquila.dtsi`](./aquila.dtsi). If you need to swap a few keys for your particular PCB, you can easily reorder the `input-gpio` definition in your own keymap file (i.e. in `zmk-config/config/aquila.keymap`):

```dts
/* Adjusted Aquila pin arrangement */
/* The position of Q and B keys have been swapped */
&kscan0 {
	input-gpios
	= <&pro_micro  6 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro 18 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro 19 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro 20 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro 21 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro 15 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro 14 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro 16 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro 10 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro  1 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro  2 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro  3 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro  4 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro  5 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro  7 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro  8 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	, <&pro_micro  9 (GPIO_ACTIVE_LOW | GPIO_PULL_UP)>
	;
};
```

This `&kscan0` block must be placed outside of any blocks surrounded by curly braces (`{...}`).

## Known issue: OLED blank when split is enabled (2026-09)

The SSD1306 OLED on the screen-fitted left half is **hardware-verified
working**: a standalone build (`-DCONFIG_ZMK_SPLIT=n`, display forced on)
renders widgets at SDA=P0.04 / SCL=P0.06, address 0x3C. The identical
display config on a split central initializes the panel (cleared, no
driver errors) but never renders a frame. A full generated-Kconfig diff
between the working standalone build and the blank split build shows no
display-stack differences — only BT/split. `CONFIG_ZMK_DISPLAY_WORK_QUEUE_DEDICATED=y`
did not help. Suspected ZMK-main split-central + LVGL 9.3 interaction.

Leads for whoever picks this up:
- Capture a split-central boot log via RTT over SWD (no `zmk-rtt-logging`
  snippet upstream; use `CONFIG_LOG_BACKEND_RTT` etc. — see commit 13a8ac9
  for a build.yaml stanza). USB-CDC logging misses the boot window.
- Check upstream ZMK issues for split central display regressions after
  the Zephyr 4.1 / LVGL 9 migration; consider bisecting pinned ZMK versions.
- The right half's OLED may be fine too: its only "failed init" log was
  taken with left-half pins. Right halves may route the accessory
  connector to P1.04/P1.06 (the 2022 `sda-pin=<36>/scl-pin=<38>` config
  that historically worked on that half). NB: display enabled on floating
  pins hangs the entire boot (before USB) on Zephyr 4.1.
