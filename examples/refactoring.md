# Refactoring Example Workflows

Example prompts and workflows for using Open Code CLI with local models for refactoring tasks.

## Simple Refactoring

**Best model:** `qwen3:8b` or `mistral-nemo:12b-instruct-2407-q4_K_M`

### Extract Function

```bash
opencode run "In src/utils/validation.ts, extract the email validation logic into a separate reusable function" --model ollama/qwen3:8b
```

### Rename Variable

```bash
opencode run "In src/components/UserList.tsx, rename all instances of 'usr' to 'user' for better readability" --model ollama/qwen3:4b
```

### Simplify Conditional

```bash
opencode run "Simplify the nested if statements in src/services/auth.ts lines 45-78 using early returns" --model ollama/qwen3:8b
```

## TypeScript Migration

**Best model:** `mistral-nemo:12b-instruct-2407-q4_K_M` (best for type inference)

```bash
opencode run "Convert src/utils/helpers.js to TypeScript with proper type definitions and interfaces" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

## React Refactoring

### Component Extraction

```bash
opencode run "Extract the user profile section from src/pages/Dashboard.tsx into a separate UserProfile component in src/components/" --model ollama/qwen3:8b
```

### Hooks Refactoring

```bash
opencode run "Refactor src/components/ProductList.tsx to use custom hooks for data fetching and filtering logic" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

### Props Interface

```bash
opencode run "Update src/components/Button.tsx to use a proper TypeScript interface for props, including all possible variants" --model ollama/qwen3:8b
```

## Code Organization

**Best model:** `qwen3:8b-16k` (for analyzing multiple files)

### File Structure

```bash
opencode run "Analyze the file structure in src/features/auth/ and suggest a better organization following feature-based architecture" --model ollama/qwen3:8b-16k
```

### Move Functions

```bash
opencode run "Move all date formatting functions from src/utils/helpers.ts into a new src/utils/date.ts file" --model ollama/qwen3:8b
```

## Remove Code Duplication

**Example:**
```bash
opencode run "Find and remove code duplication between src/components/Header.tsx and src/components/Footer.tsx by creating shared components or utilities" --model ollama/qwen3:8b-16k
```

## Modernize Code

### ES6+ Features

```bash
opencode run "Modernize src/utils/legacy.js to use ES6+ features:
- Replace var with const/let
- Use arrow functions
- Use template literals
- Use destructuring
- Use spread operator" --model ollama/qwen3:8b
```

### Async/Await

```bash
opencode run "Refactor src/api/users.js to use async/await instead of promise chains" --model ollama/qwen3:8b
```

## Performance Refactoring

### Memoization

```bash
opencode run "Add React.memo and useMemo to src/components/ExpensiveList.tsx to prevent unnecessary re-renders" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

### Lazy Loading

```bash
opencode run "Refactor src/App.tsx to use React.lazy and Suspense for code splitting on route components" --model ollama/qwen3:8b
```

## Design Pattern Application

### Factory Pattern

```bash
opencode run "Refactor src/services/notification.ts to use the Factory pattern for creating different notification types (email, SMS, push)" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

### Strategy Pattern

```bash
opencode run "Refactor src/utils/sorting.ts to use the Strategy pattern for different sorting algorithms" --model ollama/qwen3:8b
```

## Interactive Refactoring Session

For complex refactoring, use interactive mode:

```bash
cd your-project
opencode

# Then in the session:
>>> Analyze src/components/Dashboard.tsx and identify opportunities for refactoring

>>> Extract the statistics section into a separate component

>>> Now create a custom hook for the data fetching logic

>>> Add proper TypeScript interfaces for all props and state

>>> Update the tests to reflect these changes
```

## Batch Refactoring

Create a refactoring script:

```bash
#!/bin/bash
# modernize-components.sh

COMPONENTS=(
  "src/components/Header.tsx"
  "src/components/Footer.tsx"
  "src/components/Navigation.tsx"
)

for component in "${COMPONENTS[@]}"; do
  echo "Refactoring $component..."
  opencode run "Modernize $component:
  - Use functional components with hooks
  - Add proper TypeScript types
  - Use React.memo if needed
  - Extract complex logic into custom hooks" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
  echo "---"
done
```

## Complex Multi-File Refactoring

**Best model:** `qwen3:8b-16k` (extended context)

```bash
opencode run "Refactor the authentication flow across these files:
- src/hooks/useAuth.ts
- src/contexts/AuthContext.tsx
- src/services/authService.ts

Goals:
1. Centralize auth logic in the service layer
2. Simplify the context to only expose necessary state
3. Make the hook more reusable
4. Add proper error handling" --model ollama/qwen3:8b-16k
```

## Refactoring Checklist

When requesting refactoring, include:

```bash
opencode run "Refactor [file] to [goal]:

Before refactoring, ensure:
- [ ] All tests pass
- [ ] No breaking changes to public API
- [ ] Type safety is maintained or improved
- [ ] Performance is not degraded

After refactoring, verify:
- [ ] Tests still pass
- [ ] Code is more readable
- [ ] Follows project conventions
- [ ] Documentation is updated" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

## Step-by-Step Refactoring

For large refactoring tasks, break into steps:

```bash
# Step 1: Identify issues
opencode run "Analyze src/components/ComplexForm.tsx and create a refactoring plan" --model ollama/qwen3:8b

# Step 2: Extract validation
opencode run "Extract form validation logic from src/components/ComplexForm.tsx into src/utils/formValidation.ts" --model ollama/qwen3:8b

# Step 3: Extract components
opencode run "Extract form field components from src/components/ComplexForm.tsx into separate files in src/components/form/" --model ollama/qwen3:8b

# Step 4: Add types
opencode run "Add comprehensive TypeScript types to the refactored form components" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M

# Step 5: Update tests
opencode run "Update tests in src/components/ComplexForm.test.tsx to reflect the refactored structure" --model ollama/qwen3:8b
```

## Real-World Example: WordPress Block Refactoring

```bash
opencode run "Refactor resources/js/blocks/hero/index.tsx:

Context: WordPress Gutenberg block built with Sage theme

Refactoring goals:
1. Extract attribute types into separate interfaces
2. Create custom hooks for block state management
3. Split large render function into smaller components
4. Move inline styles to CSS modules or Tailwind classes
5. Add prop-types validation for all components

Ensure compatibility with WordPress block editor." --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

## Testing After Refactoring

```bash
# Generate tests for refactored code
opencode run "Generate unit tests for the refactored components in src/components/form/ using Jest and React Testing Library" --model ollama/qwen3:8b
```

## Documentation

```bash
# Update documentation after refactoring
opencode run "Update the JSDoc comments and README.md to reflect the refactoring changes in src/services/api/" --model ollama/qwen3:8b
```

## Tips

1. **Start small:**
   - Refactor one function at a time
   - Easier to review and test
   - Lower risk of breaking changes

2. **Use extended context for related files:**
   - When refactoring affects multiple files
   - `qwen3:8b-16k` can see the full picture

3. **Request before/after examples:**
   - "Show me the before and after code"
   - Helps verify the refactoring is correct

4. **Specify constraints:**
   - "Maintain backward compatibility"
   - "Don't change the public API"
   - "Keep the same test coverage"

5. **Review generated code:**
   - Local models may miss edge cases
   - Always test refactored code
   - Use version control to track changes

## Performance Expectations

| Task | Model | Expected Time |
|------|-------|---------------|
| Simple rename/extract | `qwen3:4b` | 8-15s |
| Single file refactor | `qwen3:8b` | 20-40s |
| Complex refactor | `mistral-nemo:12b` | 30-60s |
| Multi-file refactor | `qwen3:8b-16k` | 60-120s |

## Common Pitfalls

1. **Too much at once:**
   - Break large refactoring into smaller steps
   - Easier to debug if something goes wrong

2. **Not testing between steps:**
   - Test after each refactoring step
   - Helps identify which change broke something

3. **Ignoring project conventions:**
   - Specify your project's coding standards in the prompt
   - "Follow the naming conventions used in this project"

4. **Breaking backward compatibility:**
   - Explicitly state compatibility requirements
   - "Maintain the same function signature"
