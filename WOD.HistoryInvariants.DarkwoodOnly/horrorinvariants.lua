-- horrorinvariants.lua (in WOD.HistoryInvariants.DarkwoodOnly)
local H = {}
-- CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI, UEC..ARR accessors

function H.sample_all(region_id, tile_id)
  return {
    CIC  = H.CIC(region_id, tile_id),
    MDI  = H.MDI(region_id, tile_id),
    AOS  = H.AOS(region_id, tile_id),
    RRM  = H.RRM(region_id, tile_id),
    FCF  = H.FCF(region_id, tile_id),
    DET  = H.DET(region_id, tile_id),
    HVF  = H.HVF(region_id, tile_id),
    LSG  = H.LSG(region_id, tile_id),
    RWF  = H.RWF(region_id, tile_id),
    SPR  = H.SPR(region_id, tile_id),
    SHCI = H.SHCI(region_id, tile_id),
    UEC  = H.UEC(region_id, tile_id),
    EMD  = H.EMD(region_id, tile_id),
    STCI = H.STCI(region_id, tile_id),
    CDL  = H.CDL(region_id, tile_id),
    ARR  = H.ARR(region_id, tile_id)
  }
end

return H
