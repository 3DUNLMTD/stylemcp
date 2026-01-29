// StyleMCP Chrome Extension - Content Script

// Listen for messages from popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'getSelection') {
    const selection = window.getSelection();
    const text = selection ? selection.toString().trim() : '';
    sendResponse({ text });
    return true;
  }
  
  if (request.action === 'replaceSelection') {
    const selection = window.getSelection();
    if (selection && selection.rangeCount > 0) {
      const range = selection.getRangeAt(0);
      const activeElement = document.activeElement;
      
      // If in a text input or textarea
      if (activeElement && (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA')) {
        const start = activeElement.selectionStart;
        const end = activeElement.selectionEnd;
        const value = activeElement.value;
        activeElement.value = value.substring(0, start) + request.text + value.substring(end);
        activeElement.selectionStart = activeElement.selectionEnd = start + request.text.length;
        
        // Trigger input event for React/Vue/etc
        activeElement.dispatchEvent(new Event('input', { bubbles: true }));
      }
      // If in a contenteditable
      else if (activeElement && activeElement.isContentEditable) {
        document.execCommand('insertText', false, request.text);
      }
      // Regular selection
      else {
        range.deleteContents();
        range.insertNode(document.createTextNode(request.text));
      }
      
      sendResponse({ success: true });
    } else {
      sendResponse({ success: false, error: 'No selection' });
    }
    return true;
  }
});

// Floating validation indicator (optional enhancement)
let floatingIndicator = null;

function createFloatingIndicator() {
  if (floatingIndicator) return floatingIndicator;
  
  floatingIndicator = document.createElement('div');
  floatingIndicator.id = 'stylemcp-indicator';
  floatingIndicator.innerHTML = `
    <div class="stylemcp-indicator-content">
      <span class="stylemcp-logo">S</span>
      <span class="stylemcp-status">Checking...</span>
    </div>
  `;
  document.body.appendChild(floatingIndicator);
  
  return floatingIndicator;
}

function showIndicator(x, y, status, score) {
  const indicator = createFloatingIndicator();
  indicator.style.left = `${x}px`;
  indicator.style.top = `${y}px`;
  indicator.style.display = 'block';
  
  const statusEl = indicator.querySelector('.stylemcp-status');
  if (status === 'loading') {
    statusEl.textContent = 'Checking...';
    indicator.className = 'loading';
  } else if (status === 'good') {
    statusEl.textContent = `${score}/100 ✓`;
    indicator.className = 'good';
  } else if (status === 'warning') {
    statusEl.textContent = `${score}/100`;
    indicator.className = 'warning';
  } else {
    statusEl.textContent = `${score}/100 ✗`;
    indicator.className = 'bad';
  }
}

function hideIndicator() {
  if (floatingIndicator) {
    floatingIndicator.style.display = 'none';
  }
}

// Auto-validate on selection (optional - can be enabled via settings)
let selectionTimeout = null;

document.addEventListener('selectionchange', () => {
  if (selectionTimeout) {
    clearTimeout(selectionTimeout);
  }
  
  // Debounce selection validation
  selectionTimeout = setTimeout(async () => {
    const selection = window.getSelection();
    const text = selection ? selection.toString().trim() : '';
    
    if (text.length < 20) {
      hideIndicator();
      return;
    }
    
    // Check if auto-validate is enabled
    const { autoValidate } = await chrome.storage.sync.get('autoValidate');
    if (!autoValidate) return;
    
    // Get selection position for indicator
    if (selection.rangeCount > 0) {
      const range = selection.getRangeAt(0);
      const rect = range.getBoundingClientRect();
      
      showIndicator(
        rect.right + window.scrollX + 10,
        rect.top + window.scrollY,
        'loading'
      );
      
      // Validate
      try {
        const { apiKey, selectedPack } = await chrome.storage.sync.get(['apiKey', 'selectedPack']);
        if (!apiKey) {
          hideIndicator();
          return;
        }
        
        const response = await fetch('https://stylemcp.com/api/validate', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${apiKey}`
          },
          body: JSON.stringify({ text, pack: selectedPack || 'saas' })
        });
        
        const data = await response.json();
        const score = data.score || 0;
        const status = score >= 80 ? 'good' : score >= 50 ? 'warning' : 'bad';
        
        showIndicator(
          rect.right + window.scrollX + 10,
          rect.top + window.scrollY,
          status,
          score
        );
        
        // Hide after 3 seconds
        setTimeout(hideIndicator, 3000);
      } catch (error) {
        hideIndicator();
      }
    }
  }, 500);
});

// Hide indicator on click elsewhere
document.addEventListener('click', (e) => {
  if (floatingIndicator && !floatingIndicator.contains(e.target)) {
    hideIndicator();
  }
});

console.log('StyleMCP content script loaded');
