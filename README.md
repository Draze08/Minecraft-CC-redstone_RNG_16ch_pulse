# Minecraft-CC-redstone_RNG_16ch_pulse

Reusable CC:Tweaked controller for **1 to 16 independent random redstone outputs** using Redstone Relay peripherals.

The controller does not know or care what is connected downstream. In the original build each relay feeds a different EnderIO Redstone Conduit colour channel, but the software simply treats every commissioned relay/output-side pair as an independent channel.

## Behaviour

- Supports 1-16 commissioned Redstone Relays.
- Commissioning automatically discovers attached/networked `redstone_relay` peripherals.
- Commissioning also discovers which physical side of each relay actually drives the downstream lamp/device.
- Missing channels are normal; all 16 are not required.
- Relays with no usable output can be skipped during commissioning.
- Every active relay runs its own asynchronous RNG state loop.
- Multiple outputs may therefore be ON simultaneously.
- Every state change rolls a new random duration between the configured minimum and maximum.
- Each channel starts in a random state with a random initial duration, avoiding an obvious synchronized startup pattern.
- If a previously commissioned relay is absent at runtime it is skipped rather than killing the whole controller.
- Minimum timing is limited to 0.1 seconds.

## Files

- `commission.lua` - discovers up to 16 relays, discovers the working output side for each one, and asks for minimum/maximum random state timing.
- `pulse.lua` - runs one independent RNG worker per available commissioned relay/output pair.
- `startup.lua` - launches `pulse.lua` automatically when the CC computer starts.
- `install.lua` - downloads the runtime files from this branch while preserving an existing config.
- `rngpulse.cfg` - generated locally by commissioning; do not copy between computers unless the peripheral names and relay orientations are appropriate.

## Installation

From a CC:Tweaked computer:

```text
wget run https://raw.githubusercontent.com/Draze08/Minecraft-CC-redstone_RNG_16ch_pulse/refs/heads/initial-controller/install.lua
```

## Commissioning

Attach the required Redstone Relays to the CC:Tweaked wired peripheral network, then run:

```text
commission.lua
```

For each discovered relay, commissioning pulses all six physical faces in this order:

```text
top
bottom
left
right
front
back
```

Watch the downstream lamp/device and enter the side that activated it. You may repeat the test or skip a relay. This means relay orientation does not need to be consistent across the installation.

After side discovery, commissioning asks for timing:

```text
Minimum random state time [0.1s]: 0.1
Maximum random state time [2.0s]: 2
```

A channel may then independently remain ON for 0.34s, OFF for 1.72s, ON for 0.11s, and so on. Every other commissioned relay performs its own unrelated sequence.

Run the controller manually with:

```text
pulse.lua
```

`startup.lua` runs it automatically on computer boot.

## Capacity

The software deliberately has no fixed eight-channel assumption. Commissioning uses however many compatible relays are present and successfully mapped, up to the 16-channel design limit, making the controller reusable for other lighting or random-redstone installations.
