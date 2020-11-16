import Foundation
import RxSwift
import RxCocoa

typealias EmptyBlock = () -> ()

class AuthViewModel {
    struct Dependencies {
        let api: APIProvider
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func auth(_ code: String, completion: @escaping EmptyBlock) {
        guard let searchURL = URL(string: "https://github.com/login/oauth/access_token?client_id=\(Constants.client_id)&client_secret=\(Constants.client_secret)&code=\(code)") else {
        preconditionFailure("Auth URL is invalid.")
        }
        dependencies.api.auth(searchURL) { token in
            guard let token = token else { return }
            
            StorageAccessToken().saveToken(from: token)
            completion()
        }
    }
}
