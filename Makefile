CXX ?= g++
CXXFLAGS := -std=c++17 -Wall -Wextra -Isrc -MMD -MP -O2 -g -ffp-contract=off -fno-fast-math
LDFLAGS := -Wl,-rpath-link,/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu
LDLIBS := -lsfml-graphics -lsfml-window -lsfml-system

SRC_DIR := src
OBJ_DIR := compiled
BIN_DIR := build

SRCS := $(shell find $(SRC_DIR) -name '*.cpp')
OBJS := $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))
TARGET := $(BIN_DIR)/plataformer

all: $(TARGET)

$(TARGET): $(OBJS)
	@mkdir -p $(dir $@)
	$(CXX) $(LDFLAGS) $(OBJS) -o $@ $(LDLIBS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)

run: all
	./$(TARGET)

test:
	@echo "No tests yet"

.PHONY: all clean run test
