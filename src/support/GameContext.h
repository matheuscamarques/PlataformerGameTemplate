#pragma once
namespace support {
struct GameContext {
    void* world = nullptr;
    void* player = nullptr;
    void* input = nullptr;
    void* enemies = nullptr;
    void* throws = nullptr;
};
}

