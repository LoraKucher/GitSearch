import UIKit
import RxSwift
import RxCocoa

open class RxTableViewSectionedReloadDataSource<Section: SectionModelType>
    : TableViewSectionedDataSource<Section>
    , RxTableViewDataSourceType {
    public typealias Element = [Section]

    open func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, element in
            dataSource.setSections(element)
            tableView.reloadData()
        }.on(observedEvent)
    }
}
