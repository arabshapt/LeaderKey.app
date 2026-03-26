# Future Plans

## Bidirectional Config Converter
- Import existing goku EDN configs into Leader Key's JSON format
- Import existing kar TypeScript configs into Leader Key's JSON format
- Currently only export (Leader Key JSON → goku/kar) is supported

## Search Keymaps (Discoverability)
- Fuzzy search within the WhichKey hint overlay — user types to filter shortcuts
- Dedicated searchable list in the configurator/settings UI
- Similar to LazyVim's `leader->s->k` (Search Keymaps)

## Extract CLI Tools
- Extract "macro" action into a standalone CLI tool
- Other actions that make sense as standalone tools

## leaderkey-cli Evaluation
- Evaluate what leaderkey-cli does beyond transport
- If send_user_command fully replaces it, consider removing the binary
