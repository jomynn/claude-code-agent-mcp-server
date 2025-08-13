#!/bin/bash

PROJECT_DIR="$(pwd)"
echo "=== Project Status ==="
echo "Directory: $PROJECT_DIR"
echo "Memory file: $([ -f project-memory.json ] && echo "✅ Exists" || echo "❌ Missing")"
echo "Dumps: $(ls memory-dumps/ 2>/dev/null | wc -l) files"
echo "Backups: $(ls backups/ 2>/dev/null | wc -l) files"
echo "n8n status: $(curl -s http://localhost:5678/rest/health 2>/dev/null && echo "✅ Running" || echo "❌ Not running")"
