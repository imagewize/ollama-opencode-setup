# Batch Processing Example Workflows

Scripts and workflows for processing multiple files or tasks in batch mode with local models.

## Why Batch Processing with Local Models?

**Advantages:**
- No API rate limits
- No per-token costs
- Can run overnight
- Good for repetitive tasks
- Privacy for sensitive code

**Best for:**
- Code generation from templates
- Bulk file updates
- Documentation generation
- Consistent refactoring across many files

## Simple Batch Script

### Basic Template

```bash
#!/bin/bash
# batch-process.sh

MODEL="ollama/qwen3:8b"
FILES=(
  "src/file1.ts"
  "src/file2.ts"
  "src/file3.ts"
)

for file in "${FILES[@]}"; do
  echo "Processing $file..."
  opencode run "Add TypeScript strict mode types to $file" --model "$MODEL"
  echo "---"
done
```

Make it executable:
```bash
chmod +x batch-process.sh
./batch-process.sh
```

## Documentation Generation

### Generate README for Each Directory

```bash
#!/bin/bash
# generate-readmes.sh

MODEL="ollama/qwen3:8b"
DIRS=(
  "src/components"
  "src/hooks"
  "src/utils"
  "src/services"
)

for dir in "${DIRS[@]}"; do
  echo "Generating README for $dir..."
  opencode run "Analyze all files in $dir and create a README.md that documents:
  - Purpose of this directory
  - List of files with descriptions
  - Usage examples
  - Dependencies" --model "$MODEL"
  echo "---"
  sleep 2  # Rate limiting (optional for local)
done
```

### Generate JSDoc Comments

```bash
#!/bin/bash
# add-jsdoc.sh

MODEL="ollama/mistral-nemo:12b-instruct-2407-q4_K_M"

find src/utils -name "*.ts" -type f | while read -r file; do
  echo "Adding JSDoc to $file..."
  opencode run "Add comprehensive JSDoc comments to all functions in $file. Include:
  - Function description
  - @param for each parameter with type
  - @returns with return type
  - @example with usage example" --model "$MODEL"
done
```

## Test Generation

### Generate Tests for Multiple Files

```bash
#!/bin/bash
# generate-tests.sh

MODEL="ollama/mistral-nemo:12b-instruct-2407-q4_K_M"
SOURCE_FILES=(
  "src/utils/validation.ts"
  "src/utils/formatting.ts"
  "src/utils/conversion.ts"
)

for file in "${SOURCE_FILES[@]}"; do
  test_file="${file%.ts}.test.ts"
  echo "Generating tests for $file..."

  opencode run "Generate comprehensive unit tests for $file using Jest:
  - Test all exported functions
  - Include edge cases
  - Test error handling
  - Save to $test_file" --model "$MODEL"

  echo "---"
done
```

## Code Modernization

### Modernize Multiple Files

```bash
#!/bin/bash
# modernize-legacy.sh

MODEL="ollama/qwen3:8b"

find src/legacy -name "*.js" -type f | while read -r file; do
  echo "Modernizing $file..."

  opencode run "Modernize $file:
  - Convert to TypeScript (.ts extension)
  - Use ES6+ features (const/let, arrow functions, async/await)
  - Add type definitions
  - Use modern best practices" --model "$MODEL"

  # Rename .js to .ts after conversion
  # mv "$file" "${file%.js}.ts"

  echo "---"
done
```

## Consistency Enforcement

### Enforce Coding Standards

```bash
#!/bin/bash
# enforce-standards.sh

MODEL="ollama/qwen3:8b"
COMPONENTS=($(find src/components -name "*.tsx" -type f))

for component in "${COMPONENTS[@]}"; do
  echo "Enforcing standards on $component..."

  opencode run "Update $component to follow our standards:
  - Use functional components with TypeScript
  - Props interface named {ComponentName}Props
  - Use React.FC type
  - Add prop-types for runtime validation
  - Use consistent export (named export + default)" --model "$MODEL"

  echo "---"
done
```

## Migration Tasks

### Convert Class Components to Functional

```bash
#!/bin/bash
# convert-to-functional.sh

MODEL="ollama/mistral-nemo:12b-instruct-2407-q4_K_M"

# Find all class components
grep -l "class.*extends.*Component" src/components/**/*.tsx | while read -r file; do
  echo "Converting $file to functional component..."

  opencode run "Convert $file from class component to functional component:
  - Use hooks (useState, useEffect, etc.)
  - Maintain same functionality
  - Keep prop types
  - Update tests if present" --model "$MODEL"

  echo "---"
done
```

## Internationalization

### Add i18n to Multiple Files

```bash
#!/bin/bash
# add-i18n.sh

MODEL="ollama/qwen3:8b-16k"
FILES=(
  "src/components/Header.tsx"
  "src/components/Footer.tsx"
  "src/pages/Home.tsx"
  "src/pages/About.tsx"
)

for file in "${FILES[@]}"; do
  echo "Adding i18n to $file..."

  opencode run "Add internationalization to $file:
  - Import useTranslation from react-i18next
  - Replace hardcoded strings with t('key')
  - Create translation key suggestions
  - Maintain component functionality" --model "$MODEL"

  echo "---"
done
```

## Parallel Processing

### Process Multiple Files in Parallel

```bash
#!/bin/bash
# parallel-process.sh

MODEL="ollama/qwen3:4b"  # Use faster model for parallel
MAX_JOBS=3  # Process 3 files at a time

process_file() {
  local file=$1
  echo "Processing $file..."
  opencode run "Add error handling to $file" --model "$MODEL"
  echo "Completed $file"
}

export -f process_file
export MODEL

# Process files in parallel (3 at a time)
find src -name "*.ts" -type f | xargs -P $MAX_JOBS -I {} bash -c 'process_file "$@"' _ {}
```

## Validation and Reporting

### Batch Code Review with Report

```bash
#!/bin/bash
# batch-review.sh

MODEL="ollama/qwen3:8b"
REPORT_FILE="code-review-report.md"

echo "# Code Review Report - $(date)" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

FILES=($(find src/components -name "*.tsx" -type f))

for file in "${FILES[@]}"; do
  echo "Reviewing $file..."
  echo "## $file" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"

  # Run review and append to report
  opencode run "Review $file for:
  - Bugs
  - Performance issues
  - Security vulnerabilities
  - Best practices

  Format output as markdown." --model "$MODEL" >> "$REPORT_FILE"

  echo "" >> "$REPORT_FILE"
  echo "---" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
done

echo "Review complete! Report saved to $REPORT_FILE"
```

## Template-Based Generation

### Generate Components from Template

```bash
#!/bin/bash
# generate-components.sh

MODEL="ollama/qwen3:8b"
COMPONENTS=(
  "UserCard:displays user information"
  "ProductCard:displays product details"
  "ArticleCard:displays article preview"
)

for component_spec in "${COMPONENTS[@]}"; do
  IFS=':' read -r name description <<< "$component_spec"

  echo "Generating $name component..."

  opencode run "Create a new React component:

  Component name: $name
  Description: $description

  Requirements:
  - TypeScript with proper types
  - Functional component
  - Props interface
  - Styled with Tailwind CSS
  - Accessible (ARIA labels)
  - Responsive design

  Save to: src/components/$name.tsx" --model "$MODEL"

  echo "---"
done
```

## WordPress Block Generation

### Create Multiple Blocks from Spec

```bash
#!/bin/bash
# generate-blocks.sh

MODEL="ollama/mistral-nemo:12b-instruct-2407-q4_K_M"
BLOCKS=(
  "testimonial:Display customer testimonials with image and quote"
  "pricing:Pricing table with features and CTA button"
  "team:Team member profile with photo and bio"
  "faq:Frequently asked questions accordion"
)

cd /path/to/sage-theme

for block_spec in "${BLOCKS[@]}"; do
  IFS=':' read -r name description <<< "$block_spec"

  echo "Creating $name block..."

  # Create block using sage-native-block
  wp acorn sage-native-block:create "$name" --template=nynaeve-cta --force

  # Customize the generated block
  opencode run "Customize the $name block in resources/js/blocks/$name/:

  Description: $description

  Requirements:
  - Update block.json with proper title and description
  - Implement edit.tsx with block controls
  - Implement save.tsx with frontend output
  - Use Tailwind CSS for styling
  - Make it responsive" --model "$MODEL"

  echo "---"
done
```

## Progressive Enhancement

### Gradually Improve Multiple Files

```bash
#!/bin/bash
# progressive-enhancement.sh

MODEL="ollama/qwen3:8b"
PHASES=(
  "Add TypeScript types"
  "Add error handling"
  "Add input validation"
  "Add unit tests"
  "Add JSDoc comments"
)

FILES=(
  "src/utils/api.ts"
  "src/utils/storage.ts"
  "src/utils/cache.ts"
)

for phase in "${PHASES[@]}"; do
  echo "=== Phase: $phase ==="

  for file in "${FILES[@]}"; do
    echo "Applying '$phase' to $file..."
    opencode run "$phase to $file" --model "$MODEL"
  done

  echo "Phase complete. Running tests..."
  npm test

  echo "---"
done
```

## Logging and Error Handling

### Batch Script with Logging

```bash
#!/bin/bash
# batch-with-logging.sh

MODEL="ollama/qwen3:8b"
LOG_DIR="batch-logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/batch_$TIMESTAMP.log"

mkdir -p "$LOG_DIR"

log() {
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $1" | tee -a "$LOG_FILE"
}

process_file() {
  local file=$1
  log "Processing: $file"

  if opencode run "Add error handling to $file" --model "$MODEL" 2>> "$LOG_FILE"; then
    log "SUCCESS: $file"
    return 0
  else
    log "ERROR: $file failed"
    return 1
  fi
}

FILES=($(find src -name "*.ts" -type f))
TOTAL=${#FILES[@]}
SUCCESS=0
FAILED=0

log "Starting batch process with $TOTAL files"

for file in "${FILES[@]}"; do
  if process_file "$file"; then
    ((SUCCESS++))
  else
    ((FAILED++))
  fi
done

log "Batch complete: $SUCCESS succeeded, $FAILED failed"
```

## Tips for Effective Batch Processing

1. **Choose the right model:**
   - `qwen3:4b` - Fast, simple tasks (renaming, formatting)
   - `qwen3:8b` - Balanced, most tasks
   - `mistral-nemo:12b-instruct-2407-q4_K_M` - Complex tasks (refactoring, generation)

2. **Add delays for resource management:**
   ```bash
   sleep 2  # Wait 2 seconds between tasks
   ```

3. **Use parallel processing for independent tasks:**
   - Faster completion
   - Use `xargs -P` or GNU `parallel`
   - Limit concurrent jobs based on system resources

4. **Log everything:**
   - Track success/failure
   - Debug issues
   - Monitor progress

5. **Test on small subset first:**
   ```bash
   # Test with first 3 files
   FILES=($(find src -name "*.ts" -type f | head -3))
   ```

6. **Add confirmation prompts for destructive operations:**
   ```bash
   read -p "Process $TOTAL files? (y/n) " -n 1 -r
   echo
   if [[ ! $REPLY =~ ^[Yy]$ ]]; then
     exit 1
   fi
   ```

7. **Use version control:**
   ```bash
   # Commit before batch processing
   git add -A
   git commit -m "Before batch processing"

   # Run batch script
   ./batch-process.sh

   # Review changes
   git diff
   ```

## Performance Expectations

| Task Type | Files | Model | Time per File | Total (10 files) |
|-----------|-------|-------|---------------|------------------|
| Simple formatting | 10 | `qwen3:4b` | 8-12s | 1.5-2 min |
| Type additions | 10 | `qwen3:8b` | 15-20s | 2.5-3.5 min |
| Refactoring | 10 | `mistral-nemo:12b-instruct-2407-q4_K_M` | 30-45s | 5-7.5 min |
| Test generation | 10 | `mistral-nemo:12b-instruct-2407-q4_K_M` | 40-60s | 6.5-10 min |

**Parallel processing (3 jobs):**
- Can reduce total time by ~60-70%
- 10 files in parallel: ~2-3.5 min instead of 6.5-10 min
