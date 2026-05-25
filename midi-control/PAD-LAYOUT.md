# Pad Layout — MPK Mini Play (Bank A)

```
┌─────────────────────────────────────────────────────┐
│  TOP ROW                                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ │
│  │ PAD 5    │ │ PAD 6    │ │ PAD 7    │ │ PAD 8  │ │
│  │ note 55  │ │ note 57  │ │ note 59  │ │note 60 │ │
│  │ PREV     │ │ NEXT     │ │ PANIC    │ │ (free) │ │
│  │ REGION   │ │ REGION   │ │          │ │        │ │
│  └──────────┘ └──────────┘ └──────────┘ └────────┘ │
│                                                     │
│  BOTTOM ROW                                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ │
│  │ PAD 1    │ │ PAD 2    │ │ PAD 3    │ │ PAD 4  │ │
│  │ note 32  │ │ note 50  │ │ note 52  │ │note 53 │ │
│  │ PLAY /   │ │ STOP     │ │ LOOP     │ │ GO TO  │ │
│  │ PAUSE ●  │ │          │ │ REGION ● │ │ START  │ │
│  └──────────┘ └──────────┘ └──────────┘ └────────┘ │
└─────────────────────────────────────────────────────┘

● = pad LED stays lit while feature is active
    Pad 1 LED: on while playing or paused
    Pad 3 LED: on while loop/repeat is active

Bank B (notes: 36 38 3a 3b / 24 26 28 2a) — available for future use
All notes are MIDI channel 10 (index 9 in ReaLearn)
```

## Quick reference

| Pad | Note (hex) | Note (dec) | Action |
|-----|-----------|------------|--------|
| 1   | 0x20      | 32         | Play / Pause |
| 2   | 0x32      | 50         | Stop |
| 3   | 0x34      | 52         | Loop current region |
| 4   | 0x35      | 53         | Go to region start |
| 5   | 0x37      | 55         | Previous region |
| 6   | 0x39      | 57         | Next region |
| 7   | 0x3b      | 59         | Panic (stop + all notes off) |
| 8   | 0x3c      | 60         | (free) |
