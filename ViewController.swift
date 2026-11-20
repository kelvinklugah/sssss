import UIKit
import WebKit
import LocalAuthentication

class ViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.024, green: 0.063, blue: 0.098, alpha: 1.0)

        let contentController = WKUserContentController()
        contentController.add(self, name: "kvnFaceID")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.024, green: 0.063, blue: 0.098, alpha: 1.0)
        webView.scrollView.backgroundColor = UIColor(red: 0.024, green: 0.063, blue: 0.098, alpha: 1.0)
        webView.scrollView.bounces = false
        view.addSubview(webView)

        if let indexURL = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(indexURL, allowingReadAccessTo: indexURL.deletingLastPathComponent())
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "kvnFaceID" else { return }
        authenticateWithFaceID()
    }

    private func authenticateWithFaceID() {
        let context = LAContext()
        var authError: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock KVN_EXE Vault"
            ) { [weak self] success, error in
                DispatchQueue.main.async {
                    let msg = (error?.localizedDescription ?? "").replacingOccurrences(of: "\"", with: "'")
                    let js = """
                    if (window.__kvnFaceIDResolve) { window.__kvnFaceIDResolve(\(success)); }
                    if (window.onKvnFaceIDResult) { window.onKvnFaceIDResult(\(success), "\(msg)"); }
                    window.dispatchEvent(new CustomEvent('kvn-faceid-result', { detail: { success: \(success), error: "\(msg)" } }));
                    """
                    self?.webView.evaluateJavaScript(js, completionHandler: nil)
                }
            }
        } else {
            let msg = (authError?.localizedDescription ?? "Biometrics unavailable").replacingOccurrences(of: "\"", with: "'")
            let js = """
            if (window.__kvnFaceIDResolve) { window.__kvnFaceIDResolve(false); }
            if (window.onKvnFaceIDResult) { window.onKvnFaceIDResult(false, "\(msg)"); }
            window.dispatchEvent(new CustomEvent('kvn-faceid-result', { detail: { success: false, error: "\(msg)" } }));
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}
