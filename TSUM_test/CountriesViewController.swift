//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import RxSwift
import RxDataSources

class CountriesViewController: UIViewController {

    let _tableView = UITableView()
    
    let bag = DisposeBag()
    let service = CountriesService()
    let items = PublishSubject<CountriesSectionModel>()
    
    typealias CountriesSectionModel = SectionModel<String, CountryShortDataCell.ViewState>
    typealias DataSource = RxTableViewSectionedReloadDataSource<CountriesSectionModel>
    private lazy var _dataSource: DataSource = { () -> DataSource in
        return .init(configureCell: { [weak self] _, tv, ip, item in
            guard let self = self else { return UITableViewCell() }
            let cell = tv.dequeueReusableCell(withIdentifier: String(describing: CountryShortDataCell.self),
                                              for: ip) as! CountryShortDataCell
            cell.render(with: item)
            return cell
        })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(_tableView, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        _tableView.register(CountryShortDataCell.self,
                            forCellReuseIdentifier: String(describing: CountryShortDataCell.self))
        
        service
            .request().asObservable()
            .map { countries -> [CountriesSectionModel] in
                return countries.map { CountriesSectionModel.init(model: "",
                                                                  items: [($0.name, $0.population)]) }
            }
        .   bind(to: _tableView.rx.items(dataSource: _dataSource))
            .disposed(by: bag)
    }
}
