#!/bin/bash
set -e

PROJECT_DIR="$(pwd)"

echo "🚀 Kickoff: Setting up agentic project..."

# Create .claude directory for configuration
mkdir -p .claude

# 1. Create claude.config.json with RAG tool
echo "📝 Creating claude.config.json..."
cat > claude.config.json << 'EOF'
{
  "version": "1.0",
  "tools": [
    {
      "name": "rag.search",
      "description": "Search through project documentation and codebase using RAG index",
      "type": "command",
      "command": "./rag/search.sh",
      "schema": {
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "The search query"
          },
          "max_results": {
            "type": "number",
            "description": "Maximum number of results to return",
            "default": 5
          }
        },
        "required": ["query"]
      }
    }
  ]
}
EOF

# 2. Create RAG directory and scripts
echo "📂 Setting up RAG scripts..."
mkdir -p rag

# Create search script
cat > rag/search.sh << 'EOF'
#!/bin/bash
# Simple RAG search implementation
# In a real implementation, this would use vector embeddings and semantic search

QUERY="$1"
MAX_RESULTS="${2:-5}"
INDEX_FILE="rag/index.txt"

if [ ! -f "$INDEX_FILE" ]; then
    echo "Error: RAG index not found. Run ./rag/build_index.sh first."
    exit 1
fi

# Simple grep-based search (replace with actual RAG implementation)
echo "Searching for: $QUERY"
echo "---"
grep -i "$QUERY" "$INDEX_FILE" 2>/dev/null | head -n "$MAX_RESULTS" || echo "No results found."
EOF
chmod +x rag/search.sh

# Create index builder
cat > rag/build_index.sh << 'EOF'
#!/bin/bash
# Build RAG index from project files

echo "🔨 Building RAG index..."

INDEX_FILE="rag/index.txt"
rm -f "$INDEX_FILE"

# Index common documentation and code files
find . -type f \( \
    -name "*.md" -o \
    -name "*.txt" -o \
    -name "*.swift" -o \
    -name "*.js" -o \
    -name "*.ts" -o \
    -name "*.py" -o \
    -name "*.go" -o \
    -name "*.rs" \
\) ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/build/*" > "$INDEX_FILE"

# Create content index (simple version - just file paths and first lines)
echo "" >> "$INDEX_FILE"
echo "=== Content Preview ===" >> "$INDEX_FILE"
while IFS= read -r file; do
    if [ -f "$file" ]; then
        echo "File: $file" >> "$INDEX_FILE"
        head -n 5 "$file" >> "$INDEX_FILE" 2>/dev/null || true
        echo "---" >> "$INDEX_FILE"
    fi
done < <(find . -type f \( -name "*.md" -o -name "*.txt" \) ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/rag/*")

echo "✅ Index built: $INDEX_FILE"
echo "   Indexed $(wc -l < "$INDEX_FILE") lines"
EOF
chmod +x rag/build_index.sh

# 3. Build initial RAG index
echo "🔍 Building initial RAG index..."
./rag/build_index.sh

# 4. Create README.md
if [ ! -f "README.md" ]; then
    echo "📖 Creating README.md..."
    cat > README.md << 'EOF'
# Agentic Project

This project was created with the Agentic Kickoff tool.

## Quick Start

1. Review `SPEC.md` for the project specification
2. Use Claude Code with the built-in RAG search tool
3. Run `./rag/search.sh "query"` to search documentation

## Claude Code Integration

This project is pre-configured with:
- `claude.config.json` - Custom RAG search tool
- `rag/` directory - RAG scripts and index
- Pre-built search index for quick queries

## RAG Commands

- `./rag/search.sh "query"` - Search the project
- `./rag/build_index.sh` - Rebuild the search index

## Next Steps

Start building! Claude Code is ready to help with the RAG search tool.
EOF
fi

# 5. Create optional package.json for Node projects
if grep -qi "node\|npm\|javascript\|typescript" SPEC.md 2>/dev/null; then
    if [ ! -f "package.json" ]; then
        echo "📦 Creating package.json..."
        cat > package.json << 'EOF'
{
  "name": "agentic-project",
  "version": "1.0.0",
  "description": "Agentic project created with Kickoff tool",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "MIT"
}
EOF
    fi
fi

# 6. Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "🙈 Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Build outputs
build/
dist/
*.log

# Environment
.env
.env.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF
fi

echo ""
echo "✅ Kickoff complete!"
echo ""
echo "📁 Project structure:"
echo "   - SPEC.md           : Project specification"
echo "   - claude.config.json: Claude Code configuration"
echo "   - rag/              : RAG search scripts and index"
echo "   - README.md         : Project documentation"
echo ""
echo "🎯 Next: Open this folder in Claude Code and start building!"
