import UIKit
  import WebKit

  // ─── Hardcoded Replit session cookies ────────────────────────────────────────
  private let replitCookies: [[String: Any]] = [
      ["name": "_ga_MPJY3F1YEL", "value": "GS2.2.s1776182361$o10$g1$t1776182371$j50$l0$h660148579", "domain": ".replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1810742371.629],
      ["name": "replit_statsig_stable_id", "value": "13775ab5-1a21-48fa-9227-815bcc4a0536", "domain": "replit.com", "path": "/", "secure": true, "httpOnly": false, "expires": 1806834940.269],
      ["name": "marketing_attribution", "value": "{%22last_fbp%22:%22fb.1.1775298885829.207696713791408376%22%2C%22first_fbp%22:%22fb.1.1775298885829.207696713791408376%22}", "domain": "replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1814142527],
      ["name": "ld_uid", "value": "45444832", "domain": "replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 0],
      ["name": "_dd_s", "value": "logs=1&id=1b828411-a54c-40c7-ae9b-59e14663dc5f&created=1782606502283&expire=1782607426027", "domain": "replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1782607426],
      ["name": "analytics_session_id.last_access", "value": "1781831175923", "domain": ".replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1813367175],
      ["name": "_ga", "value": "GA1.2.1315687772.1775298962", "domain": ".replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1810742360.369],
      ["name": "g_state", "value": "{\"i_l\":0}", "domain": "replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1797026610],
      ["name": "__stripe_mid", "value": "f51d5705-5751-4484-b739-22a942473739ac3f21", "domain": ".replit.com", "path": "/", "secure": true, "httpOnly": false, "expires": 1814142531],
      ["name": "replit_authed", "value": "1", "domain": "replit.com", "path": "/", "secure": true, "httpOnly": true, "expires": 1783211330.213],
      ["name": "__stripe_sid", "value": "d2d53521-757f-4fbf-9ef8-48a8aee73a76f47d7d", "domain": ".replit.com", "path": "/", "secure": true, "httpOnly": false, "expires": 1781832845],
      ["name": "_fbp", "value": "fb.1.1775298885829.207696713791408376", "domain": ".replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1789607041],
      ["name": "_gcl_au", "value": "1.1.197199112.1775298961", "domain": ".replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1783074961],
      ["name": "_gid", "value": "GA1.2.1897315643.1776069481", "domain": ".replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1776268760],
      ["name": "ajs_anonymous_id", "value": "7f7140d1-0d03-4be0-9f2e-b8911fe3bc9e", "domain": ".replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1813367173],
      ["name": "ajs_user_id", "value": "48115522", "domain": ".replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1813367173],
      ["name": "analytics_session_id", "value": "1781826866995", "domain": ".replit.com", "path": "/", "secure": false, "httpOnly": false, "expires": 1813367175],
      // Critical auth cookies
      ["name": "connect.sid", "value": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjRVUXdHZyJ9.eyJpc3MiOiJodHRwczovL3Nlc3Npb24uZmlyZWJhc2UuZ29vZ2xlLmNvbS9yZXBsaXQtd2ViIiwicm9sZXMiOltdLCJyZXBsaXRfdXNlcl9pZCI6NDgxMTU1MjIsImF1ZCI6InJlcGxpdC13ZWIiLCJhdXRoX3RpbWUiOjE3ODE0NzQ2MjcsInVzZXJfaWQiOiJtZU8yTkF5azhkYmJSMFVsZkJ5dUc2blA5aWUyIiwic3ViIjoibWVPMk5BeWs4ZGJiUjBVbGZCeXVHNm5QOWllMiIsImlhdCI6MTc4MjYwNjUzMCwiZXhwIjoxNzgzMjExMzMwLCJlbWFpbCI6Im5ldGFqYXQ5NDVAcHJvdG9uemEuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsibmV0YWphdDk0NUBwcm90b256YS5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwYXNzd29yZCJ9fQ.GnauXfYf4ouXJxVaoHVy1RvQAUiRM1mwYlfCSC0Kug99vrD7Yv6kntxbwt0vAA2OefIid3WduFG5dov9W2jO_EHsMlUn5U6DKxP4fQ7aS7vWr4sN49ElGiR7vndyItsuJBRaeami26GohVqCtDDYgwwE-JL6deAccOHqDQr1E5IaC_pJc3ujKwEh-oIdg9jZl9-0AubmbJDkhBjFTf0MKZBgXLn5YaqXJQICglZ1LCz8ELOb2wKUu7WRLmjV53GjCxVESU4bwUGJKTY7DTdJJe5RHhs40IKS7RNESSafqYIj5uGhwiOmXaet0BcP2_TQfNV8v59QnrKFhw4-OqwsNA", "domain": "replit.com", "path": "/", "secure": true, "httpOnly": true, "expires": 1783211330.212],
      ["name": "__Host-session-sig", "value": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImNmLWp3dC0yMDI2LTA1LTA2LTE4MDMiLCJ0eXAiOiJKV1QifQ.eyJzdWIiOiI0ODExNTUyMiIsInRjIjoxNzU5MTU1MjMwLCJlbnQiOmZhbHNlLCJwYWlkIjpmYWxzZSwiaWF0IjoxNzgyNjA2NTMwLCJleHAiOjE3ODI2MDc0MzB9.EJOmurA7Jw0OEk51AVKqqR4kUFrWlJjOksEX_Z31lwmV5yb2VVEgfAQPImW7wwStgRn5K9gfF5bfnbIoN_ZsIQrWAgMyfkTN7YNIAyAYKDBwUxh-3h_tUchI2l1yGjPtYPSMZ5L4jaWrRs5lWgDyl10k0hJSl-cCG-tkpvYKbl_9M5oXWcsAGdNTIADQHOc3CC6ua1TgUIJFAiyev4SQsOwcjR6enJ-xkXp3I1GCsA5kx0de17T0qjDpe8PtSoAUNdjZuw7PkclPGQIhI6u4XmApJrv-yU73oWnAucy7YUMYVd21QMczYc4O6WYY2EUPGsQ37J2xVqrpuACOuWHbVw", "domain": "replit.com", "path": "/", "secure": true, "httpOnly": true, "expires": 1782607430.215],
      ["name": "__Host-wr-tc", "value": "1759155230", "domain": "replit.com", "path": "/", "secure": true, "httpOnly": true, "expires": 1782607430.214],
  ]

  class BrowserViewController: UIViewController {

      private let addressBar  = UITextField()
      private let progressBar = UIProgressView(progressViewStyle: .bar)
      private var webView: WKWebView!
      private let consoleView = UITextView()
      private var consoleVisible = false
      private var kvoToken: NSKeyValueObservation?
      private var cookiesInjected = false

      override func viewDidLoad() {
          super.viewDidLoad()
          setupWebView()
          setupNavBar()
          setupAddressBar()
          setupProgressBar()
          setupConsoleView()
          injectCookiesThenLoad()
      }

      // MARK: - Cookie Injection
      private func injectCookiesThenLoad() {
          let store = webView.configuration.websiteDataStore.httpCookieStore
          let group = DispatchGroup()

          for raw in replitCookies {
              guard let name   = raw["name"]   as? String,
                    let value  = raw["value"]  as? String,
                    let domain = raw["domain"] as? String,
                    let path   = raw["path"]   as? String else { continue }

              var props: [HTTPCookiePropertyKey: Any] = [
                  .name:   name,
                  .value:  value,
                  .domain: domain,
                  .path:   path,
              ]
              if let secure = raw["secure"] as? Bool, secure {
                  props[.secure] = "TRUE"
              }
              if let httpOnly = raw["httpOnly"] as? Bool, httpOnly {
                  props[.init("HttpOnly")] = "TRUE"
              }
              if let exp = raw["expires"] as? Double, exp > 0 {
                  props[.expires] = Date(timeIntervalSince1970: exp)
              }

              if let cookie = HTTPCookie(properties: props) {
                  group.enter()
                  store.setCookie(cookie) { group.leave() }
              }
          }

          group.notify(queue: .main) {
              Logger.shared.log("Cookies injected (\(replitCookies.count) entries) — loading replit.com")
              self.cookiesInjected = true
              self.load("https://replit.com")
          }
      }

      // MARK: - WebView Setup
      private func setupWebView() {
          let config = WKWebViewConfiguration()
          config.userContentController.add(self, name: "consoleLog")
          config.userContentController.add(self, name: "consoleError")
          config.userContentController.add(self, name: "consoleWarn")

          let jsConsole = """
          (function() {
              if (window.__rk) return; window.__rk = true;
              function send(lv, args) {
                  var m = Array.from(args).map(function(a){
                      try{return typeof a==='object'?JSON.stringify(a):String(a);}catch(e){return String(a);}
                  }).join(' ');
                  try{window.webkit.messageHandlers['console'+lv].postMessage(m);}catch(e){}
              }
              var _l=console.log,_e=console.error,_w=console.warn;
              console.log  =function(){_l.apply(console,arguments);send('Log',arguments);};
              console.error=function(){_e.apply(console,arguments);send('Error',arguments);};
              console.warn =function(){_w.apply(console,arguments);send('Warn',arguments);};
              window.addEventListener('error',function(e){
                  send('Error',['UNCAUGHT: '+e.message+' @ '+e.filename+':'+e.lineno]);
              });
              window.addEventListener('unhandledrejection',function(e){
                  try{send('Error',['PROMISE: '+(e.reason&&e.reason.message?e.reason.message:String(e.reason))]);}catch(x){}
              });
          })();
          """
          config.userContentController.addUserScript(
              WKUserScript(source: jsConsole, injectionTime: .atDocumentStart, forMainFrameOnly: false)
          )
          config.websiteDataStore = .default()
          config.allowsInlineMediaPlayback = true
          config.mediaTypesRequiringUserActionForPlayback = []

          webView = WKWebView(frame: .zero, configuration: config)
          webView.navigationDelegate = self
          webView.uiDelegate = self
          webView.allowsBackForwardNavigationGestures = true
          webView.translatesAutoresizingMaskIntoConstraints = false
          webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

          view.addSubview(webView)
          NSLayoutConstraint.activate([
              webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 88),
              webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
          ])

          kvoToken = webView.observe(\.estimatedProgress, options: .new) { [weak self] wv, _ in
              DispatchQueue.main.async {
                  let p = Float(wv.estimatedProgress)
                  self?.progressBar.setProgress(p, animated: true)
                  self?.progressBar.isHidden = p >= 1.0
              }
          }
      }

      // MARK: - Nav Bar
      private func setupNavBar() {
          title = "ReplitKit"
          navigationController?.navigationBar.tintColor = .systemOrange
          let back    = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),        style: .plain, target: self, action: #selector(goBack))
          let forward = UIBarButtonItem(image: UIImage(systemName: "chevron.right"),       style: .plain, target: self, action: #selector(goForward))
          let reload  = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"),     style: .plain, target: self, action: #selector(reloadPage))
          let console = UIBarButtonItem(image: UIImage(systemName: "ladybug"),             style: .plain, target: self, action: #selector(toggleConsole))
          let share   = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareLog))
          navigationItem.leftBarButtonItems  = [back, forward]
          navigationItem.rightBarButtonItems = [share, console, reload]
      }

      // MARK: - Address Bar
      private func setupAddressBar() {
          addressBar.translatesAutoresizingMaskIntoConstraints = false
          addressBar.borderStyle = .roundedRect
          addressBar.keyboardType = .URL
          addressBar.autocapitalizationType = .none
          addressBar.autocorrectionType = .no
          addressBar.returnKeyType = .go
          addressBar.placeholder = "replit.com"
          addressBar.delegate = self
          addressBar.backgroundColor = UIColor.secondarySystemBackground
          view.addSubview(addressBar)
          NSLayoutConstraint.activate([
              addressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
              addressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
              addressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
              addressBar.heightAnchor.constraint(equalToConstant: 36)
          ])
      }

      // MARK: - Progress Bar
      private func setupProgressBar() {
          progressBar.translatesAutoresizingMaskIntoConstraints = false
          progressBar.progressTintColor = .systemOrange
          progressBar.trackTintColor = .clear
          progressBar.isHidden = true
          view.addSubview(progressBar)
          NSLayoutConstraint.activate([
              progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
              progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              progressBar.heightAnchor.constraint(equalToConstant: 2)
          ])
      }

      // MARK: - Console Overlay
      private func setupConsoleView() {
          consoleView.translatesAutoresizingMaskIntoConstraints = false
          consoleView.backgroundColor = UIColor.black.withAlphaComponent(0.88)
          consoleView.textColor = .green
          consoleView.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
          consoleView.isEditable = false
          consoleView.isHidden = true
          consoleView.layer.cornerRadius = 8
          view.addSubview(consoleView)
          NSLayoutConstraint.activate([
              consoleView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
              consoleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
              consoleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
              consoleView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35)
          ])
      }

      // MARK: - Load
      func load(_ urlString: String) {
          var s = urlString.trimmingCharacters(in: .whitespaces)
          if !s.hasPrefix("http") { s = "https://" + s }
          guard let url = URL(string: s) else { return }
          Logger.shared.net("Loading: \(url.absoluteString)")
          addressBar.text = url.absoluteString
          webView.load(URLRequest(url: url))
      }

      @objc private func goBack()     { if webView.canGoBack    { webView.goBack() } }
      @objc private func goForward()  { if webView.canGoForward { webView.goForward() } }
      @objc private func reloadPage() { webView.reload() }
      @objc private func toggleConsole() { consoleVisible.toggle(); consoleView.isHidden = !consoleVisible }
      @objc private func shareLog() {
          let ac = UIActivityViewController(activityItems: [URL(fileURLWithPath: Logger.shared.logPath)], applicationActivities: nil)
          present(ac, animated: true)
      }
      func appendConsole(_ line: String) {
          DispatchQueue.main.async {
              self.consoleView.text += line + "\n"
              let r = NSRange(location: self.consoleView.text.count - 1, length: 1)
              self.consoleView.scrollRangeToVisible(r)
          }
      }
      deinit { kvoToken?.invalidate() }
  }

  // MARK: - WKNavigationDelegate
  extension BrowserViewController: WKNavigationDelegate {
      func webView(_ webView: WKWebView, didStartProvisionalNavigation nav: WKNavigation!) {
          progressBar.isHidden = false; progressBar.setProgress(0.05, animated: false)
          Logger.shared.net("→ START \(webView.url?.absoluteString ?? "?")")
      }
      func webView(_ webView: WKWebView, didCommit nav: WKNavigation!) {
          Logger.shared.net("→ COMMIT \(webView.url?.absoluteString ?? "?")")
          addressBar.text = webView.url?.absoluteString
      }
      func webView(_ webView: WKWebView, didFinish nav: WKNavigation!) {
          progressBar.isHidden = true; progressBar.setProgress(0, animated: false)
          Logger.shared.net("✓ FINISH \(webView.url?.absoluteString ?? "?")")
          webView.evaluateJavaScript("JSON.stringify({title:document.title,url:location.href,bodyLen:document.body?document.body.innerHTML.length:-1,scripts:document.scripts.length})") { [weak self] r, _ in
              if let s = r as? String { Logger.shared.log("PAGE: \(s)"); self?.appendConsole("📄 \(s)") }
          }
      }
      func webView(_ webView: WKWebView, didFail nav: WKNavigation!, withError e: Error) {
          progressBar.isHidden = true; Logger.shared.error("FAIL: \(e.localizedDescription)"); appendConsole("❌ \(e.localizedDescription)")
      }
      func webView(_ webView: WKWebView, didFailProvisionalNavigation nav: WKNavigation!, withError e: Error) {
          progressBar.isHidden = true; Logger.shared.error("PROV: \(e.localizedDescription)"); appendConsole("❌ \(e.localizedDescription)")
      }
      func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
          let url = action.request.url?.absoluteString ?? "?"
          if url != "about:blank" { Logger.shared.net("REQ \(url)") }
          decisionHandler(.allow)
      }
      func webView(_ webView: WKWebView, decidePolicyFor response: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
          if let http = response.response as? HTTPURLResponse {
              Logger.shared.net("RSP \(http.statusCode) \(http.url?.absoluteString ?? "?")")
              if http.statusCode >= 400 { appendConsole("⚠️ HTTP \(http.statusCode)") }
          }
          decisionHandler(.allow)
      }
  }

  // MARK: - WKUIDelegate
  extension BrowserViewController: WKUIDelegate {
      func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                   initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
          let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
          present(ac, animated: true)
      }
      func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                   for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
          if let u = action.request.url { load(u.absoluteString) }; return nil
      }
  }

  // MARK: - WKScriptMessageHandler
  extension BrowserViewController: WKScriptMessageHandler {
      func userContentController(_ ucc: WKUserContentController, didReceive message: WKScriptMessage) {
          let text = message.body as? String ?? String(describing: message.body)
          switch message.name {
          case "consoleLog":   Logger.shared.js("LOG: \(text)");   appendConsole("🟢 \(text)")
          case "consoleError": Logger.shared.error("JS: \(text)"); appendConsole("🔴 \(text)")
          case "consoleWarn":  Logger.shared.warn("JS: \(text)");  appendConsole("🟡 \(text)")
          default: break
          }
      }
  }

  // MARK: - UITextFieldDelegate
  extension BrowserViewController: UITextFieldDelegate {
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder(); load(textField.text ?? "replit.com"); return true
      }
  }
  