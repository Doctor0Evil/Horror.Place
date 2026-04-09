local Discovery = {}

-- Returns a Lua table that matches schemas/tooling/discovery-contract-v1.json
function Discovery.capability_contract(spine_index, manifests, registries, agent_profile_id)
    local now = os.date("!%Y-%m-%dT%H:%M:%SZ")

    return {
        id = "discovery-" .. tostring(math.random(1, 10^9)),
        schemaVersion = "discovery-contract.v1",
        agentProfileId = agent_profile_id,
        generatedAt = now,
        spineRefs = {
            invariantsSpineId = spine_index.invariants_id,
            entertainmentMetricsSpineId = spine_index.metrics_id,
            schemaSpineIndexId = spine_index.schema_index_id
        },
        manifestRefs = manifests or {},
        registryRefs = registries or {}
    }
end

return Discovery
