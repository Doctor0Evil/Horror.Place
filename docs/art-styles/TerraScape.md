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


## Section 2 – Lore, Texture, and Camera Extensions

### Deeper Folkloric Lore Hooks

In TerraScape, the living tree is not just a creature but the planetary archivist: every ring in its trunk is a sealed century of the world’s memory, and every fruit is a single year that tried to escape judgment. The god-like face in the bark is the mask of an ancient steward that failed its duty, now bound to watch the planet erode beneath it as each condemned year ripens into a worried fruit, unable to fall without the tree’s consent. When a fruit is finally cast down into the void, the memories it carries bleed into the blackness as thin golden streaks, briefly illuminating ghostly silhouettes of forgotten civilizations before they fade. Villagers in implied off-screen folklore whisper that if even one fruit escapes and survives the fall, the cycle of decay will break, so the tree’s anger is directed as much at the possibility of hope as at the fruit themselves. This keeps the scene mythic and interpretable, allowing AI-chat systems to spin variations on sacrifice, memory, and judgment without changing the visual core. [openart](https://openart.ai/blog/post/stable-diffusion-prompts-for-horror)

The worried expressions of the fruits suggest that they remember previous “harvests” and know exactly what awaits them beyond the planet’s edge, invoking the horror trope where knowledge itself is a curse. Some fruits show different stages of denial, bargaining, and resignation, giving models room to vary faces across multiple renders while staying inside the TerraScape motif. The moon functions as the dispassionate witness of this ritual: an oracle that never intervenes, only recording the number of years (fruits) that vanish into the abyss. This kind of unresolved, symbolic narrative matches guidance that effective horror often leaves key motives unexplained, encouraging players or viewers to invent their own myths around what they see. [dreadcentral](https://www.dreadcentral.com/editorials/471980/the-perspective-of-horror-atmospheric-use-of-the-camera/)

### Extreme Texture and Surface Language

To push TerraScape toward a more tactile horror look, surfaces should be described as filthy, layered, and slightly diseased rather than simply “rough” or “old.” The bark is not just cracked; it is striated with vein-like fissures, where dried sap forms scabbed ridges over older wounds, and patches of lichen resemble infected skin spreading across the trunk. The planet’s underside exposes striated rock that looks chewed and gnawed, with bite-like voids where entire chunks of crust have been torn away, leaving behind fibrous soil dangling like exposed nerves. Dust and ash cling to edges of fractures, forming dirty halos around every broken surface, while charred soil crumbles into fine soot that collects in micro-crevices before drifting off into space. [getimg](https://getimg.ai/blog/create-haunting-halloween-art-with-ai-prompts-and-examples-inside)

The fruits’ skin appears thin and translucent, with fine capillary lines visible beneath, slightly too human to be comfortable. Tiny bubbles and blemishes deform their surfaces, as if the flesh is fermenting from inside, and subtle damp gloss along their lower edges hints that they might be leaking or sweating in fear. The pond should read like a mixture of water, oil, and sap: the surface shows faint ripples frozen mid-motion, and rainbow-slick sheens break the reflected image of the tree into warped, fractured ghosts. On the planet’s lower edge, the sand-like sap strands catch light like molten glass fibers, appearing both granular and sticky, a hybrid texture that can be described as “glass-sand sap” in prompts to guide generators toward gritty yet glossy material. [pixpretty.tenorshare](https://pixpretty.tenorshare.ai/ai-generator/spooky-ai-prompts.html)

### Camera Orientation Variants for Horror and Simulation

To support game and simulation contexts, TerraScape defines several canonical camera modes that all preserve the same core scene but shift emphasis and emotional feel. Horror game analysis strongly emphasizes that lens choice, FOV, and vantage point dramatically change tension, with narrow views and fixed or semi-fixed angles often producing stronger unease than free, wide cameras. [youtube](https://www.youtube.com/watch?v=PTnVyB1BkvQ)

1. **Cinematic Wide Establishing (Default TerraScape Frame)**  
   This is the primary art-style framing: a 35mm–40mm equivalent lens, slightly low angle, wide shot that captures the entire half-destroyed planet with the tree centered or slightly off-center. The FOV is moderate, keeping the planet large in frame while leaving negative space above and below for the green sky and void. This works well for title screens, key art, and cutscene stills, giving players a clear, iconic silhouette of the tree and the eaten planet.

2. **Fixed-Perspective Horror Plate (Side-Orbit)**  
   Inspired by fixed-camera survival horror, this orientation locks the camera on a slow orbit along one side of the planet, angled so that the void looms behind or beneath the tree. Lens can be 50mm–70mm equivalent, compressing space so the tree appears closer to the edge of the abyss, and FOV is slightly narrower to increase claustrophobia. In simulation contexts, the world can still update while the camera remains on a rail, emphasizing helpless observation rather than player control. [newgameplus.co](https://newgameplus.co.uk/2018/05/22/cinematography-of-horror-games/)

3. **Low-Ground Upward Terror Angle**  
   Here the camera is very close to the surface near the pond, almost at ground level, looking up at the tree so its face and reaching branches loom overhead. A 24mm–28mm lens exaggerates perspective, making branches stretch forward like grasping hands while the sky twists into an oppressive canopy of green and star-mist. This angle is suitable for encounter scenes or dialogue nodes focused on the tree as a character; the fruits overhead become a trembling chorus hanging above the viewer’s implied position.

4. **Top-Down Oracle View**  
   For management, strategy, or colony-sim style interactions, a high, near-top-down angle shows more of the planet’s surface and the structural damage while still keeping the tree recognizable as the central figure. The lens can be 35mm with a higher FOV to preserve curvature of the planet-disc, and depth-of-field can be slightly flattened for readability of smaller elements. Horror cinematography commentary notes that top-down shifts can make characters look small and powerless; TerraScape uses this to make the tree and fruits appear like pieces in a ritual board game watched by the moon. [newgameplus.co](https://newgameplus.co.uk/2018/05/22/cinematography-of-horror-games/)

5. **Void-Gaze Inversion Angle**  
   For especially unsettling sequences, the camera can be placed below the planet, looking up through the dripping sap streams toward the underside of the crust and the silhouetted tree above. A 16mm–20mm ultra-wide lens curves the planet’s bottom like a looming ceiling, and the void fills most of the frame, with light only from the moon filtering through sap and debris. This angle is ideal for cutscenes or scripted events where the player perspective “falls” beneath the world, or for still images emphasizing the abyss as the true subject.

Each of these orientations can be expressed in prompt tags such as “wide establishing shot,” “fixed camera horror angle,” “low-angle shot from ground level,” “top-down cinematic shot,” or “shot from beneath, looking up through dripping sap,” plus specific lens and FOV descriptions, which horror prompt guides suggest for more controllable composition. [dreadcentral](https://www.dreadcentral.com/editorials/471980/the-perspective-of-horror-atmospheric-use-of-the-camera/)

### Composition Rules for Simulation-Friendly Layouts

To ensure TerraScape works across UI overlays and interactive scenes, composition should reserve logical spaces for HUD, text, and gameplay elements. The central vertical band (roughly the middle third) is reserved for the tree and primary narrative focus, while the left and right thirds can host floating debris, distant galaxies, or subtle clouds with lower visual complexity, making them safe areas for UI labels or iconography. In top-down and side-orbit variants, the pond and nearby ground can act as diegetic UI anchors, where in-world markers or ritual circles appear without breaking the artstyle.

The void beneath the planet should be treated as flexible negative space. For menu screens, it can remain mostly black with faint drifting particles, ideal for logo placement or text prompts; for in-game scenes, subtle glowing shapes or distant falling fragments can be added to reflect player choices or narrative progress, without altering the core TerraScape palette or silhouette. This mirrors how horror games use fog, darkness, and skybox areas as adaptable “canvas” regions that can support overlays and dynamic elements while the core composition stays consistent. [newgameplus.co](https://newgameplus.co.uk/2018/05/22/cinematography-of-horror-games/)

### Lua-Oriented Hooks and Game Metrics

To integrate TerraScape more deeply into PromptLang-Lua and horror simulations, Section 2 adds structured hooks and new metrics that can be computed from prompt text or game-state variables and then fed back into generation or camera logic:

1. **BranchAggression Vector (BAV)** – A scalar or small vector describing how many branches are “attacking” (reaching toward fruits or viewer) versus “resting.” High BAV increases the chance of low-angle, confrontational camera shots and more contorted branch poses in the prompt.

2. **FruitTension Density (FTD)** – Measures how many worried fruits are explicitly present and how close they are to falling (e.g., dangling over the edge, held by a single branch). High FTD can drive more close-up shots of fruit clusters or trigger subtle animation-like variations (swaying, trembling) in generated sequences.

3. **CrustFracture Load (CFL)** – Represents how close the planet is to structural failure, based on the number and size of visible cracks and the intensity of sap-sand streams. In gameplay, CFL can map to difficulty or time pressure; in prompts, high CFL adds language like “severely fractured,” “almost torn in half,” or “on the verge of collapse.”

4. **VoidDominance Ratio (VDR)** – The proportion of the frame visually occupied by the void versus solid matter. High VDR configurations favor compositions like the Void-Gaze Inversion Angle or more negative space beneath the planet, increasing feelings of vertigo and insignificance.

5. **OracleGaze Alignment (OGA)** – Measures whether the moon’s “gaze” lines up with the tree, the fruits, or the viewer’s implied position. When OGA favors the viewer, descriptions like “the moon seems to glare directly at you” can be added to text; when it favors the fruits, more emphasis is placed on their role as judged subjects.

6. **LoreWhisper Intensity (LWI)** – A meta-metric indicating how strongly the prompt leans into implied mythology (mentions of “ancient oath,” “forgotten covenant,” “cursed years,” etc.). High LWI encourages the generator to add tiny symbolic details—carvings on the trunk, sigils around the pond, constellations shaped like eyes—while still keeping the core TerraScape layout.

These metrics can be implemented as Lua tables associated with a TerraScape scene object, updated by scripted events and then serialized back into text prompts or camera selection rules. RimWorld-style simulation notes emphasize performance-conscious ticking and selective updates; similarly, TerraScape metrics can be updated less frequently when the camera is static or the scene is in a distant overview, and more often during close-up or event-driven shots. [rimworldwiki](https://rimworldwiki.com/wiki/RimWorld_Wiki:To-do)

### Additional Art-Behavior Definitions (Section 2 Additions)

Continuing the requirement to evolve art-determination logic, Section 2 introduces three more abstract definitions tailored to TerraScape and horror routing:

8. **DecayOrbit Function (DOF)** – A procedural measure that maps how often elements in the scene (fruits, debris, sap streams) cross a conceptual “event horizon” around the planet’s edge. High DOF suggests an accelerated decay cycle and can automatically increase CFL and VDR, nudging the generator toward more chaotic compositions.

9. **MythicSilence Quotient (MSQ)** – Evaluates how much the scene relies on stillness and implied soundlessness: no visible wind, frozen particles, suspended sap mid-drip. Horror design discussions highlight silence and restraint as powerful tools; high MSQ encourages static but oppressive frames, while lower MSQ might justify more dynamic, storm-like visuals. [northernfilmorchestra](https://www.northernfilmorchestra.com/post/film-composers-5-tips-for-writing-horror-music)

10. **WitnessIsolation Metric (WIM)** – Represents whether any secondary entities (villages, other trees, orbiting bodies) are present. A maximal WIM (only the tree, fruits, and moon) amplifies cosmic loneliness; reducing WIM by adding small, distant signs of life or ruins can shift the tone toward tragic epics or broader worldbuilding without exiting the TerraScape style.
