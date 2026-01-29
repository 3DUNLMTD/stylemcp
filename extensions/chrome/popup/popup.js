// StyleMCP Chrome Extension - Popup Script

const API_BASE = 'https://stylemcp.com/api';

// DOM Elements
const setupSection = document.getElementById('setupSection');
const mainSection = document.getElementById('mainSection');
const apiKeyInput = document.getElementById('apiKeyInput');
const saveApiKeyBtn = document.getElementById('saveApiKey');
const clearApiKeyBtn = document.getElementById('clearApiKey');
const packSelect = document.getElementById('packSelect');
const validateBtn = document.getElementById('validateSelection');
const rewriteBtn = document.getElementById('rewriteSelection');
const lastResult = document.getElementById('lastResult');
const resultScore = document.getElementById('resultScore');
const resultCount = document.getElementById('resultCount');
const resultViolations = document.getElementById('resultViolations');

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
  const { apiKey, selectedPack } = await chrome.storage.sync.get(['apiKey', 'selectedPack']);
  
  if (apiKey) {
    showMainSection();
    if (selectedPack) {
      packSelect.value = selectedPack;
    }
  } else {
    showSetupSection();
  }
});

// Show/hide sections
function showSetupSection() {
  setupSection.style.display = 'block';
  mainSection.style.display = 'none';
}

function showMainSection() {
  setupSection.style.display = 'none';
  mainSection.style.display = 'block';
}

// Save API key
saveApiKeyBtn.addEventListener('click', async () => {
  const apiKey = apiKeyInput.value.trim();
  if (!apiKey) {
    alert('Please enter an API key');
    return;
  }
  
  // Validate the key works
  try {
    const response = await fetch(`${API_BASE}/packs`, {
      headers: { 'Authorization': `Bearer ${apiKey}` }
    });
    
    if (!response.ok) {
      throw new Error('Invalid API key');
    }
    
    await chrome.storage.sync.set({ apiKey });
    showMainSection();
  } catch (error) {
    alert('Invalid API key. Please check and try again.');
  }
});

// Clear API key
clearApiKeyBtn.addEventListener('click', async () => {
  await chrome.storage.sync.remove('apiKey');
  apiKeyInput.value = '';
  showSetupSection();
});

// Save pack selection
packSelect.addEventListener('change', async () => {
  await chrome.storage.sync.set({ selectedPack: packSelect.value });
});

// Validate selection
validateBtn.addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  chrome.tabs.sendMessage(tab.id, { action: 'getSelection' }, async (response) => {
    if (chrome.runtime.lastError || !response?.text) {
      alert('Please select some text first');
      return;
    }
    
    const text = response.text;
    const pack = packSelect.value;
    
    validateBtn.disabled = true;
    validateBtn.textContent = 'Validating...';
    
    try {
      const { apiKey } = await chrome.storage.sync.get('apiKey');
      const result = await fetch(`${API_BASE}/validate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        },
        body: JSON.stringify({ text, pack })
      });
      
      const data = await result.json();
      displayResult(data);
    } catch (error) {
      alert('Validation failed. Please try again.');
    } finally {
      validateBtn.disabled = false;
      validateBtn.innerHTML = '<span class="btn-icon">✓</span> Validate Selection';
    }
  });
});

// Rewrite selection
rewriteBtn.addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  chrome.tabs.sendMessage(tab.id, { action: 'getSelection' }, async (response) => {
    if (chrome.runtime.lastError || !response?.text) {
      alert('Please select some text first');
      return;
    }
    
    const text = response.text;
    const pack = packSelect.value;
    
    rewriteBtn.disabled = true;
    rewriteBtn.textContent = 'Fixing...';
    
    try {
      const { apiKey } = await chrome.storage.sync.get('apiKey');
      const result = await fetch(`${API_BASE}/rewrite`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        },
        body: JSON.stringify({ text, pack, mode: 'normal' })
      });
      
      const data = await result.json();
      
      if (data.rewritten && data.rewritten !== text) {
        // Copy to clipboard
        await navigator.clipboard.writeText(data.rewritten);
        
        // Show result
        displayResult({
          score: data.score?.after || 100,
          violations: [],
          rewritten: data.rewritten
        });
        
        alert('Fixed text copied to clipboard!');
      } else {
        alert('No changes needed - text looks good!');
      }
    } catch (error) {
      alert('Rewrite failed. Please try again.');
    } finally {
      rewriteBtn.disabled = false;
      rewriteBtn.innerHTML = '<span class="btn-icon">✎</span> Fix Selection';
    }
  });
});

// Display result
function displayResult(data) {
  lastResult.style.display = 'block';
  
  const score = data.score || 0;
  resultScore.textContent = `${score}/100`;
  resultScore.className = 'result-score ' + (score >= 80 ? 'good' : score >= 50 ? 'warning' : 'bad');
  
  const violations = data.violations || [];
  resultCount.textContent = `${violations.length} issue${violations.length !== 1 ? 's' : ''}`;
  
  if (violations.length === 0) {
    resultViolations.innerHTML = '<div style="color: #4caf50; text-align: center; padding: 8px;">✓ All clear!</div>';
  } else {
    resultViolations.innerHTML = violations.slice(0, 5).map(v => `
      <div class="violation-item">
        <div class="violation-text">"${escapeHtml(v.text)}"</div>
        <div class="violation-message">${escapeHtml(v.message)}</div>
      </div>
    `).join('');
    
    if (violations.length > 5) {
      resultViolations.innerHTML += `<div style="text-align: center; color: #888; font-size: 12px; padding-top: 8px;">+ ${violations.length - 5} more</div>`;
    }
  }
}

// Escape HTML
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text || '';
  return div.innerHTML;
}
