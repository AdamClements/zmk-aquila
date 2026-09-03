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

## OLED wiring (hardware-traced 2026-09)

Both halves route the OLED to **SDA = P1.04 (D8), SCL = P1.06 (D9)**,
address 0x3C — identical on both sides because the nano is reversed on
one half. This matches the original 2022 `sda-pin=<36>/scl-pin=<38>`
config, which worked. (A 2026-09 debugging detour concluded the pins
were P0.04/P0.06 based on widgets seen on a freshly flashed half — those
turned out to be leftover pixels from the previous firmware, still shown
because the panel never lost power. These OLEDs keep displaying their
last content across MCU reflashes; only a battery-off power cycle
clears them. Verify display changes after a true cold start.)

The right half's display is currently disabled in `aquila_right.conf`:
with the display enabled there, boot hung entirely (pre-USB) on Zephyr
4.1 — either its panel/wiring was damaged in the 2025 electrical mishap,
or something else; test by re-enabling its display config after
confirming the left half renders.
