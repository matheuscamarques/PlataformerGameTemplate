#pragma once
// Enum central de partes do corpo
namespace core {
enum class BodyPartId : uint8_t {
    None = 0,
    Head,
    Torso,
    ArmL,
    ArmR,
    LegL,
    LegR,
    Weapon,
    COUNT
};
}
