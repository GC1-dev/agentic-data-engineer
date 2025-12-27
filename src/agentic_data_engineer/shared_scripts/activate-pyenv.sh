#!/bin/bash
# Source this script to activate pyenv in your current shell
# Usage: source activate-pyenv.sh

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

PYTHON_VERSION=$(cat .python-version 2>/dev/null || echo "3.12")
pyenv local "$PYTHON_VERSION"
pyenv shell "$PYTHON_VERSION"

echo "✓ Python $PYTHON_VERSION activated"
echo "Current Python version: $(python --version)"
echo "Python path: $(which python)"

source ~/.zshrc
