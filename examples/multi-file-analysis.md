# Multi-File Analysis Example Workflows

Example prompts and workflows for analyzing multiple related files using extended context models.

## Best Model for Multi-File Analysis

**Primary:** `qwen3:8b-16k` (16k context window)
**Alternative:** `mistral-nemo:12b-instruct-2407-q4_K_M` (8k context, use for smaller file sets)

## Understanding Context Limits

| Context Window | Can Analyze |
|----------------|-------------|
| 8k tokens | 1-2 medium files (~500-1000 lines each) |
| 16k tokens | 3-5 medium files |
| 32k tokens | 6-10 medium files |
| 200k tokens | Small-medium entire codebase |

**Note:** "Medium file" = ~500-1000 lines of code (~20-40 KB)

## Feature Analysis

### Analyze Complete Feature

```bash
opencode run "Analyze the authentication feature across all related files:
- src/hooks/useAuth.ts
- src/contexts/AuthContext.tsx
- src/services/authService.ts
- src/components/LoginForm.tsx

Provide:
1. Overview of the authentication flow
2. Potential security issues
3. Suggestions for improvement
4. Any inconsistencies between files" --model ollama/qwen3:8b-16k
```

### API Endpoint Analysis

```bash
opencode run "Analyze the user management API:
- src/api/routes/users.ts
- src/api/controllers/userController.ts
- src/api/services/userService.ts
- src/api/models/User.ts

Check for:
- Consistent error handling
- Input validation across layers
- Security vulnerabilities
- Performance issues" --model ollama/qwen3:8b-16k
```

## Component Relationships

### Analyze Component Tree

```bash
opencode run "Analyze the component hierarchy:
- src/components/Dashboard/index.tsx
- src/components/Dashboard/Header.tsx
- src/components/Dashboard/Sidebar.tsx
- src/components/Dashboard/Content.tsx

Questions:
1. Is prop drilling occurring?
2. Should we use context or state management?
3. Are there performance issues with re-renders?
4. Is the component structure logical?" --model ollama/qwen3:8b-16k
```

## Architecture Review

### Analyze File Organization

```bash
opencode run "Review the file organization in src/features/blog/:
- index.ts
- BlogList.tsx
- BlogPost.tsx
- BlogEditor.tsx
- blogService.ts
- blogTypes.ts

Questions:
1. Does the structure follow best practices?
2. Are concerns properly separated?
3. Should files be reorganized?
4. Are there missing files (tests, types, etc.)?" --model ollama/qwen3:8b-16k
```

## Configuration Analysis

### Analyze Related Config Files

```bash
opencode run "Analyze the build configuration:
- vite.config.ts
- tsconfig.json
- tailwind.config.js
- package.json (scripts section)

Check for:
- Consistency between configs
- Missing optimizations
- Potential conflicts
- Best practices" --model ollama/qwen3:8b-16k
```

## Theme/Style Analysis

### Analyze Styling Approach

```bash
opencode run "Analyze the styling approach across:
- src/styles/globals.css
- tailwind.config.js
- src/components/Button/Button.tsx
- src/components/Card/Card.tsx

Questions:
1. Is the styling approach consistent?
2. Should we extract shared styles?
3. Are we using Tailwind effectively?
4. Are there unused styles?" --model ollama/qwen3:8b-16k
```

## WordPress Block Analysis

### Analyze Block Structure

```bash
opencode run "Analyze this WordPress block implementation:
- resources/js/blocks/hero/index.tsx
- resources/js/blocks/hero/edit.tsx
- resources/js/blocks/hero/save.tsx
- resources/js/blocks/hero/block.json

Check for:
- Gutenberg best practices
- TypeScript usage
- Attribute definitions
- Performance considerations" --model ollama/qwen3:8b-16k
```

## Cross-File Consistency

### Analyze Naming Conventions

```bash
opencode run "Check naming consistency across:
- src/types/user.ts
- src/services/userService.ts
- src/api/routes/users.ts
- src/components/UserProfile.tsx

Identify:
1. Inconsistent naming (User vs user vs USER)
2. Different conventions (camelCase vs PascalCase)
3. Abbreviations vs full words
4. Suggest standardization" --model ollama/qwen3:8b-16k
```

### Analyze Error Handling Patterns

```bash
opencode run "Review error handling across:
- src/api/middleware/errorHandler.ts
- src/services/apiService.ts
- src/hooks/useFetch.ts
- src/components/ErrorBoundary.tsx

Questions:
1. Is error handling consistent?
2. Are errors properly typed?
3. Are all errors caught and handled?
4. Should we centralize error handling?" --model ollama/qwen3:8b-16k
```

## Data Flow Analysis

### Analyze State Management

```bash
opencode run "Trace the state flow for user data:
- src/contexts/UserContext.tsx
- src/hooks/useUser.ts
- src/services/userService.ts
- src/components/UserProfile.tsx
- src/components/UserSettings.tsx

Map out:
1. Where state is stored
2. How state is updated
3. Which components consume state
4. Potential state synchronization issues" --model ollama/qwen3:8b-16k
```

## Dependencies Analysis

### Analyze Import Relationships

```bash
opencode run "Analyze the import structure in src/features/auth/:
- index.ts
- AuthProvider.tsx
- useAuth.ts
- authService.ts
- authTypes.ts

Check for:
- Circular dependencies
- Unnecessary imports
- Missing exports
- Barrel file optimization" --model ollama/qwen3:8b-16k
```

## Test Coverage Analysis

### Analyze Test Completeness

```bash
opencode run "Review test coverage for the user feature:
- src/services/userService.ts
- src/services/userService.test.ts
- src/hooks/useUser.ts
- src/hooks/useUser.test.ts

Identify:
1. Missing test cases
2. Untested edge cases
3. Test quality issues
4. Opportunities for improvement" --model ollama/qwen3:8b-16k
```

## Interactive Multi-File Session

For exploratory analysis:

```bash
cd your-project
opencode

# Then in the session:
>>> Analyze all files in src/features/auth/ for security issues

>>> Now check if the same patterns are used in src/features/payment/

>>> Compare the two approaches and suggest which is better

>>> Create a shared security utility based on the best practices found
```

## Directory-Based Analysis

```bash
# Analyze entire directory
opencode run "Analyze all files in src/components/form/ for:
- Component structure consistency
- Shared props/types
- Accessibility compliance
- Validation patterns
Suggest refactoring opportunities." --model ollama/qwen3:8b-16k
```

## Real-World Example: WordPress Theme

```bash
opencode run "Analyze the Sage theme structure:
- resources/views/layouts/app.blade.php
- resources/js/app.js
- resources/css/app.css
- app/setup.php
- app/filters.php

Understand:
1. How assets are loaded
2. How templates are structured
3. Where hooks are registered
4. Potential conflicts or issues" --model ollama/qwen3:8b-16k
```

## Performance Analysis Across Files

```bash
opencode run "Analyze performance across:
- src/hooks/useProducts.ts (data fetching)
- src/components/ProductList.tsx (rendering)
- src/components/ProductCard.tsx (individual items)

Identify:
- Unnecessary re-renders
- Missing memoization
- Inefficient data fetching
- Opportunities for virtualization" --model ollama/qwen3:8b-16k
```

## Security Analysis

```bash
opencode run "Security audit across:
- src/api/middleware/auth.ts
- src/services/authService.ts
- src/utils/jwt.ts
- src/config/security.ts

Check for:
- Authentication vulnerabilities
- Authorization issues
- Token handling
- Secrets exposure
- Input validation" --model ollama/qwen3:8b-16k
```

## Tips for Effective Multi-File Analysis

1. **Prioritize related files:**
   - Files that work together (same feature)
   - Files with similar responsibilities
   - Files that import from each other

2. **Be specific about the relationship:**
   - "Compare approaches"
   - "Trace data flow"
   - "Find inconsistencies"

3. **Set clear goals:**
   - What are you trying to learn?
   - What problems are you trying to find?
   - What decisions are you trying to make?

4. **Use structured questions:**
   - Break analysis into specific questions
   - Easier for model to provide focused answers

5. **Consider file size:**
   - 16k context = ~12,000 words
   - Include only necessary files
   - Use summaries for very large files

## Context Window Management

### Estimate Token Usage

Rough estimates:
- 1 line of code ≈ 4-6 tokens
- 500-line file ≈ 2,000-3,000 tokens
- System prompts ≈ 1,000-2,000 tokens

**Example calculation for 16k context:**
- System prompts: 2,000 tokens
- Available for files: 14,000 tokens
- Can fit: ~4-5 medium files (500-700 lines each)

### Strategies for Large Codebases

If you exceed context limits:

1. **Break into chunks:**
   ```bash
   # First analyze part 1
   opencode run "Analyze auth flow: authService.ts, useAuth.ts" --model ollama/qwen3:8b-16k

   # Then analyze part 2
   opencode run "Analyze auth UI: LoginForm.tsx, RegisterForm.tsx" --model ollama/qwen3:8b-16k

   # Then synthesize
   opencode run "Based on previous analysis, suggest improvements to overall auth system" --model ollama/qwen3:8b-16k
   ```

2. **Use summaries:**
   ```bash
   opencode run "First, summarize each file in src/features/auth/. Then analyze relationships between them." --model ollama/qwen3:8b-16k
   ```

3. **Focus on specific aspects:**
   - Instead of "analyze everything"
   - Focus on: security, performance, types, etc.
   - One aspect at a time

## Performance Expectations

| Task | Files | Model | Expected Time |
|------|-------|-------|---------------|
| 2-3 files | Small | `qwen3:8b` | 30-45s |
| 3-5 files | Medium | `qwen3:8b-16k` | 45-90s |
| 5-7 files | Medium | `qwen3:8b-16k` | 90-150s |
| Complex analysis | 3-5 files | `mistral-nemo:12b` | 60-120s |

## When to Use Cloud Models

Use Claude Sonnet 4 (200k context) for:
- Analyzing 10+ files at once
- Whole codebase architecture review
- Complex cross-feature analysis
- When speed is critical

Use local models for:
- Focused feature analysis (3-5 files)
- Offline work
- Sensitive code
- Learning and experimentation
