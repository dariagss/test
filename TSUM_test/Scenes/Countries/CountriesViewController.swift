//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import RxSwift
import RxDataSources
import RxCocoa
import RxOptional

class CountriesViewController: UIViewController {

    private let _tableView = UITableView()
    private let _refreshControl = UIRefreshControl()
    private let _spinner = UIActivityIndicatorView()
    private let _noConnectionView = NoConnectionView()
    
    private let _bag = DisposeBag()
    private let _viewModel: CountriesViewModel
    
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
    
    init(viewModel: CountriesViewModel) {
        _viewModel = viewModel
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
        view.addSubview(_noConnectionView, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor)
        ])
        view.addSubview(_spinner, constraints: [equal(\.centerYAnchor),
                                                equal(\.centerXAnchor)])
        
        _tableView.register(CountryShortDataCell.self,
                            forCellReuseIdentifier: String(describing: CountryShortDataCell.self))
        _tableView.refreshControl = _refreshControl
        
        _tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] in
                self?._tableView.deselectRow(at: $0, animated: true)
            })
            .disposed(by: _bag)
        
        _tableView.rx.modelSelected(CountryShortDataCell.ViewState.self)
            .subscribe(onNext: { [weak self] model in
                let vc = CountryInfoViewController(viewModel: .init(countryName: model.name,
                                                                    requestCountryInfo: CountriesService().requestInfo))
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: _bag)
        
        _refreshControl.rx
            .controlEvent(UIControlEvents.valueChanged)
            .subscribe(onNext: { [weak self] _ in
                self?._spinner.startAnimating()
                self?._viewModel.loadCountries.onNext(())
            })
            .disposed(by: _bag)
        
        let loadResult = _viewModel.loadResult
            .do(onNext: { [weak self] _ in
                self?._refreshControl.endRefreshing()
                self?._spinner.stopAnimating()
            })
        loadResult
            .map { $0.countries }
            .filterNil()
            .map { $0.map { .init(model: "", items: [($0.name, $0.population)]) } }
            .drive(_tableView.rx.items(dataSource: _dataSource))
            .disposed(by: _bag)
        
        loadResult
            .map { $0.error }
            .filterNil()
            .drive(onNext: { [weak self] error in
                switch error {
                case .noConnection:
                    print("dar error")
                }
            })
            .disposed(by: _bag)
        
        _viewModel.networkReachable
            .drive(onNext: { [weak self] isReachable in
                self?._noConnectionView.isHidden = isReachable
                self?._noConnectionView.render(state: "No network connection")
            })
            .disposed(by: _bag)
        
    }
}

class NoConnectionView: UIView {
    let _title: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 64)
    }
    init() {
        super.init(frame: .zero)
        backgroundColor = .red
        addSubview(_title, constraints: [
            equal(\.bottomAnchor, constant: -10),
            equal(\.leadingAnchor, constant: 16),
            equal(\.centerXAnchor)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func render(state: String) {
        _title.text = state
    }
}
