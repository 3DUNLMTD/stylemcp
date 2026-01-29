// StyleMCP Chrome Extension - Background Service Worker

const API_BASE = 'https://stylemcp.com/api';

// Create context menu on install
chrome.runtime.onInstalled.addListener(() => {
  // Validate selection menu item
  chrome.contextMenus.create({
    id: 'stylemcp-validate',
    title: 'Validate with StyleMCP',
    contexts: ['selection']
  });
  
  // Rewrite selection menu item
  chrome.contextMenus.create({
    id: 'stylemcp-rewrite',
    title: 'Fix with StyleMCP',
    contexts: ['selection']
  });
  
  console.log('StyleMCP context menus created');
});

// Handle context menu clicks
chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  const text = info.selectionText;
  
  if (!text || text.trim().length === 0) {
    return;
  }
  
  const { apiKey, selectedPack } = await chrome.storage.sync.get(['apiKey', 'selectedPack']);
  
  if (!apiKey) {
    // Open popup to prompt for API key
    chrome.action.openPopup();
    return;
  }
  
  const pack = selectedPack || 'saas';
  
  if (info.menuItemId === 'stylemcp-validate') {
    try {
      const response = await fetch(`${API_BASE}/validate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        },
        body: JSON.stringify({ text, pack })
      });
      
      const data = await response.json();
      
      // Show notification with result
      const score = data.score || 0;
      const violations = data.violations || [];
      
      let message;
      if (violations.length === 0) {
        message = `Score: ${score}/100\n✓ All clear!`;
      } else {
        message = `Score: ${score}/100\n${violations.length} issue${violations.length > 1 ? 's' : ''} found`;
        if (violations.length > 0) {
          message += `\n\nTop issue: "${violations[0].text}" - ${violations[0].message}`;
        }
      }
      
      chrome.notifications.create({
        type: 'basic',
        iconUrl: 'icons/icon128.png',
        title: 'StyleMCP Validation',
        message: message
      });
      
    } catch (error) {
      console.error('Validation failed:', error);
      chrome.notifications.create({
        type: 'basic',
        iconUrl: 'icons/icon128.png',
        title: 'StyleMCP',
        message: 'Validation failed. Please try again.'
      });
    }
  }
  
  if (info.menuItemId === 'stylemcp-rewrite') {
    try {
      const response = await fetch(`${API_BASE}/rewrite`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        },
        body: JSON.stringify({ text, pack, mode: 'normal' })
      });
      
      const data = await response.json();
      
      if (data.rewritten && data.rewritten !== text) {
        // Copy to clipboard
        await chrome.scripting.executeScript({
          target: { tabId: tab.id },
          func: (rewritten) => {
            navigator.clipboard.writeText(rewritten);
          },
          args: [data.rewritten]
        });
        
        const changes = data.changes || [];
        let message = `Fixed text copied to clipboard!\n\nScore: ${data.score?.before || 0} → ${data.score?.after || 100}`;
        if (changes.length > 0) {
          message += `\n\n${changes.length} change${changes.length > 1 ? 's' : ''} made`;
        }
        
        chrome.notifications.create({
          type: 'basic',
          iconUrl: 'icons/icon128.png',
          title: 'StyleMCP',
          message: message
        });
      } else {
        chrome.notifications.create({
          type: 'basic',
          iconUrl: 'icons/icon128.png',
          title: 'StyleMCP',
          message: 'No changes needed - text looks good!'
        });
      }
      
    } catch (error) {
      console.error('Rewrite failed:', error);
      chrome.notifications.create({
        type: 'basic',
        iconUrl: 'icons/icon128.png',
        title: 'StyleMCP',
        message: 'Rewrite failed. Please try again.'
      });
    }
  }
});

// Listen for messages from content scripts
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'validate') {
    validateText(request.text, request.pack).then(sendResponse);
    return true; // Keep channel open for async response
  }
  
  if (request.action === 'rewrite') {
    rewriteText(request.text, request.pack).then(sendResponse);
    return true;
  }
});

async function validateText(text, pack) {
  const { apiKey } = await chrome.storage.sync.get('apiKey');
  if (!apiKey) {
    return { error: 'No API key' };
  }
  
  try {
    const response = await fetch(`${API_BASE}/validate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({ text, pack: pack || 'saas' })
    });
    
    return await response.json();
  } catch (error) {
    return { error: error.message };
  }
}

async function rewriteText(text, pack) {
  const { apiKey } = await chrome.storage.sync.get('apiKey');
  if (!apiKey) {
    return { error: 'No API key' };
  }
  
  try {
    const response = await fetch(`${API_BASE}/rewrite`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({ text, pack: pack || 'saas', mode: 'normal' })
    });
    
    return await response.json();
  } catch (error) {
    return { error: error.message };
  }
}

console.log('StyleMCP service worker loaded');
