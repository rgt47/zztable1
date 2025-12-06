# Claude Code Editing Options & Commands Guide

Complete reference for all editing capabilities, commands, and workflows in Claude Code.

---

## Table of Contents

1. [Slash Commands](#slash-commands)
2. [File Operations](#file-operations)
3. [Keyboard Shortcuts](#keyboard-shortcuts)
4. [Vim Editing Mode](#vim-editing-mode) ⭐ **NEW**
5. [Editor Configuration](#editor-configuration)
6. [Hooks & Workflows](#hooks--workflows)
7. [Special Features](#special-features-by-file-type)
8. [Your Current Setup](#your-current-setup)
9. [Quick Reference](#quick-reference)

---

## Slash Commands

### Core File Management Commands

| Command | Purpose | Syntax | Example |
|---------|---------|--------|---------|
| `/add-dir` | Add additional working directories | `/add-dir [path]` | `/add-dir ~/projects/other` |
| `/export` | Export conversation to file or clipboard | `/export [filename]` | `/export my-session.md` |
| `/memory` | Edit CLAUDE.md memory files | `/memory` | Opens editor for project memory |
| `/review` | Request code review | `/review` | Reviews pending changes |
| `/security-review` | Security analysis of pending changes | `/security-review` | Checks for security issues |

### Session & Environment Commands

| Command | Purpose | Notes |
|---------|---------|-------|
| `/clear` | Clear conversation history | Keeps files intact |
| `/compact [instructions]` | Compress conversation with optional focus | Reduces context size |
| `/rewind` | Restore to previous checkpoint | Choose files-only or full rewind |
| `/vim` | Enable Vim mode for editing | Toggle Vim key bindings |
| `/config` | Open tabbed Settings interface | Access all configuration options |
| `/terminal-setup` | Configure terminal input methods | Set multiline input preference |

### Custom Slash Commands

You can create your own commands for custom workflows.

**Storage Locations:**
- **Project-level**: `.claude/commands/` (shared with team)
- **Personal-level**: `~/.claude/commands/` (personal to your account)

**How to Create:**

Create a Markdown file in one of the above directories:

```markdown
---
description: "Analyze code for performance issues and suggest optimizations"
allowed-tools: ["Edit", "Read", "Grep"]
model: "claude-opus"
---

Analyze this code for performance issues and suggest optimizations:
```

**Features:**
- Use `$ARGUMENTS` or `$1`, `$2`, etc. for parameters
- Prefix with `!` to execute bash: `!npm test`
- Prefix with `@` to reference files: `@src/utils.js`
- Customize models and tool permissions per command

**Example Custom Commands:**

```markdown
---
description: "Format and lint staged files"
allowed-tools: ["Bash", "Edit"]
---

Format and lint all staged files:

!prettier --write $(git diff --staged --name-only)
!eslint --fix $(git diff --staged --name-only)
```

---

## File Operations

### Interactive Editing Tools

#### Edit
Modify existing files with contextual, surgical changes rather than overwriting entire files.

```r
# Edit tool applied automatically by Claude
# Example: Fix a bug in an existing function
```

**Best for:** Small modifications, bug fixes, refactoring

#### Write
Create new files or completely overwrite existing ones.

```r
# Write tool creates or overwrites files
# Example: Creating a new configuration file
```

**Best for:** New files, complete rewrites

#### Read
View file contents (automatically done when context is needed).

```r
# Read tool retrieves file contents
# Triggered automatically by Claude when needed
```

**Best for:** Understanding code before editing

#### Glob
Find files matching glob patterns.

**Pattern Examples:**
- `**/*.ts` - All TypeScript files recursively
- `src/**/*.jsx` - JSX files in src
- `tests/test-*.R` - R test files
- `*.{md,txt}` - Multiple extensions

**Best for:** Large-scale refactoring, finding specific file types

### File Reference Syntax

Use the `@` symbol to reference files without waiting for Claude to read them:

```
@src/utils/auth.js        # Single file
@src/components           # Directory
@github:repos/owner/repo/issues    # MCP resources
```

This helps Claude understand scope before diving into details.

### Checkpointing & Recovery

Claude Code **automatically tracks all edits** made through native tools:

- Each user prompt creates a checkpoint
- Use `/rewind` to restore earlier file states
- Choose "file changes only" or "conversation + files"
- **Note**: Checkpoints don't track bash command changes

---

## Keyboard Shortcuts

### General Controls

| Shortcut | Action | Platform |
|----------|--------|----------|
| **Ctrl+C** | Interrupt current input/generation | All |
| **Ctrl+D** | Exit the session | Unix/Linux/macOS |
| **Ctrl+L** | Clear screen (preserves history) | All |
| **Ctrl+O** | Toggle verbose output mode | All |
| **Ctrl+R** | Search command history interactively | All |
| **Ctrl+B** | Move bash command to background | All |
| **Esc + Esc** | Rewind code and conversation | All |
| **Tab** | Toggle extended thinking feature | All |
| **Shift+Tab** or **Alt+M** | Switch permission modes | All |

### Multiline Input Methods

| Method | Platforms | Notes |
|--------|-----------|-------|
| **Backslash + Enter** (e.g., `\` then Enter) | All terminals | Most compatible |
| **Option+Enter** | macOS | Terminal-dependent |
| **Shift+Enter** | After `/terminal-setup` | Configure via settings |
| **Ctrl+J** | All | Insert line feed for multiline |

**Note**: Use `/terminal-setup` to configure your preferred multiline input method.

### Clipboard & Media

| Shortcut | Action | Platform |
|----------|--------|----------|
| **Ctrl+V** | Paste image from clipboard | Linux, macOS |
| **Alt+V** | Paste image from clipboard | Windows |

---

## Vim Editing Mode

Enable Vim mode with `/vim` command. Vim is a powerful modal editor that dramatically increases editing speed once mastered.

**Quick Start**: `/vim` to enable, press `Esc` to ensure you're in Normal mode

### Vim Modes Overview

#### Normal Mode (Command Mode)
- Default mode - used for navigation and issuing commands
- **Enter**: Press `Esc` from Insert/Visual mode
- Most efficient for navigating and executing commands

#### Insert Mode
- Used for typing text
- **Enter** with: `i` (before cursor), `a` (after cursor), `I` (line start), `A` (line end), `o` (new line), `O` (line above)
- **Exit**: Press `Esc`

#### Visual Mode
- Used for selecting text
- `v` = Character selection, `V` = Line selection, `Ctrl+v` = Block selection
- **Exit**: Press `Esc`

#### Command Mode
- Execute Vim commands starting with `:`
- Examples: `:w` (save), `:q` (quit), `:s/old/new/g` (replace)
- **Exit**: Press `Esc`

---

### Navigation Commands - The Foundation

**Master these first - they're the fastest way to move:**

#### Single Character Movement
```vim
h  j  k  l       " Left, Down, Up, Right (like arrow keys)
5h  10j  3k  7l  " Counts work: move 5 left, 10 down, etc.
```

#### Word Navigation (FAST)
```vim
w              " Jump to next word start
e              " Jump to end of word
b              " Jump to previous word start
3w             " Jump 3 words forward
5b             " Jump 5 words back
W, E, B        " Same but skip punctuation (WORD vs word)
```

#### Line Navigation
```vim
0   ^   $      " Start, first char, end of line
Home End       " Alternative keys
g_             " Last non-blank character
```

#### Document Navigation
```vim
gg             " Jump to first line
G              " Jump to last line
42G            " Jump to line 42
:100           " Command mode: go to line 100
Ctrl+Home      " Jump to start (alternative)
Ctrl+End       " Jump to end (alternative)
```

#### Page Navigation
```vim
Ctrl+f         " Page down (forward)
Ctrl+b         " Page up (backward)
Ctrl+d         " Half page down
Ctrl+u         " Half page up
```

#### Search Navigation
```vim
/pattern       " Search forward for pattern
?pattern       " Search backward
*              " Search word under cursor (forward)
#              " Search word under cursor (backward)
n              " Next match
N              " Previous match
f{char}        " Find character forward on line (fa = find 'a')
t{char}        " Move to before character forward
;              " Repeat last f/F/t/T
,              " Reverse direction
```

---

### Editing Commands - Most Used

#### Delete Operations
```vim
x              " Delete character at cursor
X              " Delete character before cursor
dd             " Delete entire line
5dd            " Delete 5 lines
dw             " Delete word
d$             " Delete to end of line
dG             " Delete to end of file
D              " Shortcut for d$ (to end of line)
```

#### Change Operations (Delete + Insert)
```vim
cw             " Delete word and enter insert mode
cc             " Delete line and enter insert mode
c$             " Delete to end of line and insert
C              " Shortcut for c$
s              " Substitute single character
S              " Substitute entire line
```

#### Insert Modes
```vim
i              " Insert before cursor
I              " Insert at line start
a              " Append after cursor
A              " Append at line end
o              " Open new line below
O              " Open new line above
R              " Replace mode (overwrite as you type)
```

#### Copy/Paste (Yank)
```vim
yy             " Copy entire line
5yy            " Copy 5 lines
yw             " Copy word
y$             " Copy to end of line
p              " Paste after cursor
P              " Paste before cursor
"+y            " Copy to system clipboard (yy with system)
```

#### Undo/Redo
```vim
u              " Undo last change
U              " Undo all changes on line
Ctrl+r         " Redo (opposite of undo)
.              " Repeat last command (VERY powerful)
```

#### Case Changes
```vim
~              " Toggle case of single character
gU{motion}     " Uppercase: gUw = UPPERCASE word
gu{motion}     " Lowercase: guw = lowercase word
g~{motion}     " Toggle case: g~w = toggle word
gUU            " Uppercase entire line
guu            " Lowercase entire line
```

#### Advanced Edits
```vim
>>             " Indent line
<<             " Unindent line
5>>            " Indent 5 lines
J              " Join with next line
gJ             " Join without space
Ctrl+a         " Increment number (5 → 6)
Ctrl+x         " Decrement number (5 → 4)
```

---

### Selection & Copying - Visual Mode

```vim
v              " Character-wise selection
V              " Line-wise selection
Ctrl+v         " Block-wise selection
o              " Toggle cursor end in selection
```

**In visual mode, most editing commands work on selection:**
```vim
d              " Delete selected text
c              " Change selected text
y              " Copy selected text
>              " Indent selection
<              " Unindent selection
```

---

### Search & Replace

#### Find and Replace on Current Line
```vim
:s/old/new/    " Replace first 'old' with 'new'
:s/old/new/g   " Replace all on line
:s/old/new/c   " Replace with confirmation
```

#### Find and Replace in File
```vim
:%s/old/new/g       " Replace all in entire file
:1,10s/old/new/g    " Replace in lines 1-10
:.,+5s/old/new/g    " Replace in current line + 5 lines
:%s/old/new/gc      " Replace all with confirmation
:%s/old/new/i       " Case-insensitive replace
```

#### Search Settings
```vim
/pattern       " Case-sensitive search
:set ignorecase    " Make searches case-insensitive
:set smartcase     " Smart case (auto-insensitive)
:nohlsearch    " Turn off search highlighting
```

---

### Text Objects - Context-Aware Editing

**Pattern**: `{operator}{text-object}` (e.g., `daw` = delete a word)

This is what makes Vim powerful - understanding semantic units, not just character positions.

#### Word Objects
```vim
w              " Word (to end)
aw             " A word (with space)
iw             " Inner word (no space)
3aw            " 3 words with spaces
daw            " Delete word (the most useful one)
ciw            " Change inner word
yaw            " Yank word with space
```

#### Bracket/Quote Objects
```vim
di(            " Delete inside parentheses
da(            " Delete with parentheses
ci{            " Change inside braces
ca{            " Change around braces
di"            " Delete inside "quotes"
da'            " Delete 'word' with quotes
```

#### Sentence & Paragraph Objects
```vim
dis            " Delete inside sentence
dap            " Delete around paragraph
das            " Delete a sentence
yap            " Yank paragraph
```

#### HTML/XML Tags
```vim
dit            " Delete tag contents
dat            " Delete tag and contents
```

---

### Marks & Jumps - Return to Important Positions

```vim
ma             " Set mark 'a' at cursor (a-z are local)
mA             " Set mark 'A' global (A-Z across files)
`a             " Jump to mark 'a' exact position
'a             " Jump to mark 'a' line start
`'             " Jump back to previous position
Ctrl+o         " Jump to previous position
Ctrl+i         " Jump to next position
```

---

### Advanced Features

#### Macros - Record and Replay Commands
```vim
qa             " Start recording macro 'a'
(type commands)
q              " Stop recording
@a             " Replay macro 'a'
10@a           " Repeat macro 10 times
@:             " Repeat last command
```

#### Block Editing (Game Changer)
```vim
Ctrl+v         " Start block selection
Down/Up/Space  " Select block
I              " Insert at block start
Text           " Type text
Esc            " Apply to all selected lines!
```

**Example: Add comment to 10 lines**
```
Position at line 1: Ctrl+v 10j I // Esc
Result: "//" added to all 10 selected lines
```

---

### Command Mode Reference

#### File Commands
```vim
:w             " Save
:w filename    " Save as
:q             " Quit
:q!            " Quit without saving
:wq            " Save and quit
:e filename    " Open file
```

#### Line Commands
```vim
:10            " Go to line 10
:10,20d        " Delete lines 10-20
:10,20y        " Copy lines 10-20
:10copy 20     " Copy line 10 after line 20
:%d            " Delete all lines
```

#### Settings
```vim
:set number        " Show line numbers
:set relativenumber " Relative line numbers
:set tabstop=4     " Tab width
:set shiftwidth=4  " Indent width
:set expandtab     " Use spaces instead of tabs
:set hlsearch      " Highlight search results
```

---

### Power User Combinations

**These combinations save massive amounts of time:**

| Goal | Keys | Speed Benefit |
|------|------|--------------|
| Delete word and insert | `cw` | Single key vs `dw` + `i` |
| Delete 5 lines | `5dd` | 3 keys vs manual deletion |
| Change inside quotes | `ci"` | Semantic understanding |
| Uppercase word | `gUw` | 3 keys for context-aware |
| Repeat last action | `.` | Golden command |
| Jump to mark | `` `a `` | Instant repositioning |
| Copy word | `yw` | Precise selection |
| Select and delete | `vwd` | Visual selection power |

---

### Operator + Motion Formula

**Master Pattern**: `{operator}{count}{motion}`

- **Operators**: `d` (delete), `c` (change), `y` (yank), `>` (indent), `<` (unindent), `=` (format)
- **Count**: `1-9` for repetition
- **Motion**: `w` (word), `j` (down), `$` (end), `G` (end of file), etc.

**Examples:**
```vim
d2w         " Delete 2 words
3j          " Down 3 lines
5>>         " Indent 5 lines
c$          " Change to line end
y5j         " Copy down 5 lines
>2}         " Indent next 2 paragraphs
```

---

### Practical Examples

#### Example 1: Edit Function Parameters
```vim
/function      " Find function
f(             " Move to paren
caw            " Change word
x              " Type 'x'
w              " Next word
caw            " Change word
y              " Type 'y'
```

#### Example 2: Delete All Lines with Pattern
```vim
:g/console\.log/d   " Delete all console.log lines
```

#### Example 3: Add Comment to Multiple Lines
```vim
:10,20s/^/\/\/ /    " Add // to lines 10-20
```

#### Example 4: Copy Entire Function
```vim
ma             " Set mark
(navigate)
y'a            " Yank to mark
p              " Paste
```

#### Example 5: Block Insert
```vim
Ctrl+v         " Block select
Down Down      " Select multiple lines
I              " Insert at block start
// Space       " Type comment
Esc            " Apply to all
```

---

### Learning Path

#### Day 1-2: Movement (Most Important!)
- Master: `hjkl`, `w`, `e`, `b`, `0`, `$`, `gg`, `G`
- Practice: Navigate 100-line file using only Vim
- Goal: Reach line with 3 keypresses max

#### Day 3-4: Basic Editing
- Master: `i`, `a`, `dd`, `dw`, `cw`, `u`
- Practice: Simple edits (change a word, delete a line)
- Goal: Edit as fast as mouse operations

#### Day 5-7: Intermediate
- Master: `v`, `y`, `p`, `/`, `:s/`, Text objects
- Practice: Select and edit, find and replace
- Goal: Complex multi-step edits in 5-10 keypresses

#### Week 2+: Advanced
- Master: Marks, macros, block editing, command mode
- Practice: Large refactorings, batch operations
- Goal: Productivity 3-5x faster than before

---

### Tips for Mastery

1. **Use counts heavily**: `5w` is faster than `w w w w w`
2. **Combine operators with motions**: `d5w` > `dw dw dw dw dw`
3. **Learn text objects**: `daw` > character-by-character deletion
4. **Use the dot command**: Repeat complex changes with `.`
5. **Set up marks**: Jump instantly back to important positions
6. **Use search**: `/pattern` gets you there in 2 seconds
7. **Practice one concept per day** - don't try to learn everything at once

---

### Resources

- Type `:help` in Vim for comprehensive documentation
- Run `:vimtutor` for interactive tutorial
- Practice one concept per day
- Focus on navigation first - it's the foundation

---

## Editor Configuration

### Settings File Hierarchy

Claude Code reads settings from multiple locations (in priority order):

1. **Command-line arguments** (highest priority)
2. **Enterprise managed settings** (`managed-settings.json`) - System policies
3. **Project local settings** (`.claude/settings.local.json`) - Personal per-project
4. **Project shared settings** (`.claude/settings.json`) - Team shared
5. **User settings** (`~/.claude/settings.json`) - Your personal defaults

### Key Configuration Options

#### Model Selection
```json
{
  "model": "haiku|sonnet|opus",
  "alwaysThinkingEnabled": true
}
```

#### Permission Controls
```json
{
  "permissions": {
    "bash": "ask|allow|deny",
    "write": "ask|allow|deny",
    "web": "ask|allow|deny",
    "edit": "ask|allow|deny"
  },
  "exclude-files": [
    "secrets/*",
    ".env*",
    "*.key",
    "*.pem"
  ]
}
```

#### Output & Formatting
```json
{
  "output": {
    "style": "compact|verbose",
    "theme": "dark|light",
    "markdown": true
  },
  "status-line": {
    "enabled": true,
    "position": "top|bottom"
  }
}
```

#### Advanced Options
```json
{
  "sandbox": "enabled|disabled",
  "token-budget": 200000,
  "timeout": 600000,
  "proxy": "http://proxy.example.com:8080",
  "environment-variables": {
    "API_KEY": "...",
    "CUSTOM_VAR": "value"
  }
}
```

### Accessing Configuration

Use the `/config` command to open a **tabbed Settings interface** where you can:

- View current status information
- Modify configuration options
- Enable/disable features
- Manage permissions
- Configure output styles
- Set environment variables
- Manage MCP servers

### Example Settings File

```json
{
  "model": "sonnet",
  "alwaysThinkingEnabled": true,
  "permissions": {
    "bash": "ask",
    "write": "ask",
    "web": "deny"
  },
  "exclude-files": [
    ".env*",
    "*.key",
    "node_modules",
    ".git"
  ],
  "output": {
    "style": "verbose"
  },
  "environment-variables": {
    "GITHUB_TOKEN": "${GITHUB_TOKEN}",
    "NPM_TOKEN": "${NPM_TOKEN}"
  }
}
```

---

## Hooks & Workflows

Hooks allow you to automate tasks like formatting, linting, and validation.

### Available Hook Types

#### PreToolUse
**Triggers**: After Claude creates tool parameters, before execution

**Use Cases:**
- Validate file operations
- Modify parameters
- Check file permissions
- Enforce naming conventions

```json
{
  "type": "PreToolUse",
  "matcher": "Write|Edit",
  "hooks": [
    {
      "type": "command",
      "command": "lint-check.sh"
    }
  ]
}
```

#### PostToolUse
**Triggers**: Immediately after a tool completes successfully

**Use Cases:**
- Run formatters after edits
- Execute tests
- Rebuild projects
- Update documentation

```json
{
  "type": "PostToolUse",
  "matcher": "Edit",
  "hooks": [
    {
      "type": "command",
      "command": "prettier --write $FILE"
    }
  ]
}
```

#### PermissionRequest
**Triggers**: When permission dialogs appear

**Use Cases:**
- Auto-approve specific file operations
- Deny writes to critical files
- Enforce security policies
- Automation in trusted scenarios

```json
{
  "type": "PermissionRequest",
  "matcher": "Write:/src/**",
  "hooks": [
    {
      "type": "auto-approve"
    }
  ]
}
```

### Configuring Hooks

Hooks are configured in `.claude/hooks.json`:

```json
{
  "hooks": [
    {
      "id": "format-on-edit",
      "matcher": "Edit",
      "type": "PostToolUse",
      "hooks": [
        {
          "type": "command",
          "command": "prettier --write $FILE"
        }
      ]
    },
    {
      "id": "validate-before-write",
      "matcher": "Write:/**/*.json",
      "type": "PreToolUse",
      "hooks": [
        {
          "type": "command",
          "command": "jq . $FILE"
        }
      ]
    },
    {
      "id": "test-on-edit",
      "matcher": "Edit:/src/**/*.ts",
      "type": "PostToolUse",
      "hooks": [
        {
          "type": "command",
          "command": "npm test -- --testPathPattern=$FILE"
        }
      ]
    }
  ]
}
```

### Practical Workflow Examples

#### Auto-format TypeScript Files
```json
{
  "matcher": "Edit:/**/*.ts",
  "type": "PostToolUse",
  "hooks": [
    {
      "type": "command",
      "command": "prettier --write $FILE && eslint --fix $FILE"
    }
  ]
}
```

#### Validate JSON Before Writing
```json
{
  "matcher": "Write:/**/*.json",
  "type": "PreToolUse",
  "hooks": [
    {
      "type": "command",
      "command": "jq . $FILE > /dev/null"
    }
  ]
}
```

#### Run Tests After Code Changes
```json
{
  "matcher": "Edit:/src/**/*.js",
  "type": "PostToolUse",
  "hooks": [
    {
      "type": "command",
      "command": "npm test -- --testPathPattern=$(echo $FILE | sed 's/src/test/g')"
    }
  ]
}
```

#### Auto-commit Changes
```json
{
  "matcher": "Edit",
  "type": "PostToolUse",
  "hooks": [
    {
      "type": "command",
      "command": "git add $FILE && git commit -m 'Auto-commit: $FILE modified'"
    }
  ]
}
```

---

## Special Features by File Type

### Code Editing
- **Syntax-aware edits** with context preservation
- **Integration with linters and formatters** via hooks
- **Directory references** with `@src/` syntax
- **Code review** with `/review` command
- **Security analysis** with `/security-review`

**Best Practices:**
- Use `@` for large files to save context
- Enable Vim mode for power editing
- Set up hooks for automatic formatting
- Use `/review` before committing

### Markdown Files
- **Metadata frontmatter** support
- **KaTeX math rendering** for documentation
- **Table editing** support
- **Automatic formatting** preservation

**Example:**
```markdown
---
author: "Your Name"
date: 2025-12-06
---

# Document Title

Content here...

| Header 1 | Header 2 |
|----------|----------|
| Value 1  | Value 2  |
```

### Jupyter Notebooks (.ipynb)
- **Cell-by-cell editing** support
- **Output preservation** during changes
- **Code execution** capabilities
- **Integration with visualizations**

### Configuration Files
- **JSON validation** before writing
- **YAML support** with formatting
- **Environment variable references**
- **Hierarchical settings** management

### Documentation & Memory
- **`/memory` command** to edit CLAUDE.md
- **Automatic memory injection** into context
- **Project-specific vs. personal** instructions
- **Thread-safe memory** updates

---

## Your Current Setup

### Current Configuration
- **Model**: Haiku (fast, efficient)
- **Thinking**: Extended thinking enabled
- **Context**: Full codebase access
- **Permissions**: Ask for bash, write, web

### Custom Commands Available

Your project has these custom slash commands configured:

| Command | Purpose |
|---------|---------|
| `/init` | Initialize CLAUDE.md with codebase documentation |
| `/pr-comments` | Fetch comments from GitHub pull requests |
| `/statusline` | Configure Claude Code's status line UI |
| `/review` | Review code changes |
| `/security-review` | Security analysis of pending changes |

### Quick Setup Steps

1. **Enable Vim mode** (if you prefer):
   ```
   /vim
   ```

2. **Configure multiline input**:
   ```
   /terminal-setup
   ```

3. **Access settings**:
   ```
   /config
   ```

4. **Create a custom command** in `.claude/commands/`:
   ```markdown
   ---
   description: "Your command purpose"
   allowed-tools: ["Edit", "Read"]
   ---

   Command instructions here
   ```

---

## Quick Reference

### Most Used Commands

```
Editing:           /review          /security-review    /memory
Navigation:        /config          /add-dir            /export
Undo/Redo:         /rewind          Ctrl+Z (if enabled)
Enhanced Input:    /vim             /terminal-setup     Backslash+Enter
Code Quality:      /security-review Hooks               PostToolUse
```

### Essential Keyboard Shortcuts

```
Interrupt:         Ctrl+C
Clear Screen:      Ctrl+L
Search History:    Ctrl+R
Quick Rewind:      Esc Esc
Extended Think:    Tab
Multiline:         Backslash+Enter (all platforms)
```

### File Reference Patterns

```
Single file:       @src/utils/auth.js
Directory:         @src/components
Glob pattern:      @**/*.ts
MCP resource:      @github:repos/owner/repo/issues
```

### Configuration Priority

```
1. Command-line arguments  (highest)
2. Managed settings
3. Project local settings
4. Project shared settings
5. User settings            (lowest)
```

---

## Tips & Tricks

### 1. Use Checkpointing for Safety
- Make risky changes and rewind if needed
- `/rewind` can restore to any previous state
- No need to manually save backups

### 2. Create Project-Specific Commands
- Store in `.claude/commands/` for team use
- Create custom workflows for your stack
- Parameterize with `$ARGUMENTS`

### 3. Optimize with Hooks
- Auto-format on edit = consistency
- Pre-write validation = bug prevention
- Post-edit tests = confidence

### 4. Use `@` for Context Management
- Reference files without loading them
- Save tokens for important context
- Keep conversations focused

### 5. Enable Extended Thinking
- Better for complex problems
- Worth the token cost
- Toggle with `Tab` in settings

### 6. Use Vim Mode for Power Editing
- Enables `/vim` for keyboard-driven editing
- Much faster once you know the bindings
- Excellent for refactoring

### 7. Set Up Security Permissions
- Exclude sensitive files in `.claude/settings.json`
- Use `PermissionRequest` hooks for safety
- Default to "ask" for critical operations

### 8. Custom Memory with `/memory`
- Store project architecture notes
- Keep styleguides and conventions
- Auto-injected into every conversation

---

## Troubleshooting

### Multiline Input Not Working
**Solution**: Run `/terminal-setup` and choose your preferred method

### Changes Not Saving
**Solution**: Ensure you have write permissions in settings. Use `/config` to verify.

### Hooks Not Executing
**Solution**: Check `.claude/hooks.json` syntax. Verify matcher patterns match your files.

### Rewind Not Available
**Solution**: Can only rewind changes made through Claude tools, not bash commands

### Model Errors
**Solution**: Check `/config` for model availability. May need to select `sonnet` or `opus` for complex tasks.

---

## Resources

- Official Claude Code Documentation: https://code.claude.com/docs
- Settings Reference: https://code.claude.com/docs/en/settings.md
- Hooks Guide: https://code.claude.com/docs/en/hooks.md
- Slash Commands: https://code.claude.com/docs/en/slash-commands.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md

---

**Document Version**: 1.0
**Last Updated**: December 5, 2025
**Claude Code Version**: Latest
