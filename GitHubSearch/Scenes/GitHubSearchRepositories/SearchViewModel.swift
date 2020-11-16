import RxSwift
import RxCocoa
import Foundation
import Dispatch

enum GitHubCommand {
    case changeSearch(text: String)
    case loadMoreItems
    case gitHubResponseReceived(SearchRepositoriesResponse)
}

struct GithubQuery: Equatable {
    let searchText: String;
    let shouldLoadNextPage: Bool;
    let nextURL: URL?
}

class Dependencies {

    static let sharedDependencies = Dependencies()
    
    let URLSession = Foundation.URLSession.shared
    let backgroundWorkScheduler: ImmediateSchedulerType
    let mainScheduler: SerialDispatchQueueScheduler
    
    private init() {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = QualityOfService.background
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
        
        mainScheduler = MainScheduler.instance
    }
    
}

final class SearchViewModel {
    struct Dependencies {
        let api: APIProvider
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func request(with url: URL) -> Observable<SearchRepositoriesResponse> {
        return dependencies.api.loadSearchURL(url)
    }
    
    func githubSearchRepositories(
            searchText: Signal<String>,
            loadNextPageTrigger: @escaping (Driver<GitHubSearchRepositoriesState>) -> Signal<()>,
            performSearch: @escaping (URL) -> Observable<SearchRepositoriesResponse>
        ) -> Driver<GitHubSearchRepositoriesState> {

        let searchPerformerFeedback: (Driver<GitHubSearchRepositoriesState>) -> Signal<GitHubCommand> = react(
            query: { (state) in
                GithubQuery(searchText: state.searchText, shouldLoadNextPage: state.shouldLoadNextPage, nextURL: state.nextURL)
            },
            effects: { query -> Signal<GitHubCommand> in
                    if !query.shouldLoadNextPage {
                        return Signal.empty()
                    }

                    if query.searchText.isEmpty {
                        return Signal.just(GitHubCommand.gitHubResponseReceived(.success((repositories: [], nextURL: nil))))
                    }

                    guard let nextURL = query.nextURL else {
                        return Signal.empty()
                    }

                    return performSearch(nextURL)
                        .asSignal(onErrorJustReturn: .failure(GitHubServiceError.networkError))
                        .map(GitHubCommand.gitHubResponseReceived)
                }
        )

        let inputFeedbackLoop: (Driver<GitHubSearchRepositoriesState>) -> Signal<GitHubCommand> = { state in
            let loadNextPage = loadNextPageTrigger(state).map { _ in GitHubCommand.loadMoreItems }
            let searchText = searchText.map(GitHubCommand.changeSearch)

            return Signal.merge(loadNextPage, searchText)
        }

        return Driver.system(
            initialState: GitHubSearchRepositoriesState.initial,
            reduce: GitHubSearchRepositoriesState.reduce,
            feedback: searchPerformerFeedback, inputFeedbackLoop
        )
    }
}

open class AsyncOperation: Operation {
  
  enum State: String {
    case ready, executing, finished
    
    fileprivate var keyPath: String {
      return "is" + rawValue.capitalized
    }
  }
  
  var state = State.ready {
    willSet {
      willChangeValue(forKey: newValue.keyPath)
      willChangeValue(forKey: state.keyPath)
    }
    didSet {
      didChangeValue(forKey: oldValue.keyPath)
      didChangeValue(forKey: state.keyPath)
    }
  }
  
}

extension AsyncOperation {
  
  override open var isReady: Bool {
    return super.isReady && state == .ready
  }
  
  override open var isExecuting: Bool {
    return state == .executing
  }
  
  override open var isFinished: Bool {
    return state == .finished
  }
  
  override open var isAsynchronous: Bool {
    return true
  }
  
  override open func start() {
    if isCancelled {
      state = .finished
      return
    }
    main()
    state = .executing
  }
  
  override open func cancel() {
    state = .finished
  }
}
