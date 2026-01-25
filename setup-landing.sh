#!/bin/bash
# StyleMCP Landing Page Setup Script
# Run this on your VPS: bash setup-landing.sh

set -e

echo "Setting up StyleMCP landing page..."

# Create directory
mkdir -p /var/www/stylemcp

# Create the landing page
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
    *{margin:0;padding:0;box-sizing:border-box}:root{--bg:#0a0a0b;--bg-elevated:#141416;--bg-card:#1a1a1e;--border:#2a2a2e;--text:#fafafa;--text-muted:#a1a1aa;--accent:#6366f1;--accent-hover:#818cf8;--green:#22c55e;--red:#ef4444;--yellow:#eab308}body{font-family:'Inter',-apple-system,BlinkMacSystemFont,sans-serif;background:var(--bg);color:var(--text);line-height:1.6;-webkit-font-smoothing:antialiased}.container{max-width:1200px;margin:0 auto;padding:0 24px}nav{position:fixed;top:0;left:0;right:0;background:rgba(10,10,11,0.8);backdrop-filter:blur(12px);border-bottom:1px solid var(--border);z-index:100}nav .container{display:flex;align-items:center;justify-content:space-between;height:64px}.logo{font-weight:700;font-size:1.25rem;color:var(--text);text-decoration:none;display:flex;align-items:center;gap:8px}.logo-icon{width:32px;height:32px;background:linear-gradient(135deg,var(--accent) 0%,#a855f7 100%);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:16px}.nav-links{display:flex;align-items:center;gap:32px}.nav-links a{color:var(--text-muted);text-decoration:none;font-size:0.9rem;font-weight:500;transition:color 0.2s}.nav-links a:hover{color:var(--text)}.btn{display:inline-flex;align-items:center;gap:8px;padding:10px 20px;border-radius:8px;font-weight:500;font-size:0.9rem;text-decoration:none;transition:all 0.2s;cursor:pointer;border:none}.btn-primary{background:var(--accent);color:white}.btn-primary:hover{background:var(--accent-hover)}.btn-secondary{background:var(--bg-card);color:var(--text);border:1px solid var(--border)}.btn-secondary:hover{background:var(--bg-elevated);border-color:var(--text-muted)}.hero{padding:160px 0 100px;text-align:center}.badge{display:inline-flex;align-items:center;gap:8px;padding:6px 14px;background:var(--bg-card);border:1px solid var(--border);border-radius:50px;font-size:0.85rem;color:var(--text-muted);margin-bottom:24px}.badge-dot{width:6px;height:6px;background:var(--green);border-radius:50%}h1{font-size:clamp(2.5rem,6vw,4rem);font-weight:700;line-height:1.1;margin-bottom:24px;letter-spacing:-0.02em}.gradient-text{background:linear-gradient(135deg,var(--accent) 0%,#a855f7 50%,#ec4899 100%);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}.hero p{font-size:1.25rem;color:var(--text-muted);max-width:600px;margin:0 auto 40px}.hero-buttons{display:flex;gap:16px;justify-content:center;flex-wrap:wrap}.demo{margin-top:80px;background:var(--bg-card);border:1px solid var(--border);border-radius:16px;overflow:hidden}.demo-header{display:flex;align-items:center;gap:8px;padding:12px 16px;background:var(--bg-elevated);border-bottom:1px solid var(--border)}.demo-dot{width:12px;height:12px;border-radius:50%}.demo-dot.red{background:#ff5f57}.demo-dot.yellow{background:#febc2e}.demo-dot.green{background:#28c840}.demo-content{padding:24px;font-family:'JetBrains Mono',monospace;font-size:0.9rem;overflow-x:auto}.demo-line{display:flex;margin-bottom:8px}.demo-prompt{color:var(--accent);margin-right:8px}.demo-command{color:var(--text-muted)}.demo-response{color:var(--text);padding-left:20px}.demo-valid{color:var(--green)}.demo-warning{color:var(--yellow)}.features{padding:120px 0}.section-title{text-align:center;margin-bottom:60px}.section-title h2{font-size:2.5rem;font-weight:700;margin-bottom:16px}.section-title p{color:var(--text-muted);font-size:1.1rem;max-width:500px;margin:0 auto}.features-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:24px}.feature-card{background:var(--bg-card);border:1px solid var(--border);border-radius:16px;padding:32px;transition:border-color 0.2s}.feature-card:hover{border-color:var(--text-muted)}.feature-icon{width:48px;height:48px;background:linear-gradient(135deg,var(--accent) 0%,#a855f7 100%);border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:24px;margin-bottom:20px}.feature-card h3{font-size:1.25rem;font-weight:600;margin-bottom:12px}.feature-card p{color:var(--text-muted);font-size:0.95rem}.how-it-works{padding:120px 0;background:var(--bg-elevated)}.steps{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:40px;margin-top:60px}.step{text-align:center}.step-number{width:56px;height:56px;background:var(--bg-card);border:2px solid var(--accent);border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:1.5rem;font-weight:700;color:var(--accent);margin:0 auto 20px}.step h3{font-size:1.25rem;margin-bottom:12px}.step p{color:var(--text-muted);font-size:0.95rem}.api-section{padding:120px 0}.api-grid{display:grid;grid-template-columns:1fr 1fr;gap:60px;align-items:center}@media(max-width:768px){.api-grid{grid-template-columns:1fr}}.api-content h2{font-size:2.5rem;margin-bottom:24px}.api-content p{color:var(--text-muted);margin-bottom:32px;font-size:1.1rem}.api-endpoints{display:flex;flex-direction:column;gap:12px}.endpoint{display:flex;align-items:center;gap:12px;padding:12px 16px;background:var(--bg-card);border:1px solid var(--border);border-radius:8px;font-family:'JetBrains Mono',monospace;font-size:0.85rem}.endpoint-method{padding:4px 8px;border-radius:4px;font-weight:600;font-size:0.75rem}.endpoint-method.get{background:rgba(34,197,94,0.2);color:var(--green)}.endpoint-method.post{background:rgba(99,102,241,0.2);color:var(--accent)}.code-block{background:var(--bg-card);border:1px solid var(--border);border-radius:12px;overflow:hidden}.code-header{padding:12px 16px;background:var(--bg-elevated);border-bottom:1px solid var(--border);font-size:0.85rem;color:var(--text-muted)}.code-body{padding:20px;font-family:'JetBrains Mono',monospace;font-size:0.85rem;overflow-x:auto}.code-body .key{color:#a855f7}.code-body .string{color:#22c55e}.code-body .number{color:#f59e0b}.code-body .boolean{color:#3b82f6}.cta{padding:120px 0;text-align:center}.cta-box{background:linear-gradient(135deg,rgba(99,102,241,0.1) 0%,rgba(168,85,247,0.1) 100%);border:1px solid var(--border);border-radius:24px;padding:80px 40px}.cta h2{font-size:2.5rem;margin-bottom:16px}.cta p{color:var(--text-muted);font-size:1.1rem;margin-bottom:40px;max-width:500px;margin-left:auto;margin-right:auto}footer{padding:60px 0;border-top:1px solid var(--border)}.footer-content{display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:24px}.footer-links{display:flex;gap:32px}.footer-links a{color:var(--text-muted);text-decoration:none;font-size:0.9rem;transition:color 0.2s}.footer-links a:hover{color:var(--text)}.footer-copy{color:var(--text-muted);font-size:0.9rem}@media(max-width:640px){.nav-links{display:none}.hero{padding:120px 0 60px}.hero-buttons{flex-direction:column;align-items:center}.features,.how-it-works,.api-section,.cta{padding:80px 0}}
  </style>
</head>
<body>
  <nav>
    <div class="container">
      <a href="/" class="logo">
        <div class="logo-icon">S</div>
        StyleMCP
      </a>
      <div class="nav-links">
        <a href="#features">Features</a>
        <a href="#how-it-works">How It Works</a>
        <a href="#api">API</a>
        <a href="/api/packs" class="btn btn-primary">Get Started</a>
      </div>
    </div>
  </nav>

  <section class="hero">
    <div class="container">
      <div class="badge">
        <span class="badge-dot"></span>
        MCP Compatible
      </div>
      <h1>Brand rules for <span class="gradient-text">AI outputs</span></h1>
      <p>Keep every AI-generated message on-brand. Validate, rewrite, and enforce your style guide across all your AI agents and models.</p>
      <div class="hero-buttons">
        <a href="#api" class="btn btn-primary">View API Docs</a>
        <a href="/health" class="btn btn-secondary">Check Status</a>
      </div>

      <div class="demo">
        <div class="demo-header">
          <span class="demo-dot red"></span>
          <span class="demo-dot yellow"></span>
          <span class="demo-dot green"></span>
        </div>
        <div class="demo-content">
          <div class="demo-line">
            <span class="demo-prompt">$</span>
            <span class="demo-command">curl -X POST https://stylemcp.com/api/validate \</span>
          </div>
          <div class="demo-line">
            <span class="demo-response">-d '{"text": "Click here to learn more!"}'</span>
          </div>
          <div class="demo-line" style="margin-top: 16px;">
            <span class="demo-response">{</span>
          </div>
          <div class="demo-line">
            <span class="demo-response">  "valid": <span class="demo-warning">false</span>,</span>
          </div>
          <div class="demo-line">
            <span class="demo-response">  "score": 65,</span>
          </div>
          <div class="demo-line">
            <span class="demo-response">  "issues": [{ "rule": "no-click-here" }],</span>
          </div>
          <div class="demo-line">
            <span class="demo-response">  "suggestion": "Learn more about our features"</span>
          </div>
          <div class="demo-line">
            <span class="demo-response">}</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section class="features" id="features">
    <div class="container">
      <div class="section-title">
        <h2>Everything you need</h2>
        <p>A complete toolkit for enforcing brand consistency across AI outputs</p>
      </div>
      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">&#10003;</div>
          <h3>Real-time Validation</h3>
          <p>Instantly validate AI-generated text against your brand rules. Get scores, issues, and actionable feedback.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">&#9998;</div>
          <h3>Auto-Rewriting</h3>
          <p>Automatically rewrite off-brand content to match your voice. Choose minimal, normal, or aggressive modes.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">&#9881;</div>
          <h3>Style Packs</h3>
          <p>Modular rule packs for different use cases. Voice, copy patterns, CTAs, and design tokens all in one place.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">&#128279;</div>
          <h3>MCP Integration</h3>
          <p>Native Model Context Protocol support. Connect directly to Claude, GPT, and other AI agents.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">&#128640;</div>
          <h3>REST API</h3>
          <p>Simple HTTP API for any integration. Validate single texts or batch process thousands of items.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">&#128736;</div>
          <h3>GitHub Actions</h3>
          <p>Run brand checks in CI/CD. Catch off-brand copy before it reaches production.</p>
        </div>
      </div>
    </div>
  </section>

  <section class="how-it-works" id="how-it-works">
    <div class="container">
      <div class="section-title">
        <h2>How it works</h2>
        <p>Get started in under 5 minutes</p>
      </div>
      <div class="steps">
        <div class="step">
          <div class="step-number">1</div>
          <h3>Define your rules</h3>
          <p>Create a style pack with your voice, patterns, CTAs, and tokens. Or use our SaaS starter pack.</p>
        </div>
        <div class="step">
          <div class="step-number">2</div>
          <h3>Connect your agents</h3>
          <p>Add StyleMCP to your AI workflow via MCP, REST API, or CLI. Works with any model or agent.</p>
        </div>
        <div class="step">
          <div class="step-number">3</div>
          <h3>Stay on brand</h3>
          <p>Every AI output is validated and can be auto-corrected. Your brand stays consistent at scale.</p>
        </div>
      </div>
    </div>
  </section>

  <section class="api-section" id="api">
    <div class="container">
      <div class="api-grid">
        <div class="api-content">
          <h2>Simple, powerful API</h2>
          <p>Integrate brand validation into any workflow with our REST API. Validate single texts or batch process at scale.</p>
          <div class="api-endpoints">
            <div class="endpoint">
              <span class="endpoint-method post">POST</span>
              <span>/api/validate</span>
            </div>
            <div class="endpoint">
              <span class="endpoint-method post">POST</span>
              <span>/api/rewrite</span>
            </div>
            <div class="endpoint">
              <span class="endpoint-method get">GET</span>
              <span>/api/packs</span>
            </div>
            <div class="endpoint">
              <span class="endpoint-method get">GET</span>
              <span>/api/mcp/sse</span>
            </div>
          </div>
        </div>
        <div class="code-block">
          <div class="code-header">Response Example</div>
          <div class="code-body">
<pre>{
  <span class="key">"valid"</span>: <span class="boolean">true</span>,
  <span class="key">"score"</span>: <span class="number">92</span>,
  <span class="key">"issues"</span>: [],
  <span class="key">"voice"</span>: {
    <span class="key">"tone"</span>: <span class="string">"confident"</span>,
    <span class="key">"formality"</span>: <span class="string">"professional"</span>
  }
}</pre>
          </div>
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
          <a href="/api/packs" class="btn btn-primary">Get Started Free</a>
          <a href="/health" class="btn btn-secondary">Check API Status</a>
        </div>
      </div>
    </div>
  </section>

  <footer>
    <div class="container">
      <div class="footer-content">
        <div class="footer-links">
          <a href="/api/packs">API</a>
          <a href="/health">Status</a>
        </div>
        <div class="footer-copy">&copy; 2026 StyleMCP</div>
      </div>
    </div>
  </footer>
</body>
</html>
HTMLEOF

# Update nginx config
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
        try_files $uri $uri/ /index.html;
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

# Test and reload nginx
nginx -t && systemctl reload nginx

echo ""
echo "Done! Visit https://stylemcp.com"
