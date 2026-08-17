#!/usr/bin/env bash
# Installs VS Code extensions declaratively.
# Run once after bootstrap, or anytime you add extensions to this list.
set -euo pipefail

EXTENSIONS=(
  # Themes & Icons
  akamud.vscode-theme-onedark
  BeardedBear.beardedtheme
  GitHub.github-vscode-theme
  zhuangtongfa.Material-theme
  PKief.material-icon-theme

  # AI
  anthropic.claude-code

  # Formatters & Linters
  esbenp.prettier-vscode
  dbaeumer.vscode-eslint
  streetsidesoftware.code-spell-checker

  # JS/TS/React
  dsznajder.es7-react-js-snippets
  bradlc.vscode-tailwindcss
  vitest.explorer

  # Python
  ms-python.python
  ms-python.vscode-pylance
  ms-python.debugpy

  # Java/Kotlin (install when needed)
  # redhat.java
  # vscjava.vscode-java-pack
  # fwcd.kotlin

  # Go (install when needed)
  # golang.Go

  # Git
  eamodio.gitlens
  donjayamanne.githistory

  # Other
  GraphQL.vscode-graphql-syntax
)

echo "Installing ${#EXTENSIONS[@]} VS Code extensions..."
for ext in "${EXTENSIONS[@]}"; do
  code --install-extension "$ext" --force 2>/dev/null || echo "  ⚠ Failed: $ext"
done
echo "Done!"
