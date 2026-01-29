# StyleMCP Chrome Extension

Validate and fix AI-generated text to match your brand voice — directly in any text field.

## Features

- **Right-click to validate**: Select text, right-click, choose "Validate with StyleMCP"
- **One-click fixes**: Select text, right-click, choose "Fix with StyleMCP" - fixed text copied to clipboard
- **Popup quick actions**: Validate or fix selected text from the extension popup
- **8 industry packs**: SaaS, E-commerce, Healthcare, Finance, Legal, Real Estate, Education, Government
- **Auto-validate** (optional): Automatically validate selected text as you browse

## Installation

### From Chrome Web Store
*(Coming soon)*

### Developer Mode
1. Clone this repository
2. Open Chrome and go to `chrome://extensions/`
3. Enable "Developer mode" (toggle in top-right)
4. Click "Load unpacked"
5. Select the `extensions/chrome` folder

## Setup

1. Click the StyleMCP icon in your browser toolbar
2. Enter your API key (get one at [stylemcp.com](https://stylemcp.com))
3. Select your preferred style pack
4. Start validating!

## Usage

### Quick Validate
1. Select text on any webpage
2. Click the StyleMCP icon
3. Click "Validate Selection"
4. See your score and issues

### Quick Fix
1. Select text on any webpage
2. Click the StyleMCP icon
3. Click "Fix Selection"
4. Fixed text is copied to clipboard
5. Paste anywhere!

### Context Menu
1. Select text on any webpage
2. Right-click
3. Choose "Validate with StyleMCP" or "Fix with StyleMCP"

## Permissions

- **storage**: Save your API key and preferences
- **activeTab**: Access selected text on the current page
- **contextMenus**: Add right-click menu options

## Privacy

- Your API key is stored locally in Chrome sync storage
- Selected text is sent to StyleMCP API for validation only
- We don't store or log your content

## Development

```bash
# Structure
extensions/chrome/
├── manifest.json       # Extension manifest
├── popup/             # Popup UI
│   ├── popup.html
│   ├── popup.css
│   └── popup.js
├── content/           # Content scripts
│   ├── content.js
│   └── content.css
├── background/        # Service worker
│   └── service-worker.js
└── icons/            # Extension icons
    ├── icon16.png
    ├── icon48.png
    └── icon128.png
```

## Building for Production

1. Update version in `manifest.json`
2. Create icons in `icons/` folder
3. Zip the extension folder
4. Upload to Chrome Web Store

## License

MIT
