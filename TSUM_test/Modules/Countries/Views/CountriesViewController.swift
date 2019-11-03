//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import RxSwift
import RxDataSources
import RxCocoa

class CountriesViewController: UIViewController {

    private let _tableView = UITableView()
    private let _refreshControl = UIRefreshControl()
    private let _spinner = UIActivityIndicatorView()
    
    private let _bag = DisposeBag()
    private let service = CountriesService()
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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(_tableView, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        view.addSubview(_spinner, constraints: [equal(\.centerYAnchor),
                                                equal(\.centerXAnchor)])
        _spinner.startAnimating()
        
        _tableView.register(CountryShortDataCell.self,
                            forCellReuseIdentifier: String(describing: CountryShortDataCell.self))
        _tableView.refreshControl = _refreshControl
        
        _tableView.rx.modelSelected(CountryShortDataCell.ViewState.self)
            .subscribe(onNext: { [weak self] model in
                print("name: \(model.name)")
                let vc = CountryInfoViewController()
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: _bag)
        
        _refreshControl.rx
            .controlEvent(UIControlEvents.valueChanged)
            .subscribe(onNext: { _ in
                print("refresh")
            })
            .disposed(by: _bag)
        
        service
            .request()
            .asObservable()
            .map { countries -> [CountriesSectionModel] in
                return countries.map { CountriesSectionModel.init(model: "",
                                                                  items: [($0.name, $0.population)]) }
            }
            .bind(to: _tableView.rx.items(dataSource: _dataSource))
            .disposed(by: _bag)
    }
}
