//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct CountryInfoViewModel {
    private var _country = PublishSubject<CountryInfo>()
    private var _bag = DisposeBag()

    // Output
    var countryInfo: Driver<CountryInfo> {
        return _country.asDriver(onErrorDriveWith: .empty())
    }
    
    // Input
    var loadInfo = PublishSubject<Void>()
    
    init(countryName: String, requestCountryInfo: @escaping CountryInfoRequester) {
        loadInfo
            .startWith(())
            .flatMap { _ in requestCountryInfo(countryName) }
            .filterNil()
            .bind(to: _country)
            .disposed(by: _bag)
    }
}
