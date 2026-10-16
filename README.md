# whatchanged.vim

Edit alongside an AI coding agent (Claude Code, Codex, Aider…), a formatter, or `git checkout` without losing track of your files.

- **Live reload:** files changed on disk reload within a second, even while Vim isn't focused (say, while you're typing in the agent's pane). If you have unsaved changes, Vim asks instead of overwriting them. `u` undoes a reload.
- **`:WhatChanged`:** a side-by-side diff of the file before the first outside edit since **your** last change. Several outside edits in a row show up as one diff, so you review everything the agent did in one place.

```
┌ before: app.py ──────────┬ app.py ──────────────────┐
│ def load(path):          │ def load(path):          │
│-    return open(path)    │+    with open(path) as f:│
│                          │+        return f.read()  │
└──────────────────────────┴──────────────────────────┘
```

## Install

Requires Vim 8.2 or newer with `+timers` (developed and tested on Vim 9.2).

Vim's built-in packages:

```sh
git clone https://github.com/rpineda26/vim-whatchanged ~/.vim/pack/plugins/start/vim-whatchanged
vim -u NONE -c 'helptags ~/.vim/pack/plugins/start/vim-whatchanged/doc' -c q
```

[vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'rpineda26/vim-whatchanged'
```

Then map a key in your vimrc:

```vim
nmap <leader>D <Plug>(WhatChanged)
```

## Usage

1. Open a file and let the agent work. When it saves, the buffer reloads and a short message appears:
   `↻ app.py changed on disk · :WhatChanged shows what changed`
2. Run `:WhatChanged` (or your key). The file before the outside edits opens on the left, diffed against the current version on the right. `]c` / `[c` jump between changes; `q` closes the diff.
3. Keep editing. Your first edit sets a new baseline, so the next `:WhatChanged` shows only what changed after it.

## Commands and options

| | |
|---|---|
| `:WhatChanged` | diff against the snapshot (`q` closes it) |
| `:WhatChangedReset` | forget the snapshot (mark the changes as reviewed) |
| `<Plug>(WhatChanged)` | for your own mapping |
| `g:whatchanged_poll_ms` | check interval in ms, default `1000`; `0` = only on focus and buffer switch |
| `g:whatchanged_notify` | show the "↻ changed on disk" message, default `1` |
| `g:whatchanged_hl` | highlight group for that message, default `Comment` |

Full docs: `:help whatchanged`.

## How it works

The plugin handles Vim's `FileChangedShell` event. Before reloading an unmodified buffer, it saves the buffer's lines as a snapshot, unless one is already saved. Each buffer keeps its own snapshot, and it's cleared when you change the buffer yourself. Reloads are told apart from your own edits by the buffer's `changedtick`. A timer runs `:checktime` once a second, only in Normal mode, so it never interrupts a command line, insert, or prompt.

Because of this, the plugin sets `noautoread`. `autoread` reloads files without firing `FileChangedShell`, so the snapshot could never be taken. The plugin does the reloading instead, and you lose nothing.

## Limitations

- Snapshots live in memory, so they don't survive closing Vim.
- Neovim is untested.
- Deleted files and permission changes are left to Vim's own warning.

## License

MIT
