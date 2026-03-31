-- File: artstyles/machine_canyon_biomech_bci.lua

local Style = {}

Style.id = "MACHINE_CANYON_BIOMECH_BCI"

Style.invariant_requirements = function(inv)
    return inv.cic  >= 0.60 and
           inv.mdi  >= 0.50 and
           inv.aos  >= 0.70 and
           inv.fcf  >= 0.60 and
           inv.spr  >= 0.65 and
           inv.shci >= 0.70
end

Style.metric_targets = {
    UEC  = { min = 0.50, max = 0.75 },
    EMD  = { min = 0.60, max = 0.85 },
    STCI = { min = 0.40, max = 0.70 },
    CDL  = { min = 0.70, max = 0.90 },
    ARR  = { min = 0.70, max = 1.00 }
}

Style.visual_flags = {
    allow_color              = true,
    palette_desaturation     = 0.85, -- high desaturation
    max_saturation           = 0.2,
    use_muted_biomech_wash   = true,
    dense_hatching_required  = true,
    forbid_clean_metal       = true
}

Style.semantic_tags = {
    "mechanism_over_organism",
    "human_as_process_input",
    "industrial_megastructure",
    "existential_mechanical_dread"
}

Style.region_bias = 0.0

return Style
