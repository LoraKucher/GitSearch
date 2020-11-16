import RxSwift
import RxCocoa

struct GitHubSearchRepositoriesState {

    var searchText: String
    var shouldLoadNextPage: Bool
    var repositories: [Repository]
    var nextURL: URL?
    var failure: GitHubServiceError?

    init(searchText: String) {
        self.searchText = searchText
        shouldLoadNextPage = true
        repositories = []
        nextURL = URL(string: "https://api.github.com/search/repositories?q=\(searchText)&sort=stars&order=desc")
        failure = nil
    }
}

extension GitHubSearchRepositoriesState {
    static let initial = GitHubSearchRepositoriesState(searchText: "")

    static func reduce(state: GitHubSearchRepositoriesState, command: GitHubCommand) -> GitHubSearchRepositoriesState {
        switch command {
        case .changeSearch(let text):
            return GitHubSearchRepositoriesState(searchText: text).mutateOne { $0.failure = state.failure }
        case .gitHubResponseReceived(let result):
            switch result {
            case let .success((repositories, nextURL)):
                return state.mutate {
                    $0.repositories = $0.repositories + repositories
                    $0.shouldLoadNextPage = false
                    $0.nextURL = nextURL
                    $0.failure = nil
                }
            case let .failure(error):
                return state.mutateOne { $0.failure = error }
            }
        case .loadMoreItems:
            return state.mutate {
                if $0.failure == nil {
                    $0.shouldLoadNextPage = true
                }
            }
        }
    }
}

extension GitHubSearchRepositoriesState: Mutable {
    var isOffline: Bool {
        guard let failure = self.failure else {
            return false
        }
        return .offline == failure ? true : false
    }

    var isLimitExceeded: Bool {
        guard let failure = self.failure else {
            return false
        }
        return .githubLimitReached == failure ? true : false
    }
}

