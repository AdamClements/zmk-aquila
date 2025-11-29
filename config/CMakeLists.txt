# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(zmk-config)

# Ensure the configuration directory itself is available for includes.
zephyr_include_directories(${CMAKE_CURRENT_SOURCE_DIR})
