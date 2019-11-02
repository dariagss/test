//
//  CountriesService.swift
//  TSUM_test
//

import RxSwift
import Moya

struct Country {
    let name: String
    let population: Int
}

struct CountriesService {
    let provider = MoyaProvider<CountriesTarget>()
    
    func request() -> Single<[Country]> {
        return provider.rx
            .request(.countries)
            .map([CountryResponse].self)
            .map {
                $0.map { Country(name: $0.name,
                                 population: 10) }
        }
    }
}

