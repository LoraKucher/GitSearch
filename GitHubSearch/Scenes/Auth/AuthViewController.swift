import UIKit
import AuthenticationServices

struct Constants {
    static let client_id = "27d05553ce89488f06e5"
    static let client_secret = "636f56ce33b43077c98966c5a0844278215b2803"
}

class AuthViewController: UIViewController {
    
    var authSession: ASWebAuthenticationSession?
    var viewModel: AuthViewModel!
    
    @IBAction func loginButtonTouchUpInside(_ sender: Any) {
        getAuthenticateURL()
    }
    
    func getAuthenticateURL() {
        
        var urlComponent = URLComponents(string: "https://github.com/login/oauth/authorize?scope=user:email")!
        
        var queryItems = urlComponent.queryItems ?? []
        
        queryItems.append(URLQueryItem(name: "client_id", value: Constants.client_id))
        
        urlComponent.queryItems = queryItems
        guard let url = urlComponent.url else { return }
        authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "SearchApp") { callbackURL, error in
            
            guard error == nil, let callbackURL = callbackURL else {
                AlertView.show(title: "Auth error", message: "You need to auth for continue", in: self)
                return
            }
            
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            guard let code = queryItems?.filter({ $0.name == "code" }).first?.value else { return }
            
            self.viewModel.auth(code) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        authSession?.presentationContextProvider = self
        authSession?.start()
    }
}

extension AuthViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        self.view.window ?? ASPresentationAnchor()
    }
}
