#!/bin/bash
# StyleMCP Site Update - Adds docs page and updates landing page
set -e

echo "Updating StyleMCP site..."

# Create docs page
cat > /var/www/stylemcp/docs.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Documentation - StyleMCP</title>
  <meta name="description" content="Learn how to use StyleMCP to validate and rewrite AI-generated content.">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <style>
    *{margin:0;padding:0;box-sizing:border-box}:root{--bg:#0a0a0b;--bg-elevated:#141416;--bg-card:#1a1a1e;--border:#2a2a2e;--text:#fafafa;--text-muted:#a1a1aa;--accent:#6366f1;--accent-hover:#818cf8;--green:#22c55e;--yellow:#eab308}body{font-family:'Inter',-apple-system,sans-serif;background:var(--bg);color:var(--text);line-height:1.7;-webkit-font-smoothing:antialiased}.layout{display:flex;min-height:100vh}.sidebar{width:280px;background:var(--bg-elevated);border-right:1px solid var(--border);padding:24px;position:fixed;height:100vh;overflow-y:auto}.sidebar-logo{font-weight:700;font-size:1.25rem;color:var(--text);text-decoration:none;display:flex;align-items:center;gap:8px;margin-bottom:32px}.logo-icon{width:32px;height:32px;background:linear-gradient(135deg,var(--accent) 0%,#a855f7 100%);border-radius:8px;display:flex;align-items:center;justify-content:center}.nav-section{margin-bottom:24px}.nav-section-title{font-size:0.75rem;font-weight:600;text-transform:uppercase;letter-spacing:0.05em;color:var(--text-muted);margin-bottom:12px}.nav-link{display:block;padding:8px 12px;color:var(--text-muted);text-decoration:none;font-size:0.9rem;border-radius:6px;margin-bottom:2px;transition:all 0.2s}.nav-link:hover{background:var(--bg-card);color:var(--text)}.nav-link.active{background:var(--accent);color:white}.main{flex:1;margin-left:280px;padding:48px 64px;max-width:900px}h1{font-size:2.5rem;font-weight:700;margin-bottom:16px}h2{font-size:1.75rem;font-weight:600;margin-top:48px;margin-bottom:16px;padding-top:24px;border-top:1px solid var(--border)}h3{font-size:1.25rem;font-weight:600;margin-top:32px;margin-bottom:12px}p{color:var(--text-muted);margin-bottom:16px}p code,li code,td code{background:var(--bg-card);padding:2px 6px;border-radius:4px;font-family:'JetBrains Mono',monospace;font-size:0.85em;color:var(--text)}.lead{font-size:1.2rem;color:var(--text);margin-bottom:32px}ul,ol{color:var(--text-muted);margin-bottom:16px;padding-left:24px}li{margin-bottom:8px}a{color:var(--accent)}a:hover{color:var(--accent-hover)}.code-block{background:var(--bg-card);border:1px solid var(--border);border-radius:12px;margin:24px 0;overflow:hidden}.code-header{display:flex;justify-content:space-between;padding:12px 16px;background:var(--bg-elevated);border-bottom:1px solid var(--border);font-size:0.85rem;color:var(--text-muted)}.code-body{padding:16px;font-family:'JetBrains Mono',monospace;font-size:0.85rem;overflow-x:auto;line-height:1.6}.code-body .comment{color:#6b7280}.code-body .string{color:#22c55e}.code-body .key{color:#a855f7}.code-body .number{color:#f59e0b}.code-body .boolean{color:#3b82f6}.endpoint{display:inline-flex;align-items:center;gap:8px;padding:4px 12px;background:var(--bg-card);border:1px solid var(--border);border-radius:6px;font-family:'JetBrains Mono',monospace;font-size:0.85rem;margin:4px 0}.method{padding:2px 6px;border-radius:4px;font-weight:600;font-size:0.75rem}.method.get{background:rgba(34,197,94,0.2);color:var(--green)}.method.post{background:rgba(99,102,241,0.2);color:var(--accent)}.callout{padding:16px 20px;border-radius:8px;margin:24px 0;border-left:4px solid}.callout.info{background:rgba(99,102,241,0.1);border-color:var(--accent)}.callout.success{background:rgba(34,197,94,0.1);border-color:var(--green)}.callout p{margin:0;color:var(--text)}.table-wrapper{overflow-x:auto;margin:24px 0}table{width:100%;border-collapse:collapse}th,td{padding:12px 16px;text-align:left;border-bottom:1px solid var(--border)}th{font-weight:600;color:var(--text);background:var(--bg-elevated)}td{color:var(--text-muted)}@media(max-width:900px){.sidebar{display:none}.main{margin-left:0;padding:24px}}
  </style>
</head>
<body>
  <div class="layout">
    <nav class="sidebar">
      <a href="/" class="sidebar-logo"><div class="logo-icon">S</div>StyleMCP</a>
      <div class="nav-section">
        <div class="nav-section-title">Getting Started</div>
        <a href="#introduction" class="nav-link active">Introduction</a>
        <a href="#quick-start" class="nav-link">Quick Start</a>
        <a href="#authentication" class="nav-link">Authentication</a>
      </div>
      <div class="nav-section">
        <div class="nav-section-title">API Reference</div>
        <a href="#validate" class="nav-link">Validate Text</a>
        <a href="#rewrite" class="nav-link">Rewrite Text</a>
        <a href="#batch" class="nav-link">Batch Validation</a>
        <a href="#packs" class="nav-link">Style Packs</a>
      </div>
      <div class="nav-section">
        <div class="nav-section-title">Integrations</div>
        <a href="#mcp" class="nav-link">MCP (Claude)</a>
        <a href="#github-actions" class="nav-link">GitHub Actions</a>
        <a href="#cli" class="nav-link">CLI</a>
      </div>
      <div class="nav-section">
        <div class="nav-section-title">Style Packs</div>
        <a href="#pack-structure" class="nav-link">Pack Structure</a>
        <a href="#custom-packs" class="nav-link">Custom Packs</a>
      </div>
    </nav>
    <main class="main">
      <h1 id="introduction">Documentation</h1>
      <p class="lead">StyleMCP validates and rewrites AI-generated text to match your brand voice. Use it via REST API, MCP, or CLI.</p>
      <div class="callout info"><p><strong>Base URL:</strong> <code>https://stylemcp.com</code></p></div>

      <h2 id="quick-start">Quick Start</h2>
      <p>Validate text against brand rules with a single API call:</p>
      <div class="code-block"><div class="code-header"><span>cURL</span></div><div class="code-body"><pre>curl -X POST https://stylemcp.com/api/validate \
  -H "Content-Type: application/json" \
  -d '{"text": "Click here to learn more!"}'</pre></div></div>
      <p>Response:</p>
      <div class="code-block"><div class="code-header"><span>JSON</span></div><div class="code-body"><pre>{
  <span class="key">"valid"</span>: <span class="boolean">false</span>,
  <span class="key">"score"</span>: <span class="number">65</span>,
  <span class="key">"issues"</span>: [{
    <span class="key">"rule"</span>: <span class="string">"no-click-here"</span>,
    <span class="key">"message"</span>: <span class="string">"Avoid 'click here'"</span>,
    <span class="key">"suggestion"</span>: <span class="string">"Learn more about features"</span>
  }]
}</pre></div></div>

      <h2 id="authentication">Authentication</h2>
      <p>If API key authentication is enabled, include your key in the <code>X-Api-Key</code> header:</p>
      <div class="code-block"><div class="code-header"><span>cURL</span></div><div class="code-body"><pre>curl -X POST https://stylemcp.com/api/validate \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: your-api-key" \
  -d '{"text": "Your text here"}'</pre></div></div>

      <h2 id="validate">Validate Text</h2>
      <p class="endpoint"><span class="method post">POST</span> /api/validate</p>
      <h3>Request Body</h3>
      <div class="table-wrapper"><table><thead><tr><th>Field</th><th>Type</th><th>Description</th></tr></thead><tbody><tr><td><code>text</code></td><td>string</td><td><strong>Required.</strong> Text to validate</td></tr><tr><td><code>pack</code></td><td>string</td><td>Style pack (default: "saas")</td></tr><tr><td><code>context</code></td><td>object</td><td>Additional context</td></tr></tbody></table></div>
      <h3>Response</h3>
      <div class="table-wrapper"><table><thead><tr><th>Field</th><th>Type</th><th>Description</th></tr></thead><tbody><tr><td><code>valid</code></td><td>boolean</td><td>Whether text passes all rules</td></tr><tr><td><code>score</code></td><td>number</td><td>Quality score (0-100)</td></tr><tr><td><code>issues</code></td><td>array</td><td>List of rule violations</td></tr></tbody></table></div>

      <h2 id="rewrite">Rewrite Text</h2>
      <p class="endpoint"><span class="method post">POST</span> /api/rewrite</p>
      <div class="code-block"><div class="code-header"><span>cURL</span></div><div class="code-body"><pre>curl -X POST https://stylemcp.com/api/rewrite \
  -H "Content-Type: application/json" \
  -d '{"text": "Please click here to utilize our product!", "mode": "normal"}'</pre></div></div>
      <h3>Rewrite Modes</h3>
      <div class="table-wrapper"><table><thead><tr><th>Mode</th><th>Description</th></tr></thead><tbody><tr><td><code>minimal</code></td><td>Only fix rule violations</td></tr><tr><td><code>normal</code></td><td>Fix violations + improve clarity</td></tr><tr><td><code>aggressive</code></td><td>Complete rewrite in brand voice</td></tr></tbody></table></div>

      <h2 id="batch">Batch Validation</h2>
      <p class="endpoint"><span class="method post">POST</span> /api/validate/batch</p>
      <div class="code-block"><div class="code-header"><span>cURL</span></div><div class="code-body"><pre>curl -X POST https://stylemcp.com/api/validate/batch \
  -H "Content-Type: application/json" \
  -d '{"items": [
    {"id": "headline", "text": "Revolutionary AI Solution!"},
    {"id": "cta", "text": "Click here to get started"}
  ]}'</pre></div></div>

      <h2 id="packs">Style Packs</h2>
      <p class="endpoint"><span class="method get">GET</span> /api/packs</p>
      <p class="endpoint"><span class="method get">GET</span> /api/packs/{pack}/voice</p>
      <p class="endpoint"><span class="method get">GET</span> /api/packs/{pack}/ctas</p>

      <h2 id="mcp">MCP Integration</h2>
      <p>StyleMCP supports the Model Context Protocol for direct integration with Claude.</p>
      <h3>Claude Desktop Config</h3>
      <div class="code-block"><div class="code-header"><span>claude_desktop_config.json</span></div><div class="code-body"><pre>{
  <span class="key">"mcpServers"</span>: {
    <span class="key">"stylemcp"</span>: {
      <span class="key">"command"</span>: <span class="string">"npx"</span>,
      <span class="key">"args"</span>: [<span class="string">"stylemcp"</span>]
    }
  }
}</pre></div></div>
      <h3>Available Tools</h3>
      <ul>
        <li><code>validate_text</code> - Validate text against brand rules</li>
        <li><code>rewrite_to_style</code> - Rewrite text to match brand voice</li>
        <li><code>get_voice_rules</code> - Get voice guidelines</li>
        <li><code>get_cta_rules</code> - Get CTA guidelines</li>
        <li><code>list_packs</code> - List available style packs</li>
      </ul>

      <h2 id="github-actions">GitHub Actions</h2>
      <div class="code-block"><div class="code-header"><span>.github/workflows/brand-check.yml</span></div><div class="code-body"><pre>name: Brand Check
on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check copy
        run: npx stylemcp validate src/copy/*.json --min-score 80</pre></div></div>

      <h2 id="cli">CLI</h2>
      <div class="code-block"><div class="code-header"><span>Terminal</span></div><div class="code-body"><pre><span class="comment"># Install</span>
npm install -g stylemcp

<span class="comment"># Validate text</span>
stylemcp validate "Click here to learn more"

<span class="comment"># Rewrite text</span>
stylemcp rewrite "Please utilize our product" --mode aggressive</pre></div></div>

      <h2 id="pack-structure">Pack Structure</h2>
      <div class="code-block"><div class="code-header"><span>Directory</span></div><div class="code-body"><pre>packs/my-brand/
  manifest.yaml      <span class="comment"># Pack metadata</span>
  voice.yaml         <span class="comment"># Tone, vocabulary, forbidden words</span>
  copy_patterns.yaml <span class="comment"># Reusable copy templates</span>
  cta_rules.yaml     <span class="comment"># Button/CTA guidelines</span></pre></div></div>

      <h2 id="custom-packs">Custom Packs</h2>
      <ol>
        <li>Copy the default pack: <code>cp -r packs/saas packs/my-brand</code></li>
        <li>Edit the YAML files to match your brand</li>
        <li>Use via API: <code>{"pack": "my-brand"}</code></li>
      </ol>
      <div class="callout success"><p><strong>Tip:</strong> Start with the <code>saas</code> pack and modify it.</p></div>
    </main>
  </div>
</body>
</html>
HTMLEOF

# Update index.html with docs link
cat > /var/www/stylemcp/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>StyleMCP - Brand Rules for AI</title>
  <meta name="description" content="Executable brand rules for AI models and agents. Keep every AI output on-brand with StyleMCP.">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <style>
    *{margin:0;padding:0;box-sizing:border-box}:root{--bg:#0a0a0b;--bg-elevated:#141416;--bg-card:#1a1a1e;--border:#2a2a2e;--text:#fafafa;--text-muted:#a1a1aa;--accent:#6366f1;--accent-hover:#818cf8;--green:#22c55e;--red:#ef4444;--yellow:#eab308}body{font-family:'Inter',-apple-system,BlinkMacSystemFont,sans-serif;background:var(--bg);color:var(--text);line-height:1.6;-webkit-font-smoothing:antialiased}.container{max-width:1200px;margin:0 auto;padding:0 24px}nav{position:fixed;top:0;left:0;right:0;background:rgba(10,10,11,0.8);backdrop-filter:blur(12px);border-bottom:1px solid var(--border);z-index:100}nav .container{display:flex;align-items:center;justify-content:space-between;height:64px}.logo{font-weight:700;font-size:1.25rem;color:var(--text);text-decoration:none;display:flex;align-items:center;gap:8px}.logo-icon{width:32px;height:32px;background:linear-gradient(135deg,var(--accent) 0%,#a855f7 100%);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:16px}.nav-links{display:flex;align-items:center;gap:32px}.nav-links a{color:var(--text-muted);text-decoration:none;font-size:0.9rem;font-weight:500;transition:color 0.2s}.nav-links a:hover{color:var(--text)}.btn{display:inline-flex;align-items:center;gap:8px;padding:10px 20px;border-radius:8px;font-weight:500;font-size:0.9rem;text-decoration:none;transition:all 0.2s;cursor:pointer;border:none}.btn-primary{background:var(--accent);color:white}.btn-primary:hover{background:var(--accent-hover)}.btn-secondary{background:var(--bg-card);color:var(--text);border:1px solid var(--border)}.btn-secondary:hover{background:var(--bg-elevated);border-color:var(--text-muted)}.hero{padding:160px 0 100px;text-align:center}.badge{display:inline-flex;align-items:center;gap:8px;padding:6px 14px;background:var(--bg-card);border:1px solid var(--border);border-radius:50px;font-size:0.85rem;color:var(--text-muted);margin-bottom:24px}.badge-dot{width:6px;height:6px;background:var(--green);border-radius:50%}h1{font-size:clamp(2.5rem,6vw,4rem);font-weight:700;line-height:1.1;margin-bottom:24px;letter-spacing:-0.02em}.gradient-text{background:linear-gradient(135deg,var(--accent) 0%,#a855f7 50%,#ec4899 100%);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}.hero p{font-size:1.25rem;color:var(--text-muted);max-width:600px;margin:0 auto 40px}.hero-buttons{display:flex;gap:16px;justify-content:center;flex-wrap:wrap}.demo{margin-top:80px;background:var(--bg-card);border:1px solid var(--border);border-radius:16px;overflow:hidden}.demo-header{display:flex;align-items:center;gap:8px;padding:12px 16px;background:var(--bg-elevated);border-bottom:1px solid var(--border)}.demo-dot{width:12px;height:12px;border-radius:50%}.demo-dot.red{background:#ff5f57}.demo-dot.yellow{background:#febc2e}.demo-dot.green{background:#28c840}.demo-content{padding:24px;font-family:'JetBrains Mono',monospace;font-size:0.9rem;overflow-x:auto}.demo-line{display:flex;margin-bottom:8px}.demo-prompt{color:var(--accent);margin-right:8px}.demo-command{color:var(--text-muted)}.demo-response{color:var(--text);padding-left:20px}.demo-valid{color:var(--green)}.demo-warning{color:var(--yellow)}.features{padding:120px 0}.section-title{text-align:center;margin-bottom:60px}.section-title h2{font-size:2.5rem;font-weight:700;margin-bottom:16px}.section-title p{color:var(--text-muted);font-size:1.1rem;max-width:500px;margin:0 auto}.features-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:24px}.feature-card{background:var(--bg-card);border:1px solid var(--border);border-radius:16px;padding:32px;transition:border-color 0.2s}.feature-card:hover{border-color:var(--text-muted)}.feature-icon{width:48px;height:48px;background:linear-gradient(135deg,var(--accent) 0%,#a855f7 100%);border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:24px;margin-bottom:20px}.feature-card h3{font-size:1.25rem;font-weight:600;margin-bottom:12px}.feature-card p{color:var(--text-muted);font-size:0.95rem}.how-it-works{padding:120px 0;background:var(--bg-elevated)}.steps{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:40px;margin-top:60px}.step{text-align:center}.step-number{width:56px;height:56px;background:var(--bg-card);border:2px solid var(--accent);border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:1.5rem;font-weight:700;color:var(--accent);margin:0 auto 20px}.step h3{font-size:1.25rem;margin-bottom:12px}.step p{color:var(--text-muted);font-size:0.95rem}.examples{padding:120px 0}.example-grid{display:grid;grid-template-columns:1fr 1fr;gap:24px;margin-top:40px}@media(max-width:768px){.example-grid{grid-template-columns:1fr}}.example-card{background:var(--bg-card);border:1px solid var(--border);border-radius:12px;padding:24px}.example-card.bad{border-left:3px solid var(--red)}.example-card.good{border-left:3px solid var(--green)}.example-label{font-size:0.75rem;font-weight:600;text-transform:uppercase;letter-spacing:0.05em;margin-bottom:12px}.example-card.bad .example-label{color:var(--red)}.example-card.good .example-label{color:var(--green)}.example-text{font-size:1.1rem;margin-bottom:12px}.example-reason{color:var(--text-muted);font-size:0.9rem}.api-section{padding:120px 0}.api-grid{display:grid;grid-template-columns:1fr 1fr;gap:60px;align-items:center}@media(max-width:768px){.api-grid{grid-template-columns:1fr}}.api-content h2{font-size:2.5rem;margin-bottom:24px}.api-content p{color:var(--text-muted);margin-bottom:32px;font-size:1.1rem}.api-endpoints{display:flex;flex-direction:column;gap:12px}.endpoint{display:flex;align-items:center;gap:12px;padding:12px 16px;background:var(--bg-card);border:1px solid var(--border);border-radius:8px;font-family:'JetBrains Mono',monospace;font-size:0.85rem}.endpoint-method{padding:4px 8px;border-radius:4px;font-weight:600;font-size:0.75rem}.endpoint-method.get{background:rgba(34,197,94,0.2);color:var(--green)}.endpoint-method.post{background:rgba(99,102,241,0.2);color:var(--accent)}.code-block{background:var(--bg-card);border:1px solid var(--border);border-radius:12px;overflow:hidden}.code-header{padding:12px 16px;background:var(--bg-elevated);border-bottom:1px solid var(--border);font-size:0.85rem;color:var(--text-muted)}.code-body{padding:20px;font-family:'JetBrains Mono',monospace;font-size:0.85rem;overflow-x:auto}.code-body .key{color:#a855f7}.code-body .string{color:#22c55e}.code-body .number{color:#f59e0b}.code-body .boolean{color:#3b82f6}.cta{padding:120px 0;text-align:center}.cta-box{background:linear-gradient(135deg,rgba(99,102,241,0.1) 0%,rgba(168,85,247,0.1) 100%);border:1px solid var(--border);border-radius:24px;padding:80px 40px}.cta h2{font-size:2.5rem;margin-bottom:16px}.cta p{color:var(--text-muted);font-size:1.1rem;margin-bottom:40px;max-width:500px;margin-left:auto;margin-right:auto}footer{padding:60px 0;border-top:1px solid var(--border)}.footer-content{display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:24px}.footer-links{display:flex;gap:32px}.footer-links a{color:var(--text-muted);text-decoration:none;font-size:0.9rem;transition:color 0.2s}.footer-links a:hover{color:var(--text)}.footer-copy{color:var(--text-muted);font-size:0.9rem}@media(max-width:640px){.nav-links{display:none}.hero{padding:120px 0 60px}.hero-buttons{flex-direction:column;align-items:center}.features,.how-it-works,.api-section,.cta,.examples{padding:80px 0}}
  </style>
</head>
<body>
  <nav>
    <div class="container">
      <a href="/" class="logo"><div class="logo-icon">S</div>StyleMCP</a>
      <div class="nav-links">
        <a href="#features">Features</a>
        <a href="#examples">Examples</a>
        <a href="/docs.html">Docs</a>
        <a href="/docs.html" class="btn btn-primary">Get Started</a>
      </div>
    </div>
  </nav>

  <section class="hero">
    <div class="container">
      <div class="badge"><span class="badge-dot"></span>MCP Compatible</div>
      <h1>Brand rules for <span class="gradient-text">AI outputs</span></h1>
      <p>Keep every AI-generated message on-brand. Validate, rewrite, and enforce your style guide across all your AI agents and models.</p>
      <div class="hero-buttons">
        <a href="/docs.html" class="btn btn-primary">Read the Docs</a>
        <a href="/health" class="btn btn-secondary">Check API Status</a>
      </div>
      <div class="demo">
        <div class="demo-header"><span class="demo-dot red"></span><span class="demo-dot yellow"></span><span class="demo-dot green"></span></div>
        <div class="demo-content">
          <div class="demo-line"><span class="demo-prompt">$</span><span class="demo-command">curl -X POST https://stylemcp.com/api/validate \</span></div>
          <div class="demo-line"><span class="demo-response">-d '{"text": "Click here to learn more!"}'</span></div>
          <div class="demo-line" style="margin-top:16px"><span class="demo-response">{</span></div>
          <div class="demo-line"><span class="demo-response">  "valid": <span class="demo-warning">false</span>, "score": 65,</span></div>
          <div class="demo-line"><span class="demo-response">  "issues": [{ "rule": "no-click-here" }],</span></div>
          <div class="demo-line"><span class="demo-response">  "suggestion": "Learn more about our features"</span></div>
          <div class="demo-line"><span class="demo-response">}</span></div>
        </div>
      </div>
    </div>
  </section>

  <section class="features" id="features">
    <div class="container">
      <div class="section-title"><h2>Everything you need</h2><p>A complete toolkit for enforcing brand consistency across AI outputs</p></div>
      <div class="features-grid">
        <div class="feature-card"><div class="feature-icon">&#10003;</div><h3>Real-time Validation</h3><p>Instantly validate AI-generated text against your brand rules. Get scores, issues, and actionable feedback.</p></div>
        <div class="feature-card"><div class="feature-icon">&#9998;</div><h3>Auto-Rewriting</h3><p>Automatically rewrite off-brand content to match your voice. Choose minimal, normal, or aggressive modes.</p></div>
        <div class="feature-card"><div class="feature-icon">&#9881;</div><h3>Style Packs</h3><p>Modular rule packs for different use cases. Voice, copy patterns, CTAs, and design tokens all in one place.</p></div>
        <div class="feature-card"><div class="feature-icon">&#128279;</div><h3>MCP Integration</h3><p>Native Model Context Protocol support. Connect directly to Claude, GPT, and other AI agents.</p></div>
        <div class="feature-card"><div class="feature-icon">&#128640;</div><h3>REST API</h3><p>Simple HTTP API for any integration. Validate single texts or batch process thousands of items.</p></div>
        <div class="feature-card"><div class="feature-icon">&#128736;</div><h3>GitHub Actions</h3><p>Run brand checks in CI/CD. Catch off-brand copy before it reaches production.</p></div>
      </div>
    </div>
  </section>

  <section class="examples" id="examples">
    <div class="container">
      <div class="section-title"><h2>What it catches</h2><p>Common copy mistakes that StyleMCP automatically flags</p></div>
      <div class="example-grid">
        <div class="example-card bad"><div class="example-label">Avoid</div><div class="example-text">"Click here to learn more"</div><div class="example-reason">Poor accessibility. Describe the destination instead.</div></div>
        <div class="example-card good"><div class="example-label">Better</div><div class="example-text">"Read the migration guide"</div><div class="example-reason">Clear, accessible, tells users what they'll find.</div></div>
        <div class="example-card bad"><div class="example-label">Avoid</div><div class="example-text">"We leverage cutting-edge technology"</div><div class="example-reason">Jargon that says nothing. Be specific.</div></div>
        <div class="example-card good"><div class="example-label">Better</div><div class="example-text">"Queries return in under 100ms"</div><div class="example-reason">Concrete claim that proves the benefit.</div></div>
        <div class="example-card bad"><div class="example-label">Avoid</div><div class="example-text">"We're sorry for any inconvenience"</div><div class="example-reason">Corporate non-apology. Be specific about the issue.</div></div>
        <div class="example-card good"><div class="example-label">Better</div><div class="example-text">"Your export failed. We're increasing the limit to 500MB."</div><div class="example-reason">Acknowledges the problem and states the fix.</div></div>
        <div class="example-card bad"><div class="example-label">Avoid</div><div class="example-text">"Simply configure your settings"</div><div class="example-reason">"Simply" can make users feel dumb if it's not simple to them.</div></div>
        <div class="example-card good"><div class="example-label">Better</div><div class="example-text">"Go to Settings > Notifications"</div><div class="example-reason">Specific guidance without assumptions.</div></div>
      </div>
    </div>
  </section>

  <section class="how-it-works">
    <div class="container">
      <div class="section-title"><h2>How it works</h2><p>Get started in under 5 minutes</p></div>
      <div class="steps">
        <div class="step"><div class="step-number">1</div><h3>Define your rules</h3><p>Create a style pack with your voice, patterns, CTAs, and tokens. Or use our SaaS starter pack.</p></div>
        <div class="step"><div class="step-number">2</div><h3>Connect your agents</h3><p>Add StyleMCP to your AI workflow via MCP, REST API, or CLI. Works with any model or agent.</p></div>
        <div class="step"><div class="step-number">3</div><h3>Stay on brand</h3><p>Every AI output is validated and can be auto-corrected. Your brand stays consistent at scale.</p></div>
      </div>
    </div>
  </section>

  <section class="api-section" id="api">
    <div class="container">
      <div class="api-grid">
        <div class="api-content">
          <h2>Simple, powerful API</h2>
          <p>Integrate brand validation into any workflow. Validate single texts or batch process at scale.</p>
          <div class="api-endpoints">
            <div class="endpoint"><span class="endpoint-method post">POST</span><span>/api/validate</span></div>
            <div class="endpoint"><span class="endpoint-method post">POST</span><span>/api/rewrite</span></div>
            <div class="endpoint"><span class="endpoint-method get">GET</span><span>/api/packs</span></div>
            <div class="endpoint"><span class="endpoint-method get">GET</span><span>/api/mcp/sse</span></div>
          </div>
        </div>
        <div class="code-block">
          <div class="code-header">Response Example</div>
          <div class="code-body"><pre>{
  <span class="key">"valid"</span>: <span class="boolean">true</span>,
  <span class="key">"score"</span>: <span class="number">92</span>,
  <span class="key">"issues"</span>: [],
  <span class="key">"voice"</span>: {
    <span class="key">"tone"</span>: <span class="string">"confident"</span>,
    <span class="key">"formality"</span>: <span class="string">"professional"</span>
  }
}</pre></div>
        </div>
      </div>
    </div>
  </section>

  <section class="cta">
    <div class="container">
      <div class="cta-box">
        <h2>Ready to keep AI on-brand?</h2>
        <p>Start validating your AI outputs today. Free to use and endlessly customizable.</p>
        <div class="hero-buttons">
          <a href="/docs.html" class="btn btn-primary">Read the Docs</a>
          <a href="/health" class="btn btn-secondary">Check API Status</a>
        </div>
      </div>
    </div>
  </section>

  <footer>
    <div class="container">
      <div class="footer-content">
        <div class="footer-links"><a href="/docs.html">Docs</a><a href="/api/packs">API</a><a href="/health">Status</a></div>
        <div class="footer-copy">&copy; 2026 StyleMCP</div>
      </div>
    </div>
  </footer>
</body>
</html>
HTMLEOF

# Update nginx to serve docs.html
cat > /etc/nginx/sites-available/stylemcp.com << 'NGINXEOF'
server {
    listen 80;
    listen [::]:80;
    server_name stylemcp.com www.stylemcp.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name stylemcp.com www.stylemcp.com;

    ssl_certificate /etc/letsencrypt/live/stylemcp.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/stylemcp.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /var/www/stylemcp;
    index index.html;

    location / {
        try_files $uri $uri/ $uri.html /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/mcp/sse {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Connection '';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 86400s;
        chunked_transfer_encoding off;
    }

    location /health {
        proxy_pass http://127.0.0.1:3000;
    }
}
NGINXEOF

nginx -t && systemctl reload nginx

echo ""
echo "Done! Updated:"
echo "  - https://stylemcp.com (landing page with examples)"
echo "  - https://stylemcp.com/docs (documentation)"
