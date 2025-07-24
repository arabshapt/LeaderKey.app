# Homebrew Tap Setup for Leader Key Enhanced

## Repository Structure

Create a new GitHub repository named `homebrew-leader-key-enhanced` with this structure:

```
homebrew-leader-key-enhanced/
├── README.md
└── Casks/
    └── leader-key-enhanced.rb
```

## Steps to Set Up Your Tap

### 1. Create the Repository
- Go to GitHub and create a new repository
- Name: `homebrew-leader-key-enhanced`
- Make it public (required for Homebrew taps)
- Initialize with README

### 2. Create the Casks Directory
```bash
mkdir Casks
```

### 3. Add the Formula File
Copy the `leader-key-enhanced.rb` file from this directory to `Casks/leader-key-enhanced.rb`

### 4. Update the SHA256 Checksum
Download your app and generate the checksum:
```bash
# Download the file first, then:
shasum -a 256 /path/to/downloaded/Leader\ Key.app.zip
```
Replace `YOUR_SHA256_CHECKSUM_HERE` in the formula with the actual checksum.

### 5. Test the Installation
```bash
# Add your tap
brew tap arabshapt/leader-key-enhanced

# Install the cask
brew install --cask leader-key-enhanced
```

## Repository README Template

```markdown
# Leader Key Enhanced - Homebrew Tap

This tap provides the enhanced version of Leader Key with improved validation UX, overlay detection, and UI enhancements.

## Installation

```bash
brew tap arabshapt/leader-key-enhanced
brew install --cask leader-key-enhanced
```

## About

Enhanced fork of the original [Leader Key.app](https://github.com/mikker/LeaderKey.app) by [@mikker](https://github.com/mikker).

For more information, visit the [main repository](https://github.com/arabshapt/LeaderKey.app).
```

## Important Notes

- The repository MUST be named `homebrew-[something]` for Homebrew to recognize it as a tap
- The `Casks/` directory is required for cask formulas
- The formula filename must match the cask name
- Keep the repository public
- Always include SHA256 checksums for security