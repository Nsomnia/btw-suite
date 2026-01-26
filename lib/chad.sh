#!/usr/bin/env bash

# --- CHAD LIBRARY FOR BTW-SUITE ---
# "I use Arch, btw." - Every Chad ever.
# This library provides colors, humor, and aesthetic dominance.

# Colors (ANSI)
export BOLD='\033[1m'
export ITALIC='\033[3m'
export UNDERLINE='\033[4m'
export RESET='\033[0m'

# Chad Palette
export CHAD_BLUE='\033[38;5;33m'
export CHAD_PURPLE='\033[38;5;135m'
export CHAD_CYAN='\033[38;5;51m'
export CHAD_GREEN='\033[38;5;82m'
export CHAD_RED='\033[38;5;196m'
export CHAD_GOLD='\033[38;5;220m'

# Humor Strings
export BTW_MSG="I use Arch, btw."
export OVER_9000="ITS OVER 9000!!!"
export STALLMAN_INTERJECTION="I'd like to interject for a moment. What you're referring to as Linux, is in fact, GNU/Linux, or as I've recently taken to calling it, GNU plus Linux."
export TORVALDS_CODE="Talk is cheap. Show me the code."
export TORVALDS_PERF="Regression testing? What's that? If it compiles, it's good; if it boots up, it's perfect."

# Helper Functions
stallman_interject() {
    echo -e "${CHAD_GOLD}${ITALIC}${STALLMAN_INTERJECTION}${RESET}"
}

torvalds_rant() {
    echo -e "${CHAD_RED}${BOLD}${TORVALDS_CODE}${RESET}"
}
chad_print() {
    echo -e "${CHAD_CYAN}${BOLD}[CHAD]${RESET} ${1}"
}

btw_print() {
    echo -e "${CHAD_PURPLE}${BOLD}[BTW]${RESET} ${1}"
}

power_level_check() {
    echo -e "${CHAD_GOLD}${BOLD}${OVER_9000}${RESET}"
}

error_print() {
    echo -e "${CHAD_RED}${BOLD}[ERROR]${RESET} ${1}"
}

success_print() {
    echo -e "${CHAD_GREEN}${BOLD}[SUCCESS]${RESET} ${1}"
}

# Visual Separator
chad_separator() {
    echo -e "${CHAD_BLUE}================================================================================${RESET}"
}

# Chad Header
chad_header() {
    chad_separator
    echo -e "  ${CHAD_GOLD}${BOLD}BTW-SUITE: THE ULTIMATE ARCH ASCENSION${RESET}"
    echo -e "  ${ITALIC}${BTW_MSG}${RESET}"
    chad_separator
}
