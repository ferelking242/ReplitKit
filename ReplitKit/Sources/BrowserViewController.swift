import UIKit
  import WebKit

  class BrowserViewController: UIViewController {

      private let addressBar = UITextField()
      private let progressBar = UIProgressView(progressViewStyle: .bar)
      private var webView: WKWebView!
      private let consoleView = UITextView()
      private var consoleVisible = false
      private var kvoToken: NSKeyValueObservation?

      override func viewDidLoad() {
          super.viewDidLoad()
          setupWebView()
          setupNavBar()
          setupAddressBar()
          setupProgressBar()
          setupConsoleView()
          load("https://replit.com")
      }

      private func setupWebView() {
          let config = WKWebViewConfiguration()
          config.userContentController.add(self, name: "consoleLog")
          config.userContentController.add(self, name: "consoleError")
          config.userContentController.add(self, name: "consoleWarn")
          let jsConsole = """
          (function() {
              if (window.__replitKitInjected) return;
              window.__replitKitInjected = true;
              function send(level, args) {
                  var msg = Array.from(args).map(function(a) {
                      try { return typeof a === 'object' ? JSON.stringify(a) : String(a); } catch(e) { return String(a); }
                  }).join(' ');
                  try { window.webkit.messageHandlers['console' + level].postMessage(msg); } catch(e) {}
              }
              var _l = console.log, _e = console.error, _w = console.warn;
              console.log   = function() { _l.apply(console, arguments); send('Log', arguments); };
              console.error = function() { _e.apply(console, arguments); send('Error', arguments); };
              console.warn  = function() { _w.apply(console, arguments); send('Warn', arguments); };
              window.addEventListener('error', function(e) {
                  send('Error', ['UNCAUGHT: ' + e.message + ' @ ' + e.filename + ':' + e.lineno]);
              });
              window.addEventListener('unhandledrejection', function(e) {
                  try { send('Error', ['PROMISE: ' + (e.reason && e.reason.message ? e.reason.message : String(e.reason))]); } catch(ex) {}
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

      @objc private func toggleConsole() {
          consoleVisible.toggle()
          consoleView.isHidden = !consoleVisible
      }

      @objc private func shareLog() {
          let url = URL(fileURLWithPath: Logger.shared.logPath)
          let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
          present(ac, animated: true)
      }

      private func appendConsole(_ line: String) {
          DispatchQueue.main.async {
              self.consoleView.text += line + "\n"
              let r = NSRange(location: self.consoleView.text.count - 1, length: 1)
              self.consoleView.scrollRangeToVisible(r)
          }
      }

      deinit { kvoToken?.invalidate() }
  }

  extension BrowserViewController: WKNavigationDelegate {
      func webView(_ webView: WKWebView, didStartProvisionalNavigation nav: WKNavigation!) {
          progressBar.isHidden = false; progressBar.setProgress(0.05, animated: false)
          Logger.shared.net("→ START \(webView.url?.absoluteString ?? "?")")
      }
      func webView(_ webView: WKWebView, didCommit nav: WKNavigation!) {
          Logger.shared.net("→ COMMIT \(webView.url?.absoluteString ?? "?")")
          addressBar.text = webView.url?.absoluteString
          if let url = webView.url, url.path == "/login" {
              Logger.shared.warn("Redirected to /login — session expired")
              DispatchQueue.main.async { self.backToLogin() }
          }
      }
      func webView(_ webView: WKWebView, didFinish nav: WKNavigation!) {
          progressBar.isHidden = true; progressBar.setProgress(0, animated: false)
          Logger.shared.net("✓ FINISH \(webView.url?.absoluteString ?? "?")")
      }
      func webView(_ webView: WKWebView, didFail nav: WKNavigation!, withError error: Error) {
          progressBar.isHidden = true
          Logger.shared.error("NAV FAIL: \(error.localizedDescription)")
          appendConsole("❌ NAV: \(error.localizedDescription)")
      }
      func webView(_ webView: WKWebView, didFailProvisionalNavigation nav: WKNavigation!, withError error: Error) {
          progressBar.isHidden = true
          Logger.shared.error("PROV FAIL: \(error.localizedDescription)")
          appendConsole("❌ PROV: \(error.localizedDescription)")
      }
      func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                   decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
          let url = action.request.url?.absoluteString ?? "?"
          if url != "about:blank" { Logger.shared.net("REQ \(url)") }
          decisionHandler(.allow)
      }
      func webView(_ webView: WKWebView, decidePolicyFor response: WKNavigationResponse,
                   decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
          if let http = response.response as? HTTPURLResponse {
              Logger.shared.net("RSP \(http.statusCode) \(http.url?.absoluteString ?? "?")")
              if http.statusCode >= 400 { appendConsole("⚠️ HTTP \(http.statusCode)") }
          }
          decisionHandler(.allow)
      }
      private func backToLogin() {
          let lvc = LoginViewController()
          navigationController?.setNavigationBarHidden(true, animated: false)
          navigationController?.setViewControllers([lvc], animated: true)
      }
  }

  extension BrowserViewController: WKUIDelegate {
      func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                   initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
          Logger.shared.js("ALERT: \(message)")
          let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
          present(ac, animated: true)
      }
      func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                   for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
          if let u = action.request.url { load(u.absoluteString) }
          return nil
      }
  }

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

  extension BrowserViewController: UITextFieldDelegate {
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder(); load(textField.text ?? "replit.com"); return true
      }
  }
  