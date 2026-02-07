/**
 * StyleMCP Client-Side Error Reporter
 * Include on any landing page / dashboard HTML:
 *   <script src="/error-reporter.js"></script>
 *
 * Automatically captures unhandled errors and promise rejections,
 * then POSTs them to /api/errors/report.
 */
(function () {
  'use strict';

  var ENDPOINT = '/api/errors/report';
  var sent = {};      // dedup by message
  var MAX_PER_PAGE = 5; // don't flood
  var count = 0;

  function getPage() {
    return location.pathname || 'unknown';
  }

  function report(message, stack, extra) {
    if (count >= MAX_PER_PAGE) return;
    var key = message + (stack || '').slice(0, 100);
    if (sent[key]) return;
    sent[key] = true;
    count++;

    try {
      var body = JSON.stringify({
        page: getPage(),
        message: (message || 'Unknown error').slice(0, 2000),
        stack: (stack || '').slice(0, 4000),
        url: location.href,
        extra: extra || {}
      });

      if (navigator.sendBeacon) {
        navigator.sendBeacon(ENDPOINT, new Blob([body], { type: 'application/json' }));
      } else {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', ENDPOINT, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(body);
      }
    } catch (e) {
      // Fail silently — don't cause more errors
    }
  }

  // Global error handler
  window.addEventListener('error', function (event) {
    report(
      event.message || 'Script error',
      event.error && event.error.stack ? event.error.stack : (event.filename + ':' + event.lineno),
      { colno: event.colno, filename: event.filename }
    );
  });

  // Unhandled promise rejections
  window.addEventListener('unhandledrejection', function (event) {
    var reason = event.reason;
    var message = reason instanceof Error ? reason.message : String(reason || 'Promise rejection');
    var stack = reason instanceof Error ? reason.stack : undefined;
    report(message, stack, { type: 'unhandledrejection' });
  });

  // Expose for manual reporting
  window.StyleMCPErrorReporter = { report: report };
})();
