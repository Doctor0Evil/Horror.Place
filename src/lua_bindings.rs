//! Horror$Place Lua Engine Integration Layer
//! Version: 3.11A
//! Doctrine: Rivers of Blood Charter
//! 
//! This module provides Lua scripting bindings for the horror invariant system.
//! Enables AI-chat code generation, runtime horror automation, and engine integration.
//! Reference: Darkwood wiki - World-of-Darkwood style pipeline[^1_1]

#![warn(missing_docs)]
#![allow(dead_code)]

use std::sync::{Arc, RwLock};
use mlua::{Lua, Result as LuaResult, UserData, Function, Table, Value as LuaValue};
use serde::{Deserialize, Serialize};
use log::{info, warn, error};

use crate::invariant_engine::{
    InvariantEngine, RegionInvariants, HistoryLayer, SpectralLayer, 
    EntertainmentLayer, InvariantValue, RegionId, ManifestationType,
    CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI, 
    UEC, EMD, STCI, CDL, ARR
};
use crate::history_database::HistoryDatabase;

/// ============================================================================
/// LUA CONTEXT STRUCTURES
/// ============================================================================

/// Main Lua context for horror invariant operations
pub struct LuaHorrorContext {
    invariant_engine: Arc<RwLock<InvariantEngine>>,
    history_database: Arc<RwLock<HistoryDatabase>>,
    lua_runtime: Lua,
    script_cache: ScriptCache,
}

/// Cached Lua script with metadata
#[derive(Debug, Clone)]
pub struct CachedScript {
    pub script_id: String,
    pub source_code: String,
    pub hash: String,
    pub last_executed: u64,
    pub execution_count: u32,
    pub invariant_dependencies: Vec<InvariantId>,
}

/// Script cache for performance optimization
pub struct ScriptCache {
    scripts: std::collections::HashMap<String, CachedScript>,
    max_cache_size: usize,
}

impl ScriptCache {
    pub fn new(max_size: usize) -> Self {
        ScriptCache {
            scripts: std::collections::HashMap::new(),
            max_cache_size: max_size,
        }
    }

    pub fn get(&self, script_id: &str) -> Option<&CachedScript> {
        self.scripts.get(script_id)
    }

    pub fn insert(&mut self, script: CachedScript) {
        if self.scripts.len() >= self.max_cache_size {
            // Simple LRU: remove oldest
            if let Some(oldest_id) = self.scripts.iter()
                .min_by_key(|(_, s)| s.last_executed)
                .map(|(id, _)| id.clone())
            {
                self.scripts.remove(&oldest_id);
            }
        }
        self.scripts.insert(script.script_id.clone(), script);
    }
}

/// Horror event trigger result from Lua execution
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HorrorEventResult {
    pub event_id: String,
    pub triggered: bool,
    pub invariant_changes: Vec<InvariantChange>,
    pub spectral_manifestation: Option<SpectralManifestationData>,
    pub audio_cues: Vec<AudioCueData>,
    pub sanity_effect: Option<f32>,
}

/// Invariant change record for telemetry
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvariantChange {
    pub invariant_id: InvariantId,
    pub old_value: InvariantValue,
    pub new_value: InvariantValue,
    pub timestamp: u64,
}

/// Spectral manifestation data from Lua hooks
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpectralManifestationData {
    pub entity_type: String,
    pub intensity: InvariantValue,
    pub duration_seconds: f32,
    pub location: String,
}

/// Audio cue data for horror soundscapes
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AudioCueData {
    pub cue_id: String,
    pub volume: f32,
    pub pitch: f32,
    pub spatial_position: Option<(f32, f32, f32)>,
    pub loop_enabled: bool,
}

/// ============================================================================
/// LUA USER DATA WRAPPERS
/// ============================================================================

/// Lua-accessible wrapper for RegionInvariants
#[derive(Clone)]
pub struct LuaRegion {
    region_id: String,
    engine: Arc<RwLock<InvariantEngine>>,
}

impl UserData for LuaRegion {
    fn add_methods<'lua, M: mlua::UserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method("get_cic", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, CIC).unwrap_or(0.0))
        });

        methods.add_method("get_mdi", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, MDI).unwrap_or(0.0))
        });

        methods.add_method("get_aos", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, AOS).unwrap_or(0.0))
        });

        methods.add_method("get_rrm", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, RRM).unwrap_or(0.0))
        });

        methods.add_method("get_fcf", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, FCF).unwrap_or(0.0))
        });

        methods.add_method("get_spr", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, SPR).unwrap_or(0.0))
        });

        methods.add_method("get_det", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, DET).unwrap_or(0.0))
        });

        methods.add_method("get_lsg", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, LSG).unwrap_or(0.0))
        });

        methods.add_method("get_shci", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, SHCI).unwrap_or(0.0))
        });

        methods.add_method("get_uec", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, UEC).unwrap_or(0.0))
        });

        methods.add_method("get_emd", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, EMD).unwrap_or(0.0))
        });

        methods.add_method("get_stci", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, STCI).unwrap_or(0.0))
        });

        methods.add_method("get_cdl", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, CDL).unwrap_or(0.0))
        });

        methods.add_method("get_arr", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.get_invariant(&this.region_id, ARR).unwrap_or(0.0))
        });

        methods.add_method("get_all_invariants", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            let mut table = std::collections::HashMap::new();
            table.insert("CIC", engine.get_invariant(&this.region_id, CIC).unwrap_or(0.0));
            table.insert("MDI", engine.get_invariant(&this.region_id, MDI).unwrap_or(0.0));
            table.insert("AOS", engine.get_invariant(&this.region_id, AOS).unwrap_or(0.0));
            table.insert("RRM", engine.get_invariant(&this.region_id, RRM).unwrap_or(0.0));
            table.insert("FCF", engine.get_invariant(&this.region_id, FCF).unwrap_or(0.0));
            table.insert("SPR", engine.get_invariant(&this.region_id, SPR).unwrap_or(0.0));
            table.insert("DET", engine.get_invariant(&this.region_id, DET).unwrap_or(0.0));
            table.insert("LSG", engine.get_invariant(&this.region_id, LSG).unwrap_or(0.0));
            table.insert("SHCI", engine.get_invariant(&this.region_id, SHCI).unwrap_or(0.0));
            table.insert("UEC", engine.get_invariant(&this.region_id, UEC).unwrap_or(0.0));
            table.insert("EMD", engine.get_invariant(&this.region_id, EMD).unwrap_or(0.0));
            table.insert("STCI", engine.get_invariant(&this.region_id, STCI).unwrap_or(0.0));
            table.insert("CDL", engine.get_invariant(&this.region_id, CDL).unwrap_or(0.0));
            table.insert("ARR", engine.get_invariant(&this.region_id, ARR).unwrap_or(0.0));
            Ok(table)
        });

        methods.add_method("to_lua_table", |_, this, _: ()| {
            let engine = this.engine.read().unwrap();
            Ok(engine.export_to_lua_table(&this.region_id).unwrap_or_default())
        });
    }
}

/// Lua-accessible horror automation controller
pub struct LuaHorrorAutomation {
    context: Arc<LuaHorrorContext>,
}

impl UserData for LuaHorrorAutomation {
    fn add_methods<'lua, M: mlua::UserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method("emit_event", |_, this, args: (String, String, Table)| {
            let (event_type, region_id, params) = args;
            info!("Lua emitting event: {} in region {}", event_type, region_id);
            // In full implementation, this would trigger the actual event
            Ok(true)
        });

        methods.add_method("spawn_spirit", |_, this, args: (String, String, Table)| {
            let (spirit_type, region_id, params) = args;
            info!("Lua spawning spirit: {} in region {}", spirit_type, region_id);
            // In full implementation, this would spawn the spectral entity
            Ok(true)
        });

        methods.add_method("apply_sanity_damage", |_, this, args: (String, f32)| {
            let (entity_id, damage) = args;
            info!("Lua applying sanity damage: {} to entity {}", damage, entity_id);
            Ok(damage)
        });

        methods.add_method("log", |_, this, message: String| {
            info!("Lua Horror Automation Log: {}", message);
            Ok(())
        });

        methods.add_method("get_region", |lua, this, region_id: String| {
            let region = LuaRegion {
                region_id: region_id.clone(),
                engine: this.context.invariant_engine.clone(),
            };
            lua.create_userdata(region)
        });

        methods.add_method("calculate_spr", |_, this, args: (f32, f32, f32)| {
            let (cic, mdi, aos) = args;
            let spr = InvariantEngine::calculate_spr(cic, mdi, aos);
            Ok(spr)
        });

        methods.add_method("get_manifestation_type", |_, this, shci: f32| {
            let manifest_type = InvariantEngine::get_manifestation_type(shci);
            Ok(format!("{:?}", manifest_type))
        });
    }
}

/// ============================================================================
/// LUA CONTEXT IMPLEMENTATION
/// ============================================================================

impl LuaHorrorContext {
    /// Create new Lua horror context with invariant engine and history database
    pub fn new(
        invariant_engine: Arc<RwLock<InvariantEngine>>,
        history_database: Arc<RwLock<HistoryDatabase>>,
    ) -> LuaResult<Self> {
        let lua = Lua::new();
        let context = Arc::new(LuaHorrorContext {
            invariant_engine: invariant_engine.clone(),
            history_database: history_database.clone(),
            lua_runtime: lua,
            script_cache: ScriptCache::new(100),
        });

        // Initialize Lua globals
        context.initialize_lua_globals()?;

        Ok(context)
    }

    /// Initialize Lua global functions and tables
    fn initialize_lua_globals(&self) -> LuaResult<()> {
        let lua = &self.lua_runtime;

        // Create Horror$Place global table
        let horror_table = lua.create_table()?;
        
        // Add invariant query functions
        horror_table.set("CIC", lua.create_function(|_, region_id: String| {
            // This would query the actual engine in full implementation
            Ok(0.5f32)
        })?)?;

        horror_table.set("MDI", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("AOS", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("RRM", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("FCF", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("SPR", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("DET", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("LSG", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("SHCI", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("UEC", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("EMD", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("STCI", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("CDL", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        horror_table.set("ARR", lua.create_function(|_, region_id: String| {
            Ok(0.5f32)
        })?)?;

        // Add utility functions
        horror_table.set("calculate_spr", lua.create_function(|_, args: (f32, f32, f32)| {
            let (cic, mdi, aos) = args;
            Ok(InvariantEngine::calculate_spr(cic, mdi, aos))
        })?)?;

        horror_table.set("get_manifestation_type", lua.create_function(|_, shci: f32| {
            Ok(format!("{:?}", InvariantEngine::get_manifestation_type(shci)))
        })?)?;

        horror_table.set("log", lua.create_function(|_, message: String| {
            info!("Lua Horror Log: {}", message);
            Ok(())
        })?)?;

        // Add automation controller
        let automation = LuaHorrorAutomation {
            context: Arc::new(LuaHorrorContext {
                invariant_engine: self.invariant_engine.clone(),
                history_database: self.history_database.clone(),
                lua_runtime: Lua::new(), // Placeholder
                script_cache: ScriptCache::new(100),
            }),
        };
        horror_table.set("automation", lua.create_userdata(automation)?)?;

        // Set as global
        lua.globals().set("Horror", horror_table)?;

        // Load Rivers of Blood Charter specific functions
        self.load_rivers_of_blood_functions()?;

        info!("Lua horror globals initialized successfully");
        Ok(())
    }

    /// Load Rivers of Blood Charter specific Lua functions
    fn load_rivers_of_blood_functions(&self) -> LuaResult<()> {
        let lua = &self.lua_runtime;

        let rivers_code = r#"
-- Rivers of Blood Charter Lua Functions
-- Version: 3.11A

function Horror.Rivers.UpdateFlow(region_id, dt)
    local cic = Horror.CIC(region_id)
    local aos = Horror.AOS(region_id)
    local hvf = Horror.HVF(region_id)
    local flux = (cic * aos) * (hvf + 0.1)
    
    Horror.emit("blood_flux", flux)
    
    if flux > 0.75 then
        Horror.spawn_spirit("Hemophage", region_id, { shci = Horror.SHCI(region_id) })
    end
    
    return flux
end

function Horror.Rivers.OnInvestigatorEnter(entity_id, region_id)
    local det = Horror.DET(region_id)
    if det < 0.7 then
        Horror.apply_sanity_damage(entity_id, det * 0.3)
        Horror.log("Investigator feels arterial pull in the soil.")
    end
end

function Horror.Rivers.GetFlowIntensity(region_id)
    local cic = Horror.CIC(region_id)
    local rrm = Horror.RRM(region_id)
    local fcf = Horror.FCF(region_id)
    return (cic + rrm + fcf) / 3.0
end

function Horror.Rivers.CheckCharterCompliance(region_id)
    local cic = Horror.CIC(region_id)
    local shci = Horror.SHCI(region_id)
    local arr = Horror.ARR(region_id)
    
    local compliant = cic >= 0.85 and shci >= 0.9 and arr >= 0.7
    Horror.log("Charter compliance check: " .. tostring(compliant))
    return compliant
end
"#;

        lua.load(rivers_code).exec()?;
        info!("Rivers of Blood Charter Lua functions loaded");
        Ok(())
    }

    /// Execute Lua script with invariant context
    pub fn execute_script(&self, script_id: &str, source_code: &str) -> LuaResult<LuaValue> {
        // Check cache first
        if let Some(cached) = self.script_cache.get(script_id) {
            if cached.source_code == source_code {
                info!("Using cached script: {}", script_id);
            }
        }

        // Execute script
        let result = self.lua_runtime.load(source_code).eval()?;

        // Update cache
        let script = CachedScript {
            script_id: script_id.to_string(),
            source_code: source_code.to_string(),
            hash: format!("{:x}", md5::compute(source_code.as_bytes())),
            last_executed: 0, // Would use actual timestamp
            execution_count: 1,
            invariant_dependencies: vec![CIC, MDI, AOS, SHCI], // Would parse from source
        };

        // Note: Need mutable access for cache update
        // In production, use RwLock for script_cache

        Ok(result)
    }

    /// Execute Lua script with parameters
    pub fn execute_script_with_params(
        &self,
        script_id: &str,
        source_code: &str,
        params: Table,
    ) -> LuaResult<LuaValue> {
        // Set params in Lua context
        self.lua_runtime.globals().set("params", params)?;
        
        // Execute
        self.execute_script(script_id, source_code)
    }

    /// Load Lua script from file
    pub fn load_script_from_file(&self, file_path: &str) -> LuaResult<String> {
        use std::fs;
        let source_code = fs::read_to_string(file_path)
            .map_err(|e| mlua::Error::RuntimeError(format!("Failed to read file: {}", e)))?;
        Ok(source_code)
    }

    /// Register Lua horror event handler
    pub fn register_event_handler(
        &self,
        event_name: &str,
        handler_code: &str,
    ) -> LuaResult<()> {
        let lua = &self.lua_runtime;
        
        // Create event handler table if it doesn't exist
        let handlers: Option<Table> = lua.globals().get("HorrorEventHandlers")?;
        let handlers = handlers.unwrap_or_else(|| lua.create_table().unwrap());
        
        // Set handler function
        let handler_func = lua.load(handler_code).into_function()?;
        handlers.set(event_name, handler_func)?;
        
        lua.globals().set("HorrorEventHandlers", handlers)?;
        
        info!("Registered event handler for: {}", event_name);
        Ok(())
    }

    /// Trigger Lua horror event
    pub fn trigger_event(
        &self,
        event_name: &str,
        region_id: &str,
        additional_data: Table,
    ) -> LuaResult<HorrorEventResult> {
        let lua = &self.lua_runtime;
        
        // Get event handlers
        let handlers: Option<Table> = lua.globals().get("HorrorEventHandlers")?;
        
        if let Some(handlers) = handlers {
            let handler: Option<Function> = handlers.get(event_name)?;
            
            if let Some(handler) = handler {
                let result: LuaValue = handler.call((region_id, additional_data))?;
                
                // Convert Lua result to HorrorEventResult
                // In full implementation, this would parse the Lua table
                return Ok(HorrorEventResult {
                    event_id: event_name.to_string(),
                    triggered: true,
                    invariant_changes: vec![],
                    spectral_manifestation: None,
                    audio_cues: vec![],
                    sanity_effect: None,
                });
            }
        }
        
        Ok(HorrorEventResult {
            event_id: event_name.to_string(),
            triggered: false,
            invariant_changes: vec![],
            spectral_manifestation: None,
            audio_cues: vec![],
            sanity_effect: None,
        })
    }

    /// Export invariant data to Lua table format
    pub fn export_invariants_to_lua(&self, region_id: &str) -> LuaResult<String> {
        let engine = self.invariant_engine.read().unwrap();
        Ok(engine.export_to_lua_table(region_id).unwrap_or_default())
    }

    /// Get Lua runtime reference for advanced operations
    pub fn get_lua_runtime(&self) -> &Lua {
        &self.lua_runtime
    }

    /// Validate Lua script syntax without execution
    pub fn validate_script_syntax(&self, source_code: &str) -> LuaResult<bool> {
        match self.lua_runtime.load(source_code).into_function() {
            Ok(_) => Ok(true),
            Err(e) => {
                warn!("Lua script syntax error: {}", e);
                Err(e)
            }
        }
    }

    /// Get script execution statistics
    pub fn get_script_statistics(&self) -> ScriptStatistics {
        ScriptStatistics {
            cached_scripts: self.script_cache.scripts.len(),
            max_cache_size: self.script_cache.max_cache_size,
            // In full implementation, would track execution times, errors, etc.
        }
    }
}

/// Script execution statistics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScriptStatistics {
    pub cached_scripts: usize,
    pub max_cache_size: usize,
}

/// ============================================================================
/// RIVERS OF BLOOD CHARTER LUA TEMPLATES
/// ============================================================================

/// Standard Rivers of Blood Lua script template
pub const RIVERS_UPDATE_SCRIPT: &str = r#"
-- Rivers of Blood Flow Update Script
-- Doctrine Version: 3.11A
-- Invariant Dependencies: CIC, AOS, HVF, SHCI

local region_id = params.region_id or "default"
local dt = params.dt or 0.016

local cic = Horror.CIC(region_id)
local aos = Horror.AOS(region_id)
local hvf = Horror.HVF(region_id)
local shci = Horror.SHCI(region_id)

-- Calculate blood flux intensity
local flux = (cic * aos) * (hvf + 0.1)

-- Emit flux event for audio/visual systems
Horror.emit("blood_flux", flux)

-- Spawn spectral entity if flux threshold exceeded
if flux > 0.75 then
    Horror.spawn_spirit("Hemophage", region_id, { 
        shci = shci,
        intensity = flux,
        duration = 30.0
    })
    Horror.log("Hemophage manifested in " .. region_id)
end

-- Return flux value for telemetry
return {
    flux = flux,
    manifestation_triggered = flux > 0.75,
    region_id = region_id
}
"#;

/// Standard investigator entry script template
pub const INVESTIGATOR_ENTRY_SCRIPT: &str = r#"
-- Investigator Entry Sanity Check Script
-- Doctrine Version: 3.11A
-- Invariant Dependencies: DET, CIC, SHCI

local entity_id = params.entity_id or "player"
local region_id = params.region_id or "default"

local det = Horror.DET(region_id)
local cic = Horror.CIC(region_id)
local shci = Horror.SHCI(region_id)

-- Apply sanity damage based on DET
local sanity_damage = 0.0
if det < 0.7 then
    sanity_damage = det * 0.3
    Horror.apply_sanity_damage(entity_id, sanity_damage)
    Horror.log("Investigator feels arterial pull in the soil.")
end

-- Increase spectral activity if CIC is high
if cic > 0.85 then
    Horror.emit("spectral_pressure", cic * shci)
end

return {
    sanity_damage = sanity_damage,
    det = det,
    cic = cic,
    safe_to_linger = det >= 0.7
}
"#;

/// Standard spectral manifestation script template
pub const SPECTRAL_MANIFESTATION_SCRIPT: &str = r#"
-- Spectral Manifestation Control Script
-- Doctrine Version: 3.11A
-- Invariant Dependencies: SHCI, SPR, LSG, HVF

local region_id = params.region_id or "default"
local manifestation_type = params.manifestation_type or "auto"

local shci = Horror.SHCI(region_id)
local spr = Horror.SPR(region_id)
local lsg = Horror.LSG(region_id)

-- Determine manifestation type if auto
if manifestation_type == "auto" then
    manifestation_type = Horror.get_manifestation_type(shci)
end

-- Calculate manifestation intensity
local intensity = (shci + spr + lsg) / 3.0

-- Spawn appropriate spectral entity
Horror.spawn_spirit(manifestation_type, region_id, {
    intensity = intensity,
    shci = shci,
    spr = spr
})

Horror.log("Spectral manifestation: " .. manifestation_type .. " in " .. region_id)

return {
    manifestation_type = manifestation_type,
    intensity = intensity,
    region_id = region_id
}
"#;

/// Standard entertainment metrics check script template
pub const ENTERTAINMENT_METRICS_SCRIPT: &str = r#"
-- Entertainment Metrics Validation Script
-- Doctrine Version: 3.11A
-- Invariant Dependencies: UEC, EMD, STCI, CDL, ARR

local region_id = params.region_id or "default"

local uec = Horror.UEC(region_id)
local emd = Horror.EMD(region_id)
local stci = Horror.STCI(region_id)
local cdl = Horror.CDL(region_id)
local arr = Horror.ARR(region_id)

-- Validate entertainment balance
local issues = {}

if uec < 0.5 or uec > 0.9 then
    table.insert(issues, "UEC out of optimal range (0.5-0.9)")
end

if emd < 0.4 then
    table.insert(issues, "EMD too low - not enough mystery clues")
end

if stci < 0.5 then
    table.insert(issues, "STCI too low - insufficient safe-threat contrast")
end

if cdl < 0.5 then
    table.insert(issues, "CDL too low - not enough cognitive dissonance")
end

if arr < 0.6 then
    table.insert(issues, "ARR too low - too many resolved mysteries")
end

local balanced = #issues == 0

Horror.log("Entertainment balance check: " .. tostring(balanced))
if not balanced then
    for _, issue in ipairs(issues) do
        Horror.log("  Issue: " .. issue)
    end
end

return {
    balanced = balanced,
    issues = issues,
    metrics = {
        uec = uec,
        emd = emd,
        stci = stci,
        cdl = cdl,
        arr = arr
    }
}
"#;

/// ============================================================================
/// UNIT TESTS
/// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::{Arc, RwLock};
    use crate::invariant_engine::{InvariantEngine, create_rivers_of_blood_region};
    use crate::history_database::HistoryDatabase;

    #[test]
    fn test_lua_context_creation() {
        let engine = Arc::new(RwLock::new(InvariantEngine::new()));
        let db = Arc::new(RwLock::new(HistoryDatabase::new(engine.clone())));
        
        let context = LuaHorrorContext::new(engine, db);
        assert!(context.is_ok());
    }

    #[test]
    fn test_lua_script_execution() {
        let engine = Arc::new(RwLock::new(InvariantEngine::new()));
        let db = Arc::new(RwLock::new(HistoryDatabase::new(engine.clone())));
        
        let context = LuaHorrorContext::new(engine, db).unwrap();
        
        let simple_script = r#"
            return 42
        "#;
        
        let result = context.execute_script("test_simple", simple_script);
        assert!(result.is_ok());
    }

    #[test]
    fn test_rivers_script_template() {
        let engine = Arc::new(RwLock::new(InvariantEngine::new()));
        let db = Arc::new(RwLock::new(HistoryDatabase::new(engine.clone())));
        
        let context = LuaHorrorContext::new(engine, db).unwrap();
        
        // Validate syntax of Rivers script template
        let valid = context.validate_script_syntax(RIVERS_UPDATE_SCRIPT);
        assert!(valid.is_ok());
    }

    #[test]
    fn test_investigator_script_template() {
        let engine = Arc::new(RwLock::new(InvariantEngine::new()));
        let db = Arc::new(RwLock::new(HistoryDatabase::new(engine.clone())));
        
        let context = LuaHorrorContext::new(engine, db).unwrap();
        
        let valid = context.validate_script_syntax(INVESTIGATOR_ENTRY_SCRIPT);
        assert!(valid.is_ok());
    }

    #[test]
    fn test_entertainment_metrics_script() {
        let engine = Arc::new(RwLock::new(InvariantEngine::new()));
        let db = Arc::new(RwLock::new(HistoryDatabase::new(engine.clone())));
        
        let context = LuaHorrorContext::new(engine, db).unwrap();
        
        let valid = context.validate_script_syntax(ENTERTAINMENT_METRICS_SCRIPT);
        assert!(valid.is_ok());
    }

    #[test]
    fn test_lua_region_wrapper() {
        let mut engine = InvariantEngine::new();
        
        // Register a test region
        let region = create_rivers_of_blood_region("test_lua_region");
        let _ = engine.register_region(region);
        
        let engine = Arc::new(RwLock::new(engine));
        let db = Arc::new(RwLock::new(HistoryDatabase::new(engine.clone())));
        
        let lua_region = LuaRegion {
            region_id: "test_lua_region".to_string(),
            engine: engine.clone(),
        };
        
        // Test that we can create the userdata
        let lua = Lua::new();
        let result = lua.create_userdata(lua_region);
        assert!(result.is_ok());
    }
}
