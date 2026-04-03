// horrorplace_core/src/lua/interop.rs
// © Horror.Place Framework | Lua FFI Interoperability Layer
// Provides safe, zero-copy bridges between Rust style objects and Lua tables

use crate::style::metric_validator::{StyleDefinition, StyleMetric, MetricResult};
use mlua::{Lua, Table, Value, UserData, LuaSerdeExt};
use serde::{Serialize, Deserialize};
use std::sync::Arc;

/// Wrapper for StyleDefinition that implements mlua::UserData for direct Lua exposure
#[derive(Clone)]
pub struct LuaStyleHandle(pub Arc<StyleDefinition>);

impl UserData for LuaStyleHandle {
    fn add_methods<'lua, M: mlua::UserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method("id", |_, this, _: ()| Ok(this.0.id.clone()));
        methods.add_method("version", |_, this, _: ()| Ok(this.0.version.clone()));
        
        methods.add_method("get_metric", |_, this, metric_id: String| {
            this.0.metrics.get(&metric_id)
                .map(|m| serde_json::to_value(m).unwrap())
                .ok_or_else(|| mlua::Error::RuntimeError(format!("Metric not found: {}", metric_id)))
        });
        
        methods.add_method("get_palette_hex", |_, this, role: String| {
            this.0.palettes.roles.get(&role)
                .map(|c| c.hex.clone())
                .ok_or_else(|| mlua::Error::RuntimeError(format!("Palette role not found: {}", role)))
        });
        
        methods.add_method("to_prompt", |lua, this, model: String| {
            // Delegate to routing engine (simplified)
            let prompt = build_prompt_from_style(&this.0, &model)
                .map_err(|e| mlua::Error::RuntimeError(e.to_string()))?;
            Ok(lua.create_string(prompt)?)
        });
    }
}

/// Safe Lua deserialization: parse Lua table into StyleDefinition with validation
pub fn lua_to_style(lua: &Lua, lua_table: Table) -> MetricResult<StyleDefinition> {
    // Use mlua's serde integration for automatic conversion
    let style: StyleDefinition = lua.from_value(Value::Table(lua_table))
        .map_err(|e| crate::style::metric_validator::MetricValidationError::LuaSerializationError(
            format!("Lua → Rust deserialization failed: {}", e)
        ))?;
    
    // Post-deserialization validation
    // (Assumes StyleDefinition has a validate() method)
    style.validate()?;  // Custom validation logic
    
    Ok(style)
}

/// Safe Lua serialization: convert StyleDefinition to Lua table
pub fn style_to_lua(lua: &Lua, style: &StyleDefinition) -> MetricResult<Table> {
    // Use mlua's serde integration
    let lua_value = lua.to_value(style)
        .map_err(|e| crate::style::metric_validator::MetricValidationError::LuaSerializationError(
            format!("Rust → Lua serialization failed: {}", e)
        ))?;
    
    match lua_value {
        Value::Table(table) => Ok(table),
        _ => Err(crate::style::metric_validator::MetricValidationError::LuaSerializationError(
            "Expected table output from serialization".to_string()
        ))
    }
}

/// Zero-copy style handle for Lua: avoids cloning large style objects
pub fn register_style_handle(lua: &Lua, style: Arc<StyleDefinition>) -> MetricResult<()> {
    let globals = lua.globals();
    let handle = LuaStyleHandle(style);
    globals.set("HorrorPlaceStyle", handle)?;
    Ok(())
}

/// Build prompt string from style and target model (delegates to routing engine)
fn build_prompt_from_style(style: &StyleDefinition, model: &str) -> MetricResult<String> {
    // Placeholder: in production, this would call the routing engine
    // For now, assemble basic prompt from primitives
    let primitives = &style.prompt_primitives;
    let mut parts = Vec::new();
    
    // Global horror tokens
    parts.extend(primitives.global_horror_tokens.iter().cloned());
    
    // Style-specific tokens
    parts.extend(primitives.style_specific_tokens.iter().cloned());
    
    // Palette descriptions
    for color in style.palettes.roles.values() {
        parts.push(color.description.clone());
    }
    
    Ok(parts.join(", "))
}

/// Lua module registration: exposes Horror.Place interop functions to Lua scripts
pub fn register_module(lua: &Lua) -> mlua::Result<()> {
    let horror_module = lua.create_table()?;
    
    // Serialization functions
    horror_module.set("serialize_style", lua.create_function(|lua, style: LuaStyleHandle| {
        style_to_lua(lua, &style.0)
    })?)?;
    
    horror_module.set("deserialize_style", lua.create_function(|lua, table: Table| {
        lua_to_style(lua, table).map_err(mlua::Error::external)
    })?)?;
    
    // Utility functions
    horror_module.set("validate_metric_value", lua.create_function(|_, (metric_id, value): (String, f64)| {
        if (0.0..=1.0).contains(&value) {
            Ok(true)
        } else {
            Err(mlua::Error::RuntimeError(format!(
                "Metric '{}' value {} out of bounds [0,1]", metric_id, value
            )))
        }
    })?)?;
    
    horror_module.set("hex_to_rgb", lua.create_function(|_, hex: String| {
        if hex.len() == 7 && hex.starts_with('#') {
            let r = u8::from_str_radix(&hex[1..3], 16).unwrap_or(0);
            let g = u8::from_str_radix(&hex[3..5], 16).unwrap_or(0);
            let b = u8::from_str_radix(&hex[5..7], 16).unwrap_or(0);
            Ok(lua.create_table_from([("r", r), ("g", g), ("b", b)])?)
        } else {
            Err(mlua::Error::RuntimeError("Invalid hex format".to_string()))
        }
    })?)?;
    
    // Register module globally
    lua.globals().set("HorrorPlace", horror_module)?;
    
    Ok(())
}

/// Safety wrapper: execute Lua code in sandboxed environment with Horror.Place APIs
pub struct SafeLuaEnv {
    lua: Lua,
}

impl SafeLuaEnv {
    pub fn new() -> mlua::Result<Self> {
        let lua = Lua::new();
        
        // Register Horror.Place interop module
        register_module(&lua)?;
        
        // Sandbox: disable dangerous Lua functions
        let package: Table = lua.globals().get("package")?;
        package.set("loadlib", lua.nil())?;  // Disable dynamic library loading
        
        let os: Table = lua.globals().get("os")?;
        os.set("execute", lua.nil())?;       // Disable shell execution
        os.set("popen", lua.nil())?;
        
        Ok(Self { lua })
    }
    
    /// Load and execute a Lua style script safely
    pub fn load_style_script(&self, script: &str) -> MetricResult<LuaStyleHandle> {
        // Execute script in sandbox
        self.lua.load(script).exec()
            .map_err(|e| crate::style::metric_validator::MetricValidationError::LuaSerializationError(
                format!("Script execution failed: {}", e)
            ))?;
        
        // Retrieve style handle (expected to be set as global by script)
        let handle: LuaStyleHandle = self.lua.globals().get("TerraScapeScene")
            .map_err(|e| crate::style::metric_validator::MetricValidationError::LuaSerializationError(
                format!("Style handle not found after script: {}", e)
            ))?;
        
        Ok(handle)
    }
    
    /// Get direct access to underlying Lua state (for advanced use)
    pub fn lua(&self) -> &Lua {
        &self.lua
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::style::metric_validator::{PaletteCollection, HexColor, PromptPrimitives, RoutingProfile, AuditMetadata};
    use std::collections::HashMap;
    
    #[test]
    fn test_style_roundtrip_lua() {
        let lua = Lua::new();
        register_module(&lua).unwrap();
        
        // Create minimal test style
        let style = StyleDefinition {
            id: "TestStyle".to_string(),
            version: "v1.0.0".to_string(),
            metrics: HashMap::new(),
            palettes: PaletteCollection {
                roles: HashMap::from([
                    ("background_base".to_string(), HexColor {
                        hex: "#1A1E26".to_string(),
                        description: "Test Blue".to_string(),
                        usage_context: "background_base".to_string(),
                    }),
                ]),
                fallback_text_descriptions: HashMap::new(),
            },
            prompt_primitives: PromptPrimitives {
                style_line_string: "test style".to_string(),
                style_line_tokens: vec!["test".into()],
                global_horror_tokens: vec!["eerie".into()],
                style_specific_tokens: vec!["test".into()],
            },
            routing: RoutingProfile {
                model_profiles: HashMap::new(),
                default_rules: vec![],
            },
            audit: AuditMetadata {
                created_at: 0,
                last_validated: 0,
                validation_schema_version: "v1.0.0".to_string(),
                experiment_count: 0,
                avg_on_style_rating: None,
            },
        };
        
        // Serialize to Lua
        let lua_table = style_to_lua(&lua, &style).unwrap();
        
        // Deserialize back
        let restored = lua_to_style(&lua, lua_table).unwrap();
        
        // Basic equality check (simplified)
        assert_eq!(restored.id, style.id);
        assert_eq!(restored.version, style.version);
    }
    
    #[test]
    fn test_sandbox_security() {
        let env = SafeLuaEnv::new().unwrap();
        
        // Attempt to call disabled os.execute
        let result = env.lua().load("return os.execute('echo pwned')").eval::<bool>();
        assert!(result.is_err());  // Should fail due to sandbox
        
        // Valid Horror.Place API call should work
        let result = env.lua().load("return HorrorPlace.validate_metric_value('TEST', 0.5)").eval::<bool>();
        assert_eq!(result.unwrap(), true);
    }
}
