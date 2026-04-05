// cpp/stalker_kinematics.cpp  (header-only, zero-overhead)
struct HauntVector {
    float magnitude;
    Eigen::Vector3f direction;  // ties to HVF
    float shci;                 // coupling enforcement
};

HauntVector compute_stalker_intercept(const PlayerTrajectory& player, const RegionInvariants& inv) {
    // Predict + LSG-amplified intercept
    Eigen::Vector3f predicted = player.position + player.velocity * inv.DET;
    if (inv.LSG > 0.75f) predicted += inv.HVF.direction * inv.HVF.mag * 0.3f;
    // Enforce SHCI: only spawn if history coupling allows
    if (inv.SHCI < 0.6f) return {0.0f, {0,0,0}, 0.0f};
    return {inv.HVF.mag, predicted - player.position, inv.SHCI};
}
