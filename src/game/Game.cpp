#include "game/Game.h"
#include "core/System.h"
#include "support/GameContext.h"

Game::Game() {}
void Game::start() {}
void Game::run() {
    support::GameContext ctx;
    scheduler_.tick(1.0f/60.0f, ctx);
}
