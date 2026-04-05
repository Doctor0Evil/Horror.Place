# SFX & Invariant Mapping Guide

**Version:** 1.0.0  
**Module:** Horror.Audio  

This document describes how the `engine.library.horror_audio.lua` module maps abstract horror invariants to concrete audio behaviors (RTPCs, filters, layers).

## 1. Audio Design Philosophy

We do not place sounds; we place **conditions**.
The audio system queries the history of a location and generates a "pressure profile" that dictates what the player hears.
*   **High CIC** = The history is heavy; audio should feel oppressive, dense, and low-frequency.
*   **High LSG** = The space is transitioning; audio should use filter sweeps, delays, and stereo narrowing to create "threshold anxiety."

## 2. Invariant Mappings

### CIC (Catastrophic Imprint Coefficient)
*   **Low (0.0 - 0.3):** Ambient wind, standard foley.
*   **Mid (0.3 - 0.7):** "Heavy" air (low-pass filter ~2kHz), distant metallic groans, sporadic debris settling.
*   **High (0.7 - 1.0):** **"The Trauma Layer."** Sub-bass drones (30-60Hz) are introduced. Volume of environmental "groans" increases. High chance of "Tinnitus" layers (ringing) spawning to simulate high-stress environments.

### AOS (Archival Opacity Score)
*   **Low (0.0 - 0.3):** Clear, intelligible audio.
*   **High (0.7 - 1.0):** **"The Redaction Layer."**
    *   Random bit-crushing effects on footsteps (simulating digital glitch).
    *   "Phantom Audio": Muffled voices or radio chatter that cannot be understood.
    *   Audio dropouts: 0.5s of total silence at random intervals.

### LSG (Liminal Stress Gradient)
*   **Trigger:** Used primarily when crossing tile boundaries.
*   **Effect:**
    *   **Transition:** 200ms reverb spike (Wet/Dry mix up).
    *   **Stereo Image:** If LSG > 0.8, the stereo image narrows to mono for 1 second (tunnel vision effect).
    *   **Pitch:** Slight pitch shift (-5 cents) upon entry to create a sense of "wrongness."

### HVF (Haunt Vector Field)
*   **Usage:** Spatialization.
*   **Effect:**
    *   Directional audio sources (whispers, scuttling) pan along the HVF vector direction.
    *   If the player moves *against* the HVF vector, "Resistance" layers (dissonant strings/noise) are boosted.

## 3. RTPC Bundles

The `Audio.compute_dread_rtpcs` function outputs a table of Real-Time Parameter Controls (RTPCs) for the engine (Wwise/FMOD).

| RTPC Name | Source Invariant | Description |
| :--- | :--- | :--- |
| `cic_weight` | CIC | Controls volume of the "Trauma Drone" bus. |
| `aos_haze` | AOS | Controls cutoff frequency of the Master Lo-Pass Filter. |
| `haunt_mag` | HVF.mag | Controls the volume of directional whispers. |
| `liminal_stress` | LSG | Controls the intensity of the "Threshold Sweep" effect. |
| `dread_level` | DET | Master compressor threshold; makes loud sounds punchier. |

## 4. Implementation Note for Designers

Do not manually tweak these RTPCs in the engine. They are driven by the **Seed Data** (`region_invariant_pack.ndjson`). If the audio feels "too scary" in a spawn zone, check the seed data: the `CIC` or `LSG` might be too high. Fix the data, and the audio will correct itself.
