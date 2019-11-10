//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import RxSwift
import Moya

typealias CountryInfoResult = Result<CountryInfo, CountriesService.CountryError>

typealias AllCountriesRequester = () -> Single<[Country]>
typealias CountryInfoRequester = (String) -> Single<CountryInfoResult>

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
    func requestInfo(name: String) -> Single<Result<CountryInfo, CountryError>> {
        return _provider.rx
            .request(.country(name))
            .filterSuccessfulStatusCodes()
            .map([CountryInfoResponse].self)
            .map { response -> CountryInfo? in
                return response.first.map { .init(name: $0.name,
                                                  capital: $0.capital,
                                                  population: $0.population,
                                                  borders: $0.borders,
                                                  currencies: $0.currencies.map { .init(code: $0.code,
                                                                                        name: $0.name,
                                                                                        symbol: $0.symbol) })
                }
            }
            .map {
                if let country = $0 {
                    return .success(country)
                } else {
                    return .failure(.noSuchCountry)
                }
            }
            .catchErrorJustReturn(.failure(.unknown))
    }
}

extension CountriesService {
    enum CountryError: Error {
        case unknown, noSuchCountry
    }
}
