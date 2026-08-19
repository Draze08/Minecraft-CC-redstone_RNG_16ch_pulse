# Minecraft-CC-redstone_RNG_16ch_pulse

Reusable CC:Tweaked controller for **1 to 16 independent random redstone outputs** using Redstone Relay peripherals.

The controller does not know or care what is connected downstream. In the original build each relay feeds a different EnderIO Redstone Conduit colour channel, but the software simply treats every discovered relay as an independent output.

## Behaviour

- Supports 1-16 commissioned Redstone Relays.
- Commissioning automatically discovers attached `redstone_relay` peripherals.
- Missing channels are normal; all 16 are not required.
- Every active relay runs its own asynchronous RNG state loop.
- Multiple outputs may therefore be ON simultaneously.
- Every state change rolls a new random duration between the configured minimum and maximum.
- Each channel starts in a random state with a random initial duration, avoiding an obvious synchronized startup pattern.
- If a previously commissioned relay is absent at runtime it is skipped rather than killing the whole controller.
- Minimum timing is limited to 0.1 seconds.

## Files

- `commission.lua` - discovers up to 16 relays and asks for minimum/maximum random state timing.
- `pulse.lua` - runs one independent RNG worker per available commissioned relay.
- `startup.lua` - launches `pulse.lua` automatically when the CC computer starts.
- `rngpulse.cfg` - generated locally by commissioning; do not copy between computers unless the peripheral names are appropriate.

## Commissioning

Attach the required Redstone Relays to the CC:Tweaked wired peripheral network, then run:

```text
commission
```

Example timing configuration:

```text
Minimum random state time [0.1s]: 0.1
Maximum random state time [2.0s]: 2
```

A relay may then independently remain ON for 0.34s, OFF for 1.72s, ON for 0.11s, and so on. Every other relay performs its own unrelated sequence.

Run the controller with:

```text
pulse
```

## Output side

Each Redstone Relay currently drives its **front** redstone output. Rotate/orient the relay hardware accordingly.

## Capacity

The software deliberately has no fixed eight-channel assumption. Commissioning uses however many compatible relays are present, up to the 16-channel design limit, making the controller reusable for other lighting or random-redstone installations.
