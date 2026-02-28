#!/usr/bin/env bash
# =============================================================
#  Meta Quest Knowledge — Setup & Run Script
#  This script walks you through installing dependencies,
#  configuring your environment, and running the application.
# =============================================================

set -e

# ── Colors for output ────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()    { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Step 1: Check Python version ────────────────────────────
echo ""
echo "==========================================="
echo "  Step 1/5 — Checking Python version"
echo "==========================================="

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
    PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

    if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 10 ] && [ "$PYTHON_MINOR" -le 13 ]; then
        info "Python $PYTHON_VERSION detected — OK"
    else
        error "Python $PYTHON_VERSION detected. This project requires Python 3.10 – 3.13."
        exit 1
    fi
else
    error "Python 3 is not installed. Please install Python 3.10 – 3.13 first."
    exit 1
fi

# ── Step 2: Check for uv package manager ────────────────────
echo ""
echo "==========================================="
echo "  Step 2/5 — Checking for uv package manager"
echo "==========================================="

if command -v uv &> /dev/null; then
    info "uv is installed — $(uv --version)"
else
    warn "uv is not installed."
    read -rp "Would you like to install uv now? (y/n): " INSTALL_UV
    if [[ "$INSTALL_UV" =~ ^[Yy]$ ]]; then
        info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Source the updated PATH so uv is available in this session
        export PATH="$HOME/.local/bin:$PATH"
        if command -v uv &> /dev/null; then
            info "uv installed successfully — $(uv --version)"
        else
            error "uv installation failed. Please install it manually: https://docs.astral.sh/uv/getting-started/installation/"
            exit 1
        fi
    else
        error "uv is required to continue. Install it from: https://docs.astral.sh/uv/getting-started/installation/"
        exit 1
    fi
fi

# ── Step 3: Install project dependencies ────────────────────
echo ""
echo "==========================================="
echo "  Step 3/5 — Installing dependencies"
echo "==========================================="

info "Running 'uv sync' to install project dependencies..."
uv sync
info "Dependencies installed successfully."

# ── Step 4: Configure OpenAI API Key ────────────────────────
echo ""
echo "==========================================="
echo "  Step 4/5 — Configuring OpenAI API Key"
echo "==========================================="

if [ -n "$OPENAI_API_KEY" ]; then
    info "OPENAI_API_KEY is already set in your environment."
else
    warn "OPENAI_API_KEY is not set."
    read -rp "Enter your OpenAI API key (or press Enter to skip): " API_KEY
    if [ -n "$API_KEY" ]; then
        export OPENAI_API_KEY="$API_KEY"
        info "OPENAI_API_KEY has been set for this session."
    else
        warn "Skipped. Make sure to set OPENAI_API_KEY before running the crew."
        warn "  export OPENAI_API_KEY=\"your-api-key-here\""
    fi
fi

# ── Step 5: Run the application ─────────────────────────────
echo ""
echo "==========================================="
echo "  Step 5/5 — Running the application"
echo "==========================================="

echo ""
echo "Available commands:"
echo "  1) run_crew   — Ask the DevOps expert a question (interactive)"
echo "  2) train      — Train the crew"
echo "  3) test       — Test the crew"
echo "  4) replay     — Replay a specific task"
echo "  5) exit       — Exit without running"
echo ""

read -rp "Select an option [1-5] (default: 1): " CHOICE
CHOICE=${CHOICE:-1}

case "$CHOICE" in
    1)
        info "Starting interactive Q&A session..."
        echo ""
        uv run run_crew
        ;;
    2)
        read -rp "Number of training iterations (default: 3): " N_ITER
        N_ITER=${N_ITER:-3}
        read -rp "Output filename (default: training_results.json): " FILENAME
        FILENAME=${FILENAME:-training_results.json}
        info "Training the crew for $N_ITER iterations..."
        uv run train "$N_ITER" "$FILENAME"
        ;;
    3)
        read -rp "Number of test iterations (default: 3): " N_ITER
        N_ITER=${N_ITER:-3}
        read -rp "OpenAI model name (default: gpt-4o): " MODEL
        MODEL=${MODEL:-gpt-4o}
        info "Testing the crew for $N_ITER iterations with model '$MODEL'..."
        uv run test "$N_ITER" "$MODEL"
        ;;
    4)
        read -rp "Task ID to replay: " TASK_ID
        if [ -z "$TASK_ID" ]; then
            error "Task ID is required."
            exit 1
        fi
        info "Replaying task $TASK_ID..."
        uv run replay "$TASK_ID"
        ;;
    5)
        info "Exiting. You can run commands manually with: uv run <command>"
        exit 0
        ;;
    *)
        error "Invalid option: $CHOICE"
        exit 1
        ;;
esac
