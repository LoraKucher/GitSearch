import UIKit
import RxSwift
import RxCocoa

final class HistoryViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }
    
    private let disposeBag = DisposeBag()
    var viewModel: HistoryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.output
            .repositories
            .asObservable()
            .bind(to: self.tableView.rx.items(cellIdentifier: "HistoryCell"))  { _, user, cell in
                cell.textLabel?.text = user.name
                cell.detailTextLabel?.text = user.url
        }.disposed(by: self.disposeBag)
    }
}
