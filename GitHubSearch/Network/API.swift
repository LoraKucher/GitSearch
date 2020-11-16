import Foundation
import RxSwift

enum GitHubServiceError: Error {
    case offline
    case githubLimitReached
    case networkError
}

typealias SearchRepositoriesResponse = Result<(repositories: [Repository], nextURL: URL?), GitHubServiceError>
typealias AuthResponse = Result<AuthTokenResponse, GitHubServiceError>

protocol APIProvider {
    func loadSearchURL(_ searchURL: URL) -> Observable<SearchRepositoriesResponse>
    func auth(_ searchURL: URL, completion: @escaping (AuthTokenResponse?) -> ())
}

final class API: APIProvider {
    
    func auth(_ searchURL: URL, completion: @escaping (AuthTokenResponse?) -> ()) {
        var request = URLRequest(url: searchURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared
            .dataTask(with: request, completionHandler: { (data, _, _) in
                guard let data = data else { return }
                let response = try? JSONDecoder().decode(AuthTokenResponse.self, from: data)
                
                completion(response)
            }).resume()
        
    }
    
    func loadSearchURL(_ searchURL: URL) -> Observable<SearchRepositoriesResponse> {
        var request = URLRequest(url: searchURL)
        
        if let token = StorageAccessToken().fetchToken()?.accessToken {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
        
        let oneQueue = URLSession.shared
            .rx.response(request: request)
            .retry(3)
            .observeOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
        
        let twoQueue = URLSession.shared
            .rx.response(request: request)
            .retry(3)
            .observeOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
        
        return Observable.merge(oneQueue, twoQueue)
            .map { [weak self] (response, data) -> SearchRepositoriesResponse in
                if response.statusCode == 403 { return .failure(.githubLimitReached) }
                
                let data = try self?.parseJSON(response, data: data, typeOf: RepositoryResponse.self)
                
                guard let repositories = data as? RepositoryResponse else {
                    preconditionFailure("Casting to type failed")
                }
                
                let nextURL = try Pagination.parseNextURL(response)
                
                return .success((repositories: repositories.items, nextURL: nextURL))
        }
    }
    
    private func parseJSON<T: Decodable>(_ httpResponse: HTTPURLResponse, data: Data, typeOf: T.Type) throws -> Decodable {
        if !(200 ..< 300 ~= httpResponse.statusCode) {
            assertionFailure("Call failed")
        }
        return try? JSONDecoder().decode(typeOf, from: data)
    }
}
