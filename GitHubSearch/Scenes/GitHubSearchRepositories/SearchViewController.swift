import UIKit
import RxSwift
import RxCocoa
import Foundation

public protocol SectionModelType {
    associatedtype Item
    
    var items: [Item] { get }
    
    init(original: Self, items: [Item])
}

class SearchViewController: UIViewController, UITableViewDelegate {
    static let startLoadingOffset: CGFloat = 20.0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var disposeBag = DisposeBag()
    var viewModel: SearchViewModel!
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>(
        configureCell: { (_, tv, ip, repository: Repository) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = repository.name
            cell.detailTextLabel?.text = repository.url
            return cell
    },
        titleForHeaderInSection: { dataSource, sectionIndex in
            let section = dataSource[sectionIndex]
            return section.items.count > 0 ? "Repositories (\(section.items.count))" : "No repositories found"
    }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView: UITableView = self.tableView
        
        let loadNextPageTrigger: (Driver<GitHubSearchRepositoriesState>) -> Signal<()> =  { state in
            tableView.rx.contentOffset.asDriver()
                .withLatestFrom(state)
                .flatMap { state in
                    return tableView.isNearBottomEdge(edgeOffset: 20.0) && !state.shouldLoadNextPage
                        ? Signal.just(())
                        : Signal.empty()
            }
        }
        
        let searchBar: UISearchBar = self.searchBar
        
        let state = viewModel.githubSearchRepositories(
            searchText: searchBar.rx.text.orEmpty.changed.asSignal().throttle(.milliseconds(300)),
            loadNextPageTrigger: loadNextPageTrigger,
            performSearch: { URL in
                self.viewModel.request(with: URL)
        })
        
        state
            .map { $0.isOffline }
            .drive(navigationController!.rx.isOffline)
            .disposed(by: disposeBag)
        
        state
            .map { $0.repositories }
            .map { [SectionModel(model: "Repositories", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        tableView.rx.modelSelected(Repository.self)
            .bind { repository in
                guard let url = URL(string: repository.url) else { return }
                
                UIApplication.shared.open(url)
                StorageRepository().saveRepository(from: repository)
        }
        .disposed(by: disposeBag)
        
        state
            .map { $0.isLimitExceeded }
            .distinctUntilChanged()
            .filter { $0 }
            .drive(onNext: { [weak self] n in
                guard let self = self else { return }
                
                let message = "Exceeded limit of 10 non authenticated requests per minute for GitHub API. Please wait a minute. :(\nhttps://developer.github.com/v3/#rate-limiting"
                
                self.present(UIAlertController(title: "GitHubSearch", message: message, preferredStyle: .alert), animated: true)
                
            })
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .subscribe { _ in
                if searchBar.isFirstResponder {
                    _ = searchBar.resignFirstResponder()
                }
        }
        .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
}

protocol Mutable {}

extension Mutable {
    func mutateOne<T>(transform: (inout Self) -> T) -> Self {
        var newSelf = self
        _ = transform(&newSelf)
        return newSelf
    }
    
    func mutate(transform: (inout Self) -> Void) -> Self {
        var newSelf = self
        transform(&newSelf)
        return newSelf
    }
    
    func mutate(transform: (inout Self) throws -> Void) rethrows -> Self {
        var newSelf = self
        try transform(&newSelf)
        return newSelf
    }
}

