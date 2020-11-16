import Foundation
import RxSwift
import RxCocoa

class HistoryViewModel {
    struct Output {
        let repositories: Driver<[SavedRepository]>
    }
    
    struct Dependencies {
        let api: StorageRepository
    }
    
    private let dependencies: Dependencies
    let output: Output

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.output = Output(repositories: dependencies.api.fetchSavedRepository().asDriver(onErrorJustReturn: []))
    }

}
