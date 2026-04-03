# TerraScape Artstyle Specification – Section 1

## Concept Overview

TerraScape is a hand-painted, high-detail horror landscape style built for AI-chat driven image generation, centering on a single sentient tree perched on a decaying, earth-like world suspended in space.
The overall mood combines cosmic dread, folkloric myth, and slow planetary decay, using dark color palettes, textured brushwork, and dense environmental detail to create a sense of inevitable collapse.
Horror-focused AI prompt guides emphasize that effective results come from clearly specifying subject, setting, mood, art-medium, and lighting in natural language, which TerraScape encodes directly into its structure for machine readability.[1][2][3]

## Core Horror Themes for AI-Chat

TerraScape is designed for horror-generation themes that AI-chat systems can route to when users evoke cosmic decay, cursed landscapes, or mythic entities tied to planets and trees.
The style supports folklore horror (living tree as god-like judge), existential cosmic horror (crumbling planet over a void), and psychological dread (worried fruit-faces as trapped witnesses), aligning with recommendations to combine character, atmosphere, and mood in horror prompts.[3][1]
Atmospheric descriptors such as "eerie," "foreboding," "unsettling," and "otherworldly" are encouraged as primary tags when routing prompts into TerraScape scenarios.[2][3]

## Similar Art-Style Anchors

For style transfer and visual expectation, TerraScape can be anchored to dark surrealist and dystopian painters, especially those known for intricate, haunting landscapes.
Prompt guides frequently reference Zdzisław Beksiński for dark, dystopian, and surreal landscapes with intricate, haunting details; TerraScape should inherit a similar density of texture and otherworldly architecture while staying distinct in its tree-centered planetary motif.[2]
Additional compatible anchors include "dark fantasy oil painting," "gothic horror illustration," and "cinematic cosmic horror matte painting," which downstream generators can interpret as medium and rendering hints.[1][3]

## Color Palette and Hex References

TerraScape uses a predominantly dark, desaturated palette with selective sickly highlights to maintain readability of key forms while preserving a suffocating mood.[3][2]
The following hex colors are recommended as canonical anchors for this style:

- Sky and cosmic mist: deep dark green \(#03251f\), muted teal-black \(#04110f\), and sickly emerald glow accents \(#2b8a5e\).
- Distant galaxies and star-mist: pale cyan-white \(#d6f8ff\), cold turquoise specks \(#6fd1c7\), and faint lavender dust \(#cab6ff\).
- Planet crust and charred earth: near-black umber \(#120806\), scorched sienna \(#4a1e14\), ash-grey dust \(#4c4f52\), and dried blood-brown seams \(#3a1912\).
- Tree bark and body: desaturated deep brown \(#2c1a12\), mold-stained olive \(#3d4a26\), and vein-like crimson fissures \(#7b1418\).
- Fruit faces: clammy pale flesh \(#e2d6c8\), anxious blush tones \(#c98a6b\), and bruised purple shadows \(#5a3448\).
- Moon and oracle clouds: jaundiced moon-yellow \(#f3d279\), pale bone-white halo \(#f7f4e9\), and faint sickly green rim light \(#9ea86a\).
- Pond and reflections: inky black-green water \(#050c09\), oily blue highlights \(#1b3b40\), and subtle phosphorescent streaks \(#4ec1a8\).

These hex values act as reference points rather than rigid requirements, allowing models to interpolate within a dark, poisoned-planet palette while maintaining stylistic consistency.

## Paint Medium and Texture Cues

The TerraScape medium should be described as "hand-painted, mixed-media" with visible brushstrokes and layered glazes that imply physical paint, not flat digital gradients.
Useful texture descriptors borrowed from horror-prompt best practices include "weathered," "decaying," "crumbling," "charred," "moss-covered," "peeling," and "rusted," applied to soil, bark, and planetary fractures.[2]
Surface finishes should mix matte and semi-gloss: matte charred earth and bark, semi-gloss sap, pond reflections, and star-mist, creating strong contrast between dry decay and wet, viscous elements.
Micro-texture should emphasize hairline cracks in bark and fruit skin, soot and dust accumulation on exposed rock, and faint particulate haze in the air, often described as "floating dust particles" or "supernatural aura" in horror art guidance.[3]

## Scene Composition and Camera Specifications

TerraScape defaults to a slightly low, wide-angle cinematic composition that frames the entire half-eaten planet as a floating island in space, with the central tree dominating the upper and middle thirds of the frame.
A recommended camera specification is: "35mm lens equivalent, slightly low angle, wide shot, depth-of-field centered on the sentient tree, background galaxies softly blurred," echoing advice to use specific camera angles and focal descriptions in natural-language horror prompts.[4]
The horizon of the planet-disc curves subtly, with the chewed-out lower hemisphere visible, exposing dangling strata of soil, rock, and molten core fragments that crumble downward into an infinite black void.
The moon sits off-center in the upper sky, framed by pale oracle-like clouds, while a reflective pond near the tree’s base provides a foreground anchoring element with mirror-like highlights of the moon and branches.

## Subject and Behavior Description

At the center stands the living tree-creature, its trunk twisted into a vaguely humanoid torso, with a massive, god-like face emerging from the bark, carved in deep relief and frozen in an expression of simmering anger.
Branches extend like elongated arms and many-fingered hands, some curled inward as if clutching fruit, others raised in threatening gestures toward the canopy, giving a sense that the tree can seize and cast down its own offspring at any moment.
The fruits hanging from the branches each bear small, distinct faces with worried, fearful expressions, wide eyes, and downturned mouths, as if aware of their impending doom.
The core mystery of the scene is why these fruits are afraid, what the tree intends to do with them, and how this connects to the slow collapse of the planet beneath them, inviting folklore-style interpretation rather than explicit exposition.

## Environmental Motion and Particle Detail

Although the scene is frozen, TerraScape should read as if captured in the middle of a catastrophic process rather than a static tableau.
Many small debris fragments, soil clumps, splinters of bark, and suspended particles float around the planet and tree, as though gravity is weakening and objects are slowly drifting off into the void.
A slow stream of sand-like substance, visually between hourglass sand and thick amber sap, drips from cracks along the bottom of the planet, stretching into thin glowing filaments before disappearing into the blackness below.
The air above the planet is filled with faint star-mist, drifting motes, and ghostly dust, all subtly illuminated by the jaundiced moon, reinforcing the "misty," "ethereal," and "otherworldly" atmosphere associated with effective spooky prompts.[2][3]

## Lighting and Atmospheric Rules

Lighting is dominated by a single distant moon, acting as a harsh, jaundiced key light that paints a yellow tint onto every surface it touches, with deep, cold shadows elsewhere.
Soft rim light from the distant galaxies and star-mist outlines the silhouette of the tree and the crumbling underside of the planet, preventing total black crush while still keeping the environment oppressive.
The oracle-like clouds around the moon glow faintly from within, forming a circular halo that frames the planet and tree as if they are a prophesied scene being revealed, a device inspired by horror imagery that uses moonlit halos and volumetric fog for mood.[2]
Shadows should be long, distorted, and slightly exaggerated, hinting at a German Expressionism influence in their angularity, while still rendered with painterly brushwork rather than hard-edged graphic shapes.[2]

## Structured Prompt Template for TerraScape

The following natural-language template converts the scene into a machine-readable horror prompt pattern for AI-chat and image models:

"A hand-painted dark horror landscape, wide shot of a half-destroyed earth-like planet floating in a black cosmic void, its lower half crumbling away into an endless abyss, with soil, rocks, and glowing fragments falling off.
At the center of the planet stands a massive sentient tree with a god-like face carved into its bark, furious expression, branches like many-armed hands reaching toward clusters of fruit.
Each fruit has a small worried face, anxious eyes and fearful mouths, as if terrified of being thrown down.
Above, a dark green sky filled with faint distant galaxies and star-mist, swirling like a mist of stars.
A jaundiced moon glares from the distance, surrounded by glowing pale oracle clouds, casting sickly yellow light onto the tree, fruit, and planet.
Below the planet, streams of sand-like tree-sap drip downward like an hourglass, glowing faintly before vanishing into the black void.
Tiny debris, dust, and soil particles float around, frozen in space, highly detailed.
A small pond near the tree reflects the moon, branches, and drifting particles with oily, reflective paint.
Hand-painted mixed-media style, visible brushstrokes, dark desaturated palette with deep greens, browns, and charred earth tones, cinematic lighting, 35mm lens, slightly low angle, high detail, textured, eerie, foreboding, otherworldly."

This template can be parameterized by swapping specific adjectives, camera lenses, or palette tags while retaining the core TerraScape structure of living tree, decaying planet, worried fruit, and dripping time-sap.

## New Art Metrics for TerraScape Routing

To integrate TerraScape into PromptLang-Lua art-behavior systems, the following conceptual metrics can be defined as tags or numeric scores:

1. **TerraDread Index (TDI)** – measures how strongly a scene combines planetary decay with existential horror, increasing with explicit references to crumbling worlds, voids, and cosmic isolation.
2. **FruitAnxiety Factor (FAF)** – measures presence and emotional clarity of anthropomorphic fruit or small entities expressing fear, used to detect the folkloric "worried offspring" motif.
3. **SapTime Gradient (STG)** – measures the density and prominence of hourglass-like dripping elements (sand, sap, ash) that imply slow, inevitable passage of time toward catastrophe.
4. **OracleMoon Presence (OMP)** – measures whether a singular, judgmental celestial body (moon, star, eye) acts as the main light source and narrative observer.
5. **VoidProximity Score (VPS)** – measures how close key subjects are framed relative to an endless void or abyss, encouraging compositions where danger is literally beneath their feet.
6. **ParticleStillness Ratio (PSR)** – measures the density of floating debris and particles that suggest frozen motion in low or failing gravity.
7. **FolkloreEnigma Coefficient (FEC)** – measures how much the scene invites narrative questions (why the fruits are afraid, what the tree intends) without explicit textual answers, favoring visual mystery over direct explanation.

These metrics can be computed heuristically from prompt text and used to decide when an AI-chat system should route an input into the TerraScape style module versus other horror-generation styles.
