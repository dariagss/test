//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CountryInfoViewController: UIViewController {
    private let _viewModel: CountryInfoViewModel
    private let _bag = DisposeBag()
    
    private let _nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    private let _capitalNameLabel = InfoView()
    private let _populationLabel = InfoView()
    private let _bordersLabel = InfoView()
    private let _currenciesLabel = InfoView()
    
    private let _spinner = UIActivityIndicatorView()
    
    init(viewModel: CountryInfoViewModel) {
        _viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.addArrangedSubview(_capitalNameLabel)
        stackView.addArrangedSubview(_populationLabel)
        stackView.addArrangedSubview(_bordersLabel)
        stackView.addArrangedSubview(_currenciesLabel)
        
        view.addSubview(_nameLabel, constraints: [
            equal(\.topAnchor, constant: 20),
            equal(\.leadingAnchor, constant: Constants.sideOffset),
            equal(\.trailingAnchor, constant: -Constants.sideOffset)
        ])
        view.addSubview(stackView, constraints: [
            equal(\.topAnchor, to: _nameLabel, \.bottomAnchor, constant: 25),
            equal(\.leadingAnchor, constant: Constants.sideOffset),
            equal(\.trailingAnchor, constant: -Constants.sideOffset)
        ])
        view.addSubview(_spinner, constraints: [equal(\.centerYAnchor),
                                                equal(\.centerXAnchor)])
        _spinner.startAnimating()
        
        let info = _viewModel.countryInfo
            .map { $0.country }
            .filterNil()
        info
            .map { ViewState.init(name: $0.name,
                                  capital: $0.capital,
                                  population: $0.population,
                                  borders: $0.borders,
                                  currencies: $0.currencies.map { ($0.name, $0.symbol) })
            }
            .drive(onNext: { [weak self] state in
                self?._spinner.stopAnimating()
                self?.render(state: state)
            })
            .disposed(by: _bag)
        
        let error = _viewModel.countryInfo
            .map { $0.error }
            .filterNil()
        error
            .drive(onNext: { [weak self] error in
                self?._spinner.stopAnimating()
                self?.showErrorAlert(error: error)
            })
            .disposed(by: _bag)
    }
    
    func render(state: ViewState) {
        _nameLabel.text = state.name
        _capitalNameLabel.render(title: "Capital", info: state.capital)
        _populationLabel.render(title: "Population", info: "\(state.population)")
        _bordersLabel.render(title: "Borders", info: state.borders.joined(separator: ", "))
        let currencies = state.currencies.map { "\($0.symbol), \($0.name)" }
        _currenciesLabel.render(title: "Currencies", info: currencies.joined(separator: "\n"))
    }
    
    func showErrorAlert(error: CountriesService.CountryError) {
        let alert = UIAlertController(title: "Error",
                                      message: error.errorMessage,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in }))
        let isErrorFatal: Bool
        switch error {
        case .unknown:
            isErrorFatal = false
        case .noSuchCountry:
            isErrorFatal = true
        }
        if !isErrorFatal {
            alert.addAction(.init(title: "Try again", style: .default, handler: { [weak self] _ in
                self?._viewModel.loadInfo.onNext(())
            }))
        }
        present(alert, animated: true, completion: nil)
    }
}

extension CountryInfoViewController {
    struct ViewState {
        let name: String
        let capital: String
        let population: Int
        let borders: [String]
        let currencies: [(name: String, symbol: String)]
    }
}

private extension CountryInfoViewController {
    enum Constants {
        static let sideOffset = CGFloat(16)
    }
}

private extension CountriesService.CountryError {
    var errorMessage: String {
        switch self {
        case .unknown:
            return "Something went wrong. Plesae check network connection and try again."
        case .noSuchCountry:
            return "We couldn't find such country 😔"
        }
    }
}

class InfoView: UIView {
    private let _titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    private let _infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()

    init() {
        super.init(frame: .zero)
        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.addArrangedSubview(_titleLabel)
        stackView.addArrangedSubview(_infoLabel)
        stackView.alignment = .leading
        addSubview(stackView, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.topAnchor),
            equal(\.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(title: String, info: String) {
        _titleLabel.text = title + ":"
        _infoLabel.text = info.isNotEmpty ? info : "No info 😔"
    }
}
