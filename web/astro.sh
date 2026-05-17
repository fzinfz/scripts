#!/bin/bash
set -e

# Usage: ./astro.sh <site-name> [target-dir]
# Creates an Astro 6 docs-only site (no blog)

SITE_NAME="${1:-my-docs}"
TARGET_DIR="${2:-.}"
DEST_DIR="$TARGET_DIR/$SITE_NAME"

echo "==> Creating Astro 6 site: $SITE_NAME"
echo "==> Destination: $DEST_DIR"

# Check Node.js version
if ! command -v node &>/dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js >= 18."
    exit 1
fi

NODE_MAJOR=$(node -v | sed 's/v//g' | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 18 ]; then
    echo "Error: Node.js >= 18 is required. Found: $(node -v)"
    exit 1
fi

# Check npm/npx
if ! command -v npx &>/dev/null; then
    echo "Error: npx is not available. Please install npm."
    exit 1
fi

# Remove existing directory if it exists
if [ -d "$DEST_DIR" ]; then
    echo "==> Removing existing directory: $DEST_DIR"
    rm -rf "$DEST_DIR"
fi

# Create Astro minimal site
echo "==> Running create-astro..."
echo "$DEST_DIR" | npx create-astro@latest "$DEST_DIR" --template minimal --no-git --no-install

cd "$DEST_DIR"

# Install dependencies
echo "==> Installing dependencies..."
npm install

# Remove default index.astro content page, keep layout structure
cat > src/pages/index.astro << 'EOF'
---
import Layout from '../layouts/Layout.astro';
---

<Layout title="Documentation">
  <main>
    <h1>Documentation</h1>
    <p>Welcome to the docs site. Browse the topics below:</p>
    <ul>
      <li><a href="/intro">Introduction</a></li>
      <li><a href="/guide/getting-started">Getting Started</a></li>
    </ul>
  </main>
</Layout>

<style>
  main {
    margin: auto;
    padding: 1rem;
    width: 800px;
    max-width: calc(100% - 2rem);
    color: #111;
    font-size: 16px;
    line-height: 1.6;
  }
  h1 {
    font-size: 2rem;
    font-weight: 700;
    margin-bottom: 0.5em;
  }
  ul {
    margin-top: 1rem;
    padding-left: 1.25rem;
  }
  a {
    color: #2563eb;
    text-decoration: none;
  }
  a:hover {
    text-decoration: underline;
  }
</style>
EOF

# Create a sample Markdown docs page
mkdir -p src/pages/guide
cat > src/pages/guide/getting-started.md << 'EOF'
---
layout: ../../layouts/Layout.astro
title: Getting Started
---

# Getting Started

This guide will help you set up the project in minutes.

## Prerequisites

- Node.js 18 or higher
- npm or pnpm

## Installation

Run the following command:

```bash
npm install
```

## Next Steps

- Read the [Introduction](/intro)
- Check the configuration reference
EOF

# Ensure Layout.astro exists
mkdir -p src/layouts
cat > src/layouts/Layout.astro << 'EOF'
---
interface Props {
  title: string;
}

const { title } = Astro.props;
---

<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{title}</title>
  </head>
  <body>
    <slot />
  </body>
</html>

<style is:global>
  body {
    font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    margin: 0;
    padding: 0;
    background: #fff;
    color: #111;
  }
</style>
EOF

# Remove default Astro welcome component if present
rm -f src/components/Card.astro src/components/Welcome.astro

# Build to verify
echo "==> Building site..."
npm run build

echo "==> Done! Astro 6 docs-only site created at: $DEST_DIR"
echo "==> To start development server: cd $DEST_DIR && npm run dev"
