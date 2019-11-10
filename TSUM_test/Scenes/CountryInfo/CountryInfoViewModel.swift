//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct CountryInfoViewModel {
    private var _country = PublishSubject<CountryInfoResult>()
    private var _bag = DisposeBag()

    // Output
    var countryInfo: Driver<CountryInfoResult> {
        return _country.asDriver(onErrorDriveWith: .empty())
    }
    
    // Input
    var loadInfo = PublishSubject<Void>()
    
    init(countryName: String, requestCountryInfo: @escaping CountryInfoRequester) {
        loadInfo
            .startWith(())
            .flatMap { _ in requestCountryInfo(countryName) }
            .bind(to: _country)
            .disposed(by: _bag)
    }
}

extension CountryInfoResult {
    var country: CountryInfo? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
    var error: CountriesService.CountryError? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
}
