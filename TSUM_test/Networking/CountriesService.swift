//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import RxSwift
import Moya

typealias AllCountriesRequester = () -> Single<[Country]>
typealias CountryInfoRequester = (String) -> Single<CountryInfo?>

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
            .map { $0.map { .init(name: $0.name, population: $0.population) } }
    }
    func requestInfo(name: String) -> Single<CountryInfo?> {
        return _provider.rx
            .request(.country(name))
            .catchError { throw $0 }
            .map([CountryInfoResponse].self)
            .map { $0.map { .init(name: $0.name,
                                  capital: $0.capital,
                                  population: $0.population,
                                  borders: $0.borders,
                                  currencies: $0.currencies.map { .init(code: $0.code,
                                                                        name: $0.name,
                                                                        symbol: $0.symbol) })
            }.first
        }
    }
}

