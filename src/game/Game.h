#pragma once
#include "core/System.h"

class Game {
public:
    Game();
    void start();
    void run();
private:
    core::SystemScheduler scheduler_;
};
