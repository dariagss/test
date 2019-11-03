//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CountryInfoViewController: UIViewController {
    let service = CountriesService()
    let _bag = DisposeBag()
    
    private let _nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    private let _capitalNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    private let _populationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    private let _bordersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    private let _currenciesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let _spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.addArrangedSubview(_nameLabel)
        stackView.addArrangedSubview(_capitalNameLabel)
        stackView.addArrangedSubview(_populationLabel)
        stackView.addArrangedSubview(_bordersLabel)
        stackView.addArrangedSubview(_currenciesLabel)
        
        view.addSubview(stackView, constraints: [
            equal(\.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16)
        ])
        view.addSubview(_spinner, constraints: [equal(\.centerYAnchor),
                                                equal(\.centerXAnchor)])
        _spinner.startAnimating()
        
        service.requestInfo(name: "Spain")
            .asObservable()
            .map { $0.first }
            .map { ViewState.init(name: $0!.name,
                                  capital: $0!.capital,
                                  population: $0!.population,
                                  borders: $0!.borders,
                                  currencies: ["some 1", "some 2"])
            }
            .subscribe(onNext: { [weak self] (state) in
                self?._spinner.stopAnimating()
                self?.render(state: state)
            })
            .disposed(by: _bag)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(state: ViewState) {
        _nameLabel.text = state.name
        _capitalNameLabel.text = "Capital: \(state.capital)"
        _populationLabel.text = "Population: \(state.population)"
        _bordersLabel.text = "Borders: some"
        _currenciesLabel.text = "Currencies: some"
    }
}

extension CountryInfoViewController {
    struct ViewState {
        let name: String
        let capital: String
        let population: Int
        let borders: [String]
        let currencies: [String]
    }
}
