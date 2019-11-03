//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import RxSwift
import Moya

struct Country {
    let name: String
    let population: Int
}

struct CountriesService {
    private let _provider: MoyaProvider<CountriesTarget>
    
    init(provider: MoyaProvider<CountriesTarget> = MoyaProvider<CountriesTarget>()) {
        _provider = provider
    }
    
    func request() -> Single<[Country]> {
        return _provider.rx
            .request(.countries)
            .filterSuccessfulStatusCodes()
            .catchError { throw $0 }
            .map([CountryResponse].self)
            .map {
                $0.map { Country(name: $0.name,
                                 population: $0.population) }
        }
    }
    func requestInfo(name: String) -> Single<[CountryInfoResponse]> {
        return _provider.rx
            .request(.country(name))
            .catchError { throw $0 }
            .map([CountryInfoResponse].self)
    }
}

