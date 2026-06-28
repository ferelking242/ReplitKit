import UIKit
  import AuthenticationServices
  import WebKit

  class LoginViewController: UIViewController {

      private let logo        = UILabel()
      private let emailField  = UITextField()
      private let passField   = UITextField()
      private let loginBtn    = UIButton(type: .system)
      private let googleBtn   = UIButton(type: .system)
      private let orLabel     = UILabel()
      private let spinner     = UIActivityIndicatorView(style: .medium)
      private let errorLabel  = UILabel()

      override func viewDidLoad() {
          super.viewDidLoad()
          view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
          setupUI()
      }

      private func setupUI() {
          logo.text = "Replit"
          logo.font = UIFont.systemFont(ofSize: 34, weight: .bold)
          logo.textAlignment = .center

          emailField.placeholder = "Email or username"
          emailField.borderStyle = .roundedRect
          emailField.keyboardType = .emailAddress
          emailField.autocapitalizationType = .none
          emailField.autocorrectionType = .no
          emailField.returnKeyType = .next

          passField.placeholder = "Password"
          passField.borderStyle = .roundedRect
          passField.isSecureTextEntry = true
          passField.returnKeyType = .done
          passField.delegate = self

          loginBtn.setTitle("Sign In", for: .normal)
          loginBtn.backgroundColor = UIColor(red: 0.94, green: 0.27, blue: 0.14, alpha: 1)
          loginBtn.setTitleColor(.white, for: .normal)
          loginBtn.layer.cornerRadius = 10
          loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
          loginBtn.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

          orLabel.text = "— or —"
          orLabel.textAlignment = .center
          orLabel.textColor = .secondaryLabel
          orLabel.font = UIFont.systemFont(ofSize: 13)

          googleBtn.setTitle("Continue with Google", for: .normal)
          googleBtn.backgroundColor = .white
          googleBtn.setTitleColor(.label, for: .normal)
          googleBtn.layer.cornerRadius = 10
          googleBtn.layer.borderWidth = 1
          googleBtn.layer.borderColor = UIColor.separator.cgColor
          googleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
          googleBtn.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)

          errorLabel.textColor = .systemRed
          errorLabel.font = UIFont.systemFont(ofSize: 13)
          errorLabel.textAlignment = .center
          errorLabel.numberOfLines = 0
          errorLabel.isHidden = true

          spinner.hidesWhenStopped = true

          let stack = UIStackView(arrangedSubviews: [
              logo, emailField, passField, loginBtn, orLabel, googleBtn, errorLabel, spinner
          ])
          stack.axis = .vertical
          stack.spacing = 14
          stack.translatesAutoresizingMaskIntoConstraints = false

          [emailField, passField, loginBtn, googleBtn].forEach {
              $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
          }

          view.addSubview(stack)
          NSLayoutConstraint.activate([
              stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
              stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
              stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
          ])

          let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
          view.addGestureRecognizer(tap)
      }

      @objc private func dismissKeyboard() { view.endEditing(true) }

      @objc private func loginTapped() {
          let email = emailField.text?.trimmingCharacters(in: .whitespaces) ?? ""
          let pass  = passField.text ?? ""
          guard !email.isEmpty, !pass.isEmpty else { showError("Enter your email and password."); return }
          setLoading(true)
          Logger.shared.log("Attempting login for: \(email)")
          Task {
              do {
                  try await ReplitAuth.emailLogin(email: email, password: pass)
                  await MainActor.run { self.openBrowser() }
              } catch {
                  await MainActor.run {
                      self.setLoading(false)
                      self.showError(error.localizedDescription)
                      Logger.shared.error("Login failed: \(error)")
                  }
              }
          }
      }

      @objc private func googleTapped() {
          setLoading(true)
          Logger.shared.log("Starting Google OAuth")
          let authURL = URL(string: "https://replit.com/auth/google?mobile=1")!
          let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "replitkit") { [weak self] callbackURL, error in
              guard let self = self else { return }
              DispatchQueue.main.async {
                  self.setLoading(false)
                  if let error = error {
                      if (error as? ASWebAuthenticationSessionError)?.code == .canceledLogin { return }
                      self.showError("Google login failed: \(error.localizedDescription)")
                      Logger.shared.error("Google OAuth: \(error)")
                      return
                  }
                  Logger.shared.log("Google OAuth callback: \(callbackURL?.absoluteString ?? "nil")")
                  self.openBrowser()
              }
          }
          session.presentationContextProvider = self
          session.prefersEphemeralWebBrowserSession = false
          session.start()
      }

      private func openBrowser() {
          let vc = BrowserViewController()
          navigationController?.setNavigationBarHidden(false, animated: false)
          navigationController?.setViewControllers([vc], animated: true)
      }

      private func setLoading(_ on: Bool) {
          loginBtn.isEnabled = !on
          googleBtn.isEnabled = !on
          on ? spinner.startAnimating() : spinner.stopAnimating()
          errorLabel.isHidden = true
      }

      private func showError(_ msg: String) {
          errorLabel.text = msg
          errorLabel.isHidden = false
      }
  }

  extension LoginViewController: UITextFieldDelegate {
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          if textField == passField { loginTapped() } else { passField.becomeFirstResponder() }
          return true
      }
  }

  extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
      func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
          return view.window!
      }
  }

  enum ReplitAuth {
      static func emailLogin(email: String, password: String) async throws {
          let url = URL(string: "https://replit.com/graphql")!
          var req = URLRequest(url: url)
          req.httpMethod = "POST"
          req.setValue("application/json", forHTTPHeaderField: "Content-Type")
          req.setValue("https://replit.com", forHTTPHeaderField: "Origin")
          req.setValue("https://replit.com/login", forHTTPHeaderField: "Referer")
          req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
          req.httpShouldHandleCookies = true

          let mutation = """
          mutation login($username: String!, $password: String!) {
            login(input: { username: $username, password: $password }) {
              ... on User { id username }
              ... on UserError { message }
            }
          }
          """
          let body: [String: Any] = ["query": mutation, "variables": ["username": email, "password": password]]
          req.httpBody = try JSONSerialization.data(withJSONObject: body)

          let (data, response) = try await URLSession.shared.data(for: req)
          if let http = response as? HTTPURLResponse { Logger.shared.net("GraphQL: \(http.statusCode)") }

          guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let dataObj = json["data"] as? [String: Any],
                let loginObj = dataObj["login"] as? [String: Any] else {
              let raw = String(data: data, encoding: .utf8) ?? "?"
              Logger.shared.error("Unexpected: \(raw)")
              throw NSError(domain: "ReplitAuth", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Unexpected response. Check credentials."])
          }

          if let errMsg = loginObj["message"] as? String {
              throw NSError(domain: "ReplitAuth", code: 2,
                            userInfo: [NSLocalizedDescriptionKey: errMsg])
          }

          if let username = loginObj["username"] as? String {
              Logger.shared.log("Logged in as: \(username)")
          }

          // Sync cookies → WKWebView store so the dashboard loads authenticated
          let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: "https://replit.com")!) ?? []
          Logger.shared.log("Syncing \(cookies.count) cookies to WKWebView")
          let wkStore = WKWebsiteDataStore.default().httpCookieStore
          for cookie in cookies { await wkStore.setCookie(cookie) }
      }
  }
  