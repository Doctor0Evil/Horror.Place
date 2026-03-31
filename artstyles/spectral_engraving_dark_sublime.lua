-- File: artstyles/spectral_engraving_dark_sublime.lua

local SpectralStyle = {}

SpectralStyle.id = "SPECTRAL_ENGRAVING_DARK_SUBLIME"

SpectralStyle.invariant_requirements = function(inv)
    return inv.cic  >= 0.75 and
           inv.mdi  >= 0.70 and
           inv.aos  >= 0.60 and
           inv.spr  >= 0.70 and
           inv.shci >= 0.80
end

SpectralStyle.metric_targets = {
    UEC  = { min = 0.60, max = 0.80 },
    EMD  = { min = 0.70, max = 0.90 },
    STCI = { min = 0.50, max = 0.70 },
    CDL  = { min = 0.70, max = 0.90 },
    ARR  = { min = 0.75, max = 1.00 }
}

SpectralStyle.visual_flags = {
    monochrome_only         = true,
    allow_color_temperature = false,
    high_contrast_required  = true,
    volumetric_light        = true,
    halo_backlighting       = true
}

SpectralStyle.semantic_tags = {
    "cosmic_insignificance",
    "human_mass_divinity",
    "sacramental_terror",
    "dark_sublime",
    "body_as_architecture"
}

return SpectralStyle
