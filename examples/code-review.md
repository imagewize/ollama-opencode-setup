# Code Review Example Workflows

Example prompts and workflows for using Open Code CLI with local models for code review tasks.

## Quick Code Review

**Best model:** `mistral-nemo:12b-instruct-2407-q4_K_M` or `qwen3:8b`

```bash
opencode run "Review the code in src/components/Header.tsx for potential bugs and improvements" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

## Multi-File Review

**Best model:** `qwen3:8b-16k` (extended context)

```bash
opencode run "Review all files in src/components/ for consistency and best practices" --model ollama/qwen3:8b-16k
```

## Security Review

**Prompt template:**
```bash
opencode run "Analyze [file] for security vulnerabilities including:
- SQL injection
- XSS vulnerabilities
- Authentication issues
- Input validation
- Secrets exposure" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

**Example:**
```bash
opencode run "Analyze src/api/auth.ts for security vulnerabilities including SQL injection, XSS, authentication issues, input validation, and secrets exposure" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

## Performance Review

**Prompt template:**
```bash
opencode run "Review [file] for performance issues:
- Inefficient algorithms
- Memory leaks
- Unnecessary re-renders (React)
- Database query optimization
- Caching opportunities" --model ollama/qwen3:8b-16k
```

**Example:**
```bash
opencode run "Review src/components/Dashboard.tsx for performance issues including inefficient algorithms, memory leaks, unnecessary re-renders, and caching opportunities" --model ollama/qwen3:8b-16k
```

## Accessibility Review

**Example:**
```bash
opencode run "Review src/components/Form.tsx for accessibility issues:
- ARIA labels
- Keyboard navigation
- Screen reader support
- Color contrast
- Focus management" --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

## Code Style Review

**Example:**
```bash
opencode run "Review src/utils/ directory for code style consistency:
- Naming conventions
- Function size
- Code duplication
- Comment quality
- File organization" --model ollama/qwen3:8b
```

## Interactive Review Session

For more thorough reviews, use interactive mode:

```bash
cd your-project
opencode

# Then in the session:
>>> Review src/components/Header.tsx for bugs and improvements

>>> Now check if the same issues exist in src/components/Footer.tsx

>>> Suggest refactoring to share common logic between Header and Footer
```

## Batch Review Script

Create a script to review multiple files:

```bash
#!/bin/bash
# review-all.sh

FILES=(
  "src/components/Header.tsx"
  "src/components/Footer.tsx"
  "src/components/Navigation.tsx"
  "src/components/Sidebar.tsx"
)

for file in "${FILES[@]}"; do
  echo "Reviewing $file..."
  opencode run "Review $file for bugs, performance, and best practices" --model ollama/qwen3:8b
  echo "---"
done
```

## Review Output Format

Request structured output:

```bash
opencode run "Review src/api/users.ts and provide output in this format:

## Issues Found
- [Severity: High/Medium/Low] Description
- ...

## Suggestions
1. Suggestion with code example
2. ...

## Positive Aspects
- What's done well
- ..." --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```

## Comparing Implementations

```bash
opencode run "Compare the implementation in src/utils/formatDate.ts with src/helpers/dateFormatter.ts. Which approach is better and why? Suggest a unified implementation." --model ollama/qwen3:8b-16k
```

## Tips

1. **Use extended context for related files:**
   - `qwen3:8b-16k` can analyze 3-5 medium files at once
   - Useful for reviewing feature branches with multiple changed files

2. **Be specific about what to look for:**
   - Generic "review this file" prompts get generic responses
   - Specify areas: security, performance, accessibility, etc.

3. **Use smaller models for quick checks:**
   - `qwen3:4b` for basic syntax/style checks
   - Faster feedback for simple issues

4. **Combine with automated tools:**
   - Use ESLint/Prettier for style enforcement
   - Use local models for logic, architecture, and design reviews

5. **Request code examples:**
   - "Show me how to fix this with code examples"
   - More actionable than descriptions alone

## Performance Expectations

| Task | Model | Expected Time |
|------|-------|---------------|
| Single file review | `qwen3:8b` | 15-30s |
| Single file review (detailed) | `mistral-nemo:12b` | 25-45s |
| Multi-file review (3-5 files) | `qwen3:8b-16k` | 45-90s |
| Quick syntax check | `qwen3:4b` | 8-15s |

## Example Review Request (Real-World)

```bash
opencode run "Review resources/js/blocks/hero/index.tsx:

Context: This is a WordPress Gutenberg block for a hero section

Please check for:
1. TypeScript type safety
2. WordPress block best practices
3. Performance (unnecessary re-renders)
4. Accessibility (ARIA, keyboard navigation)
5. Code organization and readability

Provide specific code examples for any issues found." --model ollama/mistral-nemo:12b-instruct-2407-q4_K_M
```
