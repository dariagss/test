//
//  CountriesTarget.swift
//  TSUM_test
//

import Moya

enum CountriesTarget {
    case countries, country(String)
}
extension CountriesTarget: TargetType {
    var baseURL: URL {
        return URL(string: "https://restcountries.eu/")!
    }
    
    var path: String {
        switch self {
        case .countries:
            return "/rest/v2/all"
        case .country(let name):
            return "/rest/v2/name/" + name
        }
    }
    
    var method: Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var sampleData: Data {
        return Data()
    }
}

struct CountryResponse: Codable {
    let name: String
    let population: Int
}
struct CountryInfoResponse: Codable {
    let name: String
    let capital: String
    let population: Int
    let borders: [String]
    let currencies: [CurrencyResponse]
}
struct CurrencyResponse: Codable {
    let code: String
    let name: String
    let symbol: String
}
