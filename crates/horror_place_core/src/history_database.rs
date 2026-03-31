//! Horror$Place History Database Query Layer
//! Version: 3.11A
//! Doctrine: Rivers of Blood Charter
//! 
//! This module provides structured query capabilities for the geo-historical database.
//! Each region/tile/POI stores structured facts and soft facts with numeric weights.
//! Reference: Darkwood wiki - World-of-Darkwood style pipeline[^1_1]

#![warn(missing_docs)]
#![allow(dead_code)]

use std::collections::{HashMap, HashSet};
use std::fmt;
use std::sync::{Arc, RwLock};
use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

use crate::invariant_engine::{
    InvariantEngine, RegionInvariants, HistoryLayer, InvariantValue, 
    RegionId, ValidationStatus, CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, LSG, HVF
};

/// ============================================================================
/// GEO-HISTORICAL DATABASE STRUCTURES
/// ============================================================================

/// Primary geo-historical record for a region
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoricalRecord {
    pub region_id: RegionId,
    pub coordinates: GeoCoordinates,
    pub catastrophe_events: Vec<CatastropheEvent>,
    pub mythic_entries: Vec<MythicEntry>,
    pub archival_documents: Vec<ArchivalDocument>,
    pub ritual_activities: Vec<RitualActivity>,
    pub folkloric_convergences: Vec<FolkloricConvergence>,
    pub source_reliability: SourceReliabilityMap,
    pub temporal_metadata: TemporalMetadata,
}

/// Geographic coordinates with elevation and biome data
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GeoCoordinates {
    pub x: f64,
    pub y: f64,
    pub elevation: f32,
    pub biome_type: BiomeType,
    pub sub_region: String,
}

/// Biome types inspired by Darkwood and Aral Sea settings
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum BiomeType {
    DenseForest,
    DryMeadow,
    Swamp,
    ScorchedDesert,
    Marshland,
    IndustrialWasteland,
    AbandonedSettlement,
    WaterBody,
    Underground,
    LiminalZone,
}

/// Catastrophic event record (man-made or natural disasters)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CatastropheEvent {
    pub event_id: String,
    pub event_type: CatastropheType,
    pub date_recorded: Option<String>,
    pub casualty_estimate: Option<u32>,
    pub severity_rating: InvariantValue,
    pub documented: bool,
    pub verification_status: VerificationStatus,
    pub affected_radius_km: f32,
    pub long_term_effects: Vec<String>,
}

/// Types of catastrophes that leave historical imprints
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum CatastropheType {
    Massacre,
    IndustrialAccident,
    PlagueOutbreak,
    WeaponTrial,
    EnvironmentalCollapse,
    ForcedEvacuation,
    DisappearanceEvent,
    BiologicalExperiment,
    RadiationIncident,
    UnknownCalamity,
}

/// Verification status for historical claims
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum VerificationStatus {
    Confirmed,
    Likely,
    Disputed,
    Unverified,
    Contradicted,
    Redacted,
}

/// Mythic entry (rumors, urban legends, folklore)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MythicEntry {
    pub myth_id: String,
    pub myth_type: MythType,
    pub narrative_text: String,
    pub origin_source: String,
    pub propagation_count: u32,
    pub consistency_score: InvariantValue,
    pub first_recorded: Option<String>,
    pub related_entities: Vec<String>,
}

/// Categories of myths and legends
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum MythType {
    Apparition,
    CursedLocation,
    VanishingStory,
    RitualLegend,
    CreatureSighting,
    TemporalAnomaly,
    EnvironmentalHaunting,
    WarningTale,
    OriginMyth,
    ConspiracyTheory,
}

/// Archival document (official records, diaries, reports)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ArchivalDocument {
    pub document_id: String,
    pub document_type: DocumentType,
    pub title: String,
    pub author: Option<String>,
    pub date_created: Option<String>,
    pub completeness_score: InvariantValue,
    pub contradiction_flags: Vec<String>,
    pub redaction_level: InvariantValue,
    pub access_classification: AccessLevel,
    pub content_hash: String,
}

/// Document classification types
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum DocumentType {
    OfficialReport,
    PersonalDiary,
    NewspaperArticle,
    MilitaryRecord,
    MedicalFile,
    CultTract,
    EyewitnessTestimony,
    ScientificStudy,
    PoliceRecord,
    PropagandaMaterial,
}

/// Access classification for documents
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum AccessLevel {
    Public,
    Restricted,
    Classified,
    Blacklisted,
    Lost,
}

/// Ritual activity record (structured repeated behaviors)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RitualActivity {
    pub ritual_id: String,
    pub ritual_type: RitualType,
    pub frequency: RitualFrequency,
    pub participant_estimate: Option<u32>,
    pub location_precision: InvariantValue,
    pub success_documented: bool,
    pub residual_effects: Vec<String>,
    pub last_known_occurrence: Option<String>,
}

/// Types of ritual activities
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum RitualType {
    OccultCeremony,
    MilitaryDrill,
    ScientificExperiment,
    ReligiousRite,
    PurificationAttempt,
    ContainmentProcedure,
    SacrificialAct,
    SummoningRitual,
    TestingProtocol,
    UnknownPractice,
}

/// Frequency of ritual occurrences
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum RitualFrequency {
    OneTime,
    Rare,
    Periodic,
    Frequent,
    Continuous,
}

/// Folkloric convergence (multiple storylines pointing to same location)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FolkloricConvergence {
    pub convergence_id: String,
    pub contributing_cultures: Vec<String>,
    pub time_periods: Vec<String>,
    pub common_motifs: Vec<String>,
    pub convergence_strength: InvariantValue,
    pub narrative_pressure: InvariantValue,
}

/// Source reliability mapping (RWF calculations)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SourceReliabilityMap {
    pub sources: HashMap<String, SourceEntry>,
    pub aggregated_credibility: InvariantValue,
    pub contradiction_count: u32,
}

/// Individual source entry with reliability weighting
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SourceEntry {
    pub source_id: String,
    pub source_type: SourceType,
    pub credibility_score: InvariantValue,
    pub bias_indicators: Vec<String>,
    pub cross_verified: bool,
}

/// Source types for reliability weighting
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum SourceType {
    OfficialGovernment,
    ScientificInstitution,
    MediaOutlet,
    PersonalAccount,
    OralTradition,
    ArtifactEvidence,
    AnonymousTip,
    PropagandaSource,
}

/// Temporal metadata for historical records
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TemporalMetadata {
    pub earliest_event: Option<String>,
    pub latest_event: Option<String>,
    pub gap_periods: Vec<TimeGap>,
    pub timeline_consistency: InvariantValue,
    pub last_updated: DateTime<Utc>,
}

/// Time gap in historical records (contributes to AOS)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TimeGap {
    pub start_date: String,
    pub end_date: String,
    pub gap_reason: Option<String>,
    pub suspicion_level: InvariantValue,
}

/// ============================================================================
/// HISTORY DATABASE ENGINE
/// ============================================================================

/// Main database engine for geo-historical queries
pub struct HistoryDatabase {
    records: HashMap<RegionId, HistoricalRecord>,
    invariant_engine: Arc<RwLock<InvariantEngine>>,
    query_cache: HashMap<String, CachedQueryResult>,
    index_by_biome: HashMap<BiomeType, HashSet<RegionId>>,
    index_by_catastrophe: HashMap<CatastropheType, HashSet<RegionId>>,
    index_by_convergence: HashMap<String, HashSet<RegionId>>,
}

/// Cached query result for performance
#[derive(Debug, Clone)]
pub struct CachedQueryResult {
    pub query_hash: String,
    pub result: Vec<RegionId>,
    pub timestamp: DateTime<Utc>,
    pub ttl_seconds: u64,
}

/// Query builder for complex historical searches
pub struct HistoryQueryBuilder {
    database: Arc<RwLock<HistoryDatabase>>,
    filters: Vec<QueryFilter>,
    sort_by: Option<SortCriterion>,
    limit: Option<usize>,
}

/// Query filter types for historical database
#[derive(Debug, Clone)]
pub enum QueryFilter {
    BiomeType(BiomeType),
    MinCIC(InvariantValue),
    MinMDI(InvariantValue),
    MinAOS(InvariantValue),
    MinFCF(InvariantValue),
    CatastropheType(CatastropheType),
    MythType(MythType),
    VerificationStatus(VerificationStatus),
    DateRange(String, String),
    HasDocumentType(DocumentType),
    MinReliability(InvariantValue),
    InCoordinates(f64, f64, f64, f64), // x1, y1, x2, y2
}

/// Sort criteria for query results
#[derive(Debug, Clone)]
pub enum SortCriterion {
    ByCIC,
    ByMDI,
    ByAOS,
    ByFCF,
    BySPR,
    ByDistance(f64, f64), // from coordinates
    ByTimelineConsistency,
    ByReliability,
}

/// Query result with full historical context
#[derive(Debug, Clone)]
pub struct HistoryQueryResult {
    pub region_id: RegionId,
    pub record: HistoricalRecord,
    pub invariants: RegionInvariants,
    pub relevance_score: InvariantValue,
    pub matching_filters: Vec<String>,
}

/// ============================================================================
/// DATABASE IMPLEMENTATION
/// ============================================================================

impl HistoryDatabase {
    /// Create new history database with invariant engine integration
    pub fn new(invariant_engine: Arc<RwLock<InvariantEngine>>) -> Self {
        HistoryDatabase {
            records: HashMap::new(),
            invariant_engine,
            query_cache: HashMap::new(),
            index_by_biome: HashMap::new(),
            index_by_catastrophe: HashMap::new(),
            index_by_convergence: HashMap::new(),
        }
    }

    /// Register a historical record with automatic indexing
    pub fn register_record(&mut self, record: HistoricalRecord) -> Result<(), String> {
        let region_id = record.region_id.clone();
        
        // Build indices
        self.index_by_biome
            .entry(record.coordinates.biome_type.clone())
            .or_insert_with(HashSet::new)
            .insert(region_id.clone());
        
        for event in &record.catastrophe_events {
            self.index_by_catastrophe
                .entry(event.event_type.clone())
                .or_insert_with(HashSet::new)
                .insert(region_id.clone());
        }
        
        for convergence in &record.folkloric_convergences {
            for motif in &convergence.common_motifs {
                self.index_by_convergence
                    .entry(motif.clone())
                    .or_insert_with(HashSet::new)
                    .insert(region_id.clone());
            }
        }
        
        // Sync with invariant engine
        self.sync_with_invariant_engine(&record)?;
        
        self.records.insert(region_id, record);
        Ok(())
    }

    /// Sync historical record with invariant engine calculations
    fn sync_with_invariant_engine(&self, record: &HistoricalRecord) -> Result<(), String> {
        // Calculate CIC from catastrophe events
        let cic = self.calculate_cic_from_events(&record.catastrophe_events);
        
        // Calculate MDI from mythic entries
        let mdi = self.calculate_mdi_from_myths(&record.mythic_entries);
        
        // Calculate AOS from archival documents
        let aos = self.calculate_aos_from_documents(&record.archival_documents);
        
        // Calculate RRM from ritual activities
        let rrm = self.calculate_rrm_from_rituals(&record.ritual_activities);
        
        // Calculate FCF from folkloric convergences
        let fcf = self.calculate_fcf_from_convergences(&record.folkloric_convergences);
        
        // Calculate SPR from CIC, MDI, AOS
        let spr = InvariantEngine::calculate_spr(cic, mdi, aos);
        
        // Calculate RWF from source reliability
        let rwf = record.source_reliability.aggregated_credibility;
        
        // Calculate DET based on CIC and catastrophe severity
        let det = self.calculate_det(cic, &record.catastrophe_events);
        
        // Calculate LSG from biome transitions
        let lsg = self.calculate_lsg(&record.coordinates);
        
        // Create or update region invariants
        let mut engine = self.invariant_engine
            .write()
            .map_err(|e| format!("Lock error: {}", e))?;
        
        // Note: In full implementation, this would update existing region
        // For now, we calculate and log the values
        log::info!(
            "Synced invariants for {}: CIC={:.2}, MDI={:.2}, AOS={:.2}, RRM={:.2}, FCF={:.2}, SPR={:.2}",
            record.region_id, cic, mdi, aos, rrm, fcf, spr
        );
        
        Ok(())
    }

    /// Calculate CIC from catastrophe events
    fn calculate_cic_from_events(&self, events: &[CatastropheEvent]) -> InvariantValue {
        if events.is_empty() {
            return 0.0;
        }
        
        let total_severity: InvariantValue = events.iter()
            .map(|e| e.severity_rating)
            .sum();
        
        let documented_bonus = events.iter()
            .filter(|e| e.documented)
            .count() as InvariantValue * 0.1;
        
        ((total_severity / events.len() as InvariantValue) + documented_bonus).min(1.0)
    }

    /// Calculate MDI from mythic entries
    fn calculate_mdi_from_myths(&self, myths: &[MythicEntry]) -> InvariantValue {
        if myths.is_empty() {
            return 0.0;
        }
        
        let consistency_avg: InvariantValue = myths.iter()
            .map(|m| m.consistency_score)
            .sum::<InvariantValue>() / myths.len() as InvariantValue;
        
        let propagation_factor = (myths.iter()
            .map(|m| m.propagation_count)
            .sum::<u32>() as InvariantValue / 100.0).min(1.0);
        
        (consistency_avg * 0.6 + propagation_factor * 0.4).min(1.0)
    }

    /// Calculate AOS from archival documents
    fn calculate_aos_from_documents(&self, documents: &[ArchivalDocument]) -> InvariantValue {
        if documents.is_empty() {
            return 0.5; // Default opacity when no records exist
        }
        
        let completeness_avg: InvariantValue = documents.iter()
            .map(|d| d.completeness_score)
            .sum::<InvariantValue>() / documents.len() as InvariantValue;
        
        let redaction_avg: InvariantValue = documents.iter()
            .map(|d| d.redaction_level)
            .sum::<InvariantValue>() / documents.len() as InvariantValue;
        
        let contradiction_penalty = (documents.iter()
            .map(|d| d.contradiction_flags.len())
            .sum::<usize>() as InvariantValue * 0.05).min(0.3);
        
        // High opacity = low completeness + high redaction + contradictions
        ((1.0 - completeness_avg) * 0.4 + redaction_avg * 0.4 + contradiction_penalty).min(1.0)
    }

    /// Calculate RRM from ritual activities
    fn calculate_rrm_from_rituals(&self, rituals: &[RitualActivity]) -> InvariantValue {
        if rituals.is_empty() {
            return 0.0;
        }
        
        let frequency_score: InvariantValue = rituals.iter()
            .map(|r| match r.frequency {
                RitualFrequency::OneTime => 0.2,
                RitualFrequency::Rare => 0.4,
                RitualFrequency::Periodic => 0.6,
                RitualFrequency::Frequent => 0.8,
                RitualFrequency::Continuous => 1.0,
            })
            .sum::<InvariantValue>() / rituals.len() as InvariantValue;
        
        let location_precision_avg: InvariantValue = rituals.iter()
            .map(|r| r.location_precision)
            .sum::<InvariantValue>() / rituals.len() as InvariantValue;
        
        (frequency_score * 0.6 + location_precision_avg * 0.4).min(1.0)
    }

    /// Calculate FCF from folkloric convergences
    fn calculate_fcf_from_convergences(&self, convergences: &[FolkloricConvergence]) -> InvariantValue {
        if convergences.is_empty() {
            return 0.0;
        }
        
        let convergence_strength_avg: InvariantValue = convergences.iter()
            .map(|c| c.convergence_strength)
            .sum::<InvariantValue>() / convergences.len() as InvariantValue;
        
        let culture_count_factor = (convergences.iter()
            .map(|c| c.contributing_cultures.len())
            .max()
            .unwrap_or(0) as InvariantValue / 5.0).min(1.0);
        
        let time_period_factor = (convergences.iter()
            .map(|c| c.time_periods.len())
            .max()
            .unwrap_or(0) as InvariantValue / 4.0).min(1.0);
        
        (convergence_strength_avg * 0.5 + culture_count_factor * 0.25 + time_period_factor * 0.25).min(1.0)
    }

    /// Calculate DET based on CIC and catastrophe severity
    fn calculate_det(&self, cic: InvariantValue, events: &[CatastropheEvent]) -> InvariantValue {
        // Higher CIC = lower DET (more dangerous, less exposure time)
        let base_det = 1.0 - (cic * 0.7);
        
        // Adjust for specific event types
        let severity_adjustment = events.iter()
            .filter(|e| matches!(e.event_type, CatastropheType::BiologicalExperiment | CatastropheType::RadiationIncident))
            .map(|e| e.severity_rating * 0.1)
            .sum::<InvariantValue>();
        
        (base_det - severity_adjustment).max(0.2).min(0.9)
    }

    /// Calculate LSG from biome characteristics
    fn calculate_lsg(&self, coords: &GeoCoordinates) -> InvariantValue {
        // Liminal zones and transition biomes have higher LSG
        match coords.biome_type {
            BiomeType::LiminalZone => 0.95,
            BiomeType::WaterBody | BiomeType::Marshland => 0.75,
            BiomeType::AbandonedSettlement | BiomeType::IndustrialWasteland => 0.70,
            BiomeType::Underground => 0.65,
            _ => 0.40,
        }
    }

    /// Query records by filter criteria
    pub fn query(&self, filters: Vec<QueryFilter>) -> Vec<HistoryQueryResult> {
        let mut results = Vec::new();
        
        for (region_id, record) in &self.records {
            let mut match_score = 0.0;
            let mut matching_filters = Vec::new();
            
            for filter in &filters {
                if self.matches_filter(record, filter) {
                    match_score += 1.0;
                    matching_filters.push(format!("{:?}", filter));
                }
            }
            
            if match_score > 0.0 {
                // Get invariants from engine
                let invariants = self.get_region_invariants(region_id);
                
                results.push(HistoryQueryResult {
                    region_id: region_id.clone(),
                    record: record.clone(),
                    invariants,
                    relevance_score: match_score / filters.len() as InvariantValue,
                    matching_filters,
                });
            }
        }
        
        results.sort_by(|a, b| b.relevance_score.partial_cmp(&a.relevance_score).unwrap());
        results
    }

    /// Check if a record matches a specific filter
    fn matches_filter(&self, record: &HistoricalRecord, filter: &QueryFilter) -> bool {
        match filter {
            QueryFilter::BiomeType(bt) => record.coordinates.biome_type == *bt,
            QueryFilter::MinCIC(min) => {
                let cic = self.calculate_cic_from_events(&record.catastrophe_events);
                cic >= *min
            }
            QueryFilter::MinMDI(min) => {
                let mdi = self.calculate_mdi_from_myths(&record.mythic_entries);
                mdi >= *min
            }
            QueryFilter::MinAOS(min) => {
                let aos = self.calculate_aos_from_documents(&record.archival_documents);
                aos >= *min
            }
            QueryFilter::MinFCF(min) => {
                let fcf = self.calculate_fcf_from_convergences(&record.folkloric_convergences);
                fcf >= *min
            }
            QueryFilter::CatastropheType(ct) => record.catastrophe_events.iter()
                .any(|e| e.event_type == *ct),
            QueryFilter::MythType(mt) => record.mythic_entries.iter()
                .any(|m| m.myth_type == *mt),
            QueryFilter::VerificationStatus(vs) => record.catastrophe_events.iter()
                .any(|e| e.verification_status == *vs),
            QueryFilter::HasDocumentType(dt) => record.archival_documents.iter()
                .any(|d| d.document_type == *dt),
            QueryFilter::MinReliability(min) => record.source_reliability.aggregated_credibility >= *min,
            _ => true, // Simplified for this implementation
        }
    }

    /// Get region invariants from engine
    fn get_region_invariants(&self, region_id: &str) -> RegionInvariants {
        // In full implementation, this would fetch from invariant engine
        // For now, return a placeholder
        self.create_placeholder_invariants(region_id)
    }

    /// Create placeholder invariants (full implementation would fetch from engine)
    fn create_placeholder_invariants(&self, region_id: &str) -> RegionInvariants {
        use crate::invariant_engine::{SpectralLayer, EntertainmentLayer, RegionMetadata, HauntVector, ManifestationType};
        
        RegionInvariants {
            region_id: region_id.to_string(),
            history_layer: HistoryLayer {
                cic: 0.5,
                mdi: 0.5,
                aos: 0.5,
                rrm: 0.5,
                fcf: 0.5,
                spr: 0.5,
                rwf: 0.5,
                det: 0.5,
                hvf: HauntVector {
                    magnitude: 0.5,
                    direction_x: 0.0,
                    direction_y: 0.0,
                    pressure_gradient: 0.5,
                },
                lsg: 0.5,
            },
            spectral_layer: SpectralLayer {
                shci: 0.5,
                manifestation_type: ManifestationType::Environmental,
                activation_threshold: 0.5,
            },
            entertainment_layer: EntertainmentLayer {
                uec: 0.5,
                emd: 0.5,
                stci: 0.5,
                cdl: 0.5,
                arr: 0.5,
            },
            metadata: RegionMetadata {
                last_updated: 0,
                validation_status: ValidationStatus::Valid,
                rivers_of_blood_compliant: false,
                doctrine_version: "3.11A".to_string(),
            },
        }
    }

    /// Get record by region ID
    pub fn get_record(&self, region_id: &str) -> Option<&HistoricalRecord> {
        self.records.get(region_id)
    }

    /// Get all records in a biome
    pub fn get_by_biome(&self, biome: &BiomeType) -> Vec<&HistoricalRecord> {
        self.index_by_biome.get(biome)
            .map(|ids| ids.iter().filter_map(|id| self.records.get(id)).collect())
            .unwrap_or_default()
    }

    /// Get all records with a catastrophe type
    pub fn get_by_catastrophe(&self, catastrophe: &CatastropheType) -> Vec<&HistoricalRecord> {
        self.index_by_catastrophe.get(catastrophe)
            .map(|ids| ids.iter().filter_map(|id| self.records.get(id)).collect())
            .unwrap_or_default()
    }

    /// Find regions by motif convergence
    pub fn get_by_motif(&self, motif: &str) -> Vec<&HistoricalRecord> {
        self.index_by_convergence.get(motif)
            .map(|ids| ids.iter().filter_map(|id| self.records.get(id)).collect())
            .unwrap_or_default()
    }

    /// Export record to Lua table format for engine integration
    pub fn export_to_lua(&self, region_id: &str) -> Option<String> {
        let record = self.records.get(region_id)?;
        
        let cic = self.calculate_cic_from_events(&record.catastrophe_events);
        let mdi = self.calculate_mdi_from_myths(&record.mythic_entries);
        let aos = self.calculate_aos_from_documents(&record.archival_documents);
        
        Some(format!(
            r#"{{
    region_id = "{region_id}",
    biome = "{biome}",
    coordinates = {{ x = {x}, y = {y} }},
    history = {{
        CIC = {cic},
        MDI = {mdi},
        AOS = {aos},
        catastrophe_count = {catastrophe_count},
        myth_count = {myth_count},
        document_count = {document_count}
    }}
}}"#,
            region_id = record.region_id,
            biome = format!("{:?}", record.coordinates.biome_type),
            x = record.coordinates.x,
            y = record.coordinates.y,
            cic = cic,
            mdi = mdi,
            aos = aos,
            catastrophe_count = record.catastrophe_events.len(),
            myth_count = record.mythic_entries.len(),
            document_count = record.archival_documents.len(),
        ))
    }

    /// Get database statistics
    pub fn get_statistics(&self) -> DatabaseStatistics {
        DatabaseStatistics {
            total_records: self.records.len(),
            biome_distribution: self.index_by_biome.iter()
                .map(|(k, v)| (format!("{:?}", k), v.len()))
                .collect(),
            catastrophe_distribution: self.index_by_catastrophe.iter()
                .map(|(k, v)| (format!("{:?}", k), v.len()))
                .collect(),
            total_myths: self.records.values()
                .map(|r| r.mythic_entries.len())
                .sum(),
            total_documents: self.records.values()
                .map(|r| r.archival_documents.len())
                .sum(),
        }
    }
}

/// Database statistics for monitoring and debugging
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DatabaseStatistics {
    pub total_records: usize,
    pub biome_distribution: HashMap<String, usize>,
    pub catastrophe_distribution: HashMap<String, usize>,
    pub total_myths: usize,
    pub total_documents: usize,
}

impl fmt::Display for HistoryDatabase {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let stats = self.get_statistics();
        writeln!(f, "Horror$Place History Database")?;
        writeln!(f, "Total Records: {}", stats.total_records)?;
        writeln!(f, "Total Myths: {}", stats.total_myths)?;
        writeln!(f, "Total Documents: {}", stats.total_documents)?;
        Ok(())
    }
}

/// ============================================================================
/// RIVERS OF BLOOD CHARTER SPECIFIC RECORDS
/// ============================================================================

/// Create Eidoville Valley record (Rivers of Blood template)
pub fn create_eidoville_valley_record() -> HistoricalRecord {
    HistoricalRecord {
        region_id: "eidoville_valley".to_string(),
        coordinates: GeoCoordinates {
            x: 1245.0,
            y: 3890.0,
            elevation: 120.0,
            biome_type: BiomeType::Marshland,
            sub_region: "Valley of Eidoville".to_string(),
        },
        catastrophe_events: vec![
            CatastropheEvent {
                event_id: "V-042".to_string(),
                event_type: CatastropheType::Massacre,
                date_recorded: Some("1724-06-15".to_string()),
                casualty_estimate: Some(340),
                severity_rating: 0.95,
                documented: true,
                verification_status: VerificationStatus::Confirmed,
                affected_radius_km: 5.0,
                long_term_effects: vec![
                    "Blood rivers in irrigation systems".to_string(),
                    "Recurring screams in pipes".to_string(),
                    "Tool corrosion on contact".to_string(),
                ],
            },
        ],
        mythic_entries: vec![
            MythicEntry {
                myth_id: "eidoville_blood_river".to_string(),
                myth_type: MythType::EnvironmentalHaunting,
                narrative_text: "The water clots and the ground remembers pain".to_string(),
                origin_source: "Local oral tradition".to_string(),
                propagation_count: 87,
                consistency_score: 0.82,
                first_recorded: Some("1725-01-01".to_string()),
                related_entities: vec!["Hemophage".to_string()],
            },
        ],
        archival_documents: vec![
            ArchivalDocument {
                document_id: "EID-1724-001".to_string(),
                document_type: DocumentType::OfficialReport,
                title: "Valley Irrigation Project - Final Report".to_string(),
                author: Some("Colonial Engineering Corps".to_string()),
                date_created: Some("1724-07-01".to_string()),
                completeness_score: 0.45,
                contradiction_flags: vec![
                    "Casualty numbers disputed".to_string(),
                    "Cause of water contamination redacted".to_string(),
                ],
                redaction_level: 0.78,
                access_classification: AccessLevel::Restricted,
                content_hash: "sha256:eidoville_1724_redacted".to_string(),
            },
        ],
        ritual_activities: vec![
            RitualActivity {
                ritual_id: "eidoville_irrigation_rite".to_string(),
                ritual_type: RitualType::TestingProtocol,
                frequency: RitualFrequency::Periodic,
                participant_estimate: Some(50),
                location_precision: 0.88,
                success_documented: false,
                residual_effects: vec![
                    "Subsurface pressure increases on anniversary".to_string(),
                    "Spontaneous liquid emergence".to_string(),
                ],
                last_known_occurrence: Some("1724-06-15".to_string()),
            },
        ],
        folkloric_convergences: vec![
            FolkloricConvergence {
                convergence_id: "eidoville_convergence_01".to_string(),
                contributing_cultures: vec![
                    "Colonial Settlers".to_string(),
                    "Indigenous Population".to_string(),
                    "Engineering Corps".to_string(),
                ],
                time_periods: vec![
                    "1720s".to_string(),
                    "1890s".to_string(),
                    "1990s".to_string(),
                ],
                common_motifs: vec![
                    "Bleeding earth".to_string(),
                    "Water that remembers".to_string(),
                    "Unjust death circulates".to_string(),
                ],
                convergence_strength: 0.81,
                narrative_pressure: 0.88,
            },
        ],
        source_reliability: SourceReliabilityMap {
            sources: HashMap::new(),
            aggregated_credibility: 0.68,
            contradiction_count: 3,
        },
        temporal_metadata: TemporalMetadata {
            earliest_event: Some("1724-06-15".to_string()),
            latest_event: Some("1994-06-15".to_string()),
            gap_periods: vec![
                TimeGap {
                    start_date: "1725-01-01".to_string(),
                    end_date: "1890-01-01".to_string(),
                    gap_reason: Some("Records lost in fire".to_string()),
                    suspicion_level: 0.65,
                },
            ],
            timeline_consistency: 0.52,
            last_updated: Utc::now(),
        },
    }
}

/// ============================================================================
/// UNIT TESTS
/// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::{Arc, RwLock};
    use crate::invariant_engine::InvariantEngine;

    #[test]
    fn test_database_creation() {
        let engine = Arc::new(RwLock::new(InvariantEngine::new()));
        let db = HistoryDatabase::new(engine);
        assert_eq!(db.get_statistics().total_records, 0);
    }

    #[test]
    fn test_eidoville_record_creation() {
        let record = create_eidoville_valley_record();
        assert_eq!(record.region_id, "eidoville_valley");
        assert!(!record.catastrophe_events.is_empty());
        assert!(record.catastrophe_events[0].severity_rating >= 0.9);
    }

    #[test]
    fn test_cic_calculation() {
        let engine = Arc::new(RwLock::new(InvariantEngine::new()));
        let db = HistoryDatabase::new(engine);
        let record = create_eidoville_valley_record();
        let cic = db.calculate_cic_from_events(&record.catastrophe_events);
        assert!(cic >= 0.8); // High CIC for Rivers of Blood region
    }

    #[test]
    fn test_aos_calculation() {
        let engine = Arc::new(RwLock::new(InvariantEngine::new()));
        let db = HistoryDatabase::new(engine);
        let record = create_eidoville_valley_record();
        let aos = db.calculate_aos_from_documents(&record.archival_documents);
        assert!(aos >= 0.7); // High AOS due to redactions and contradictions
    }

    #[test]
    fn test_biome_indexing() {
        let engine = Arc::new(RwLock::new(InvariantEngine::new()));
        let mut db = HistoryDatabase::new(engine);
        let record = create_eidoville_valley_record();
        let biome = record.coordinates.biome_type.clone();
        db.register_record(record).unwrap();
        
        let by_biome = db.get_by_biome(&biome);
        assert_eq!(by_biome.len(), 1);
    }
}
