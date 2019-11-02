//
//  CountriesTarget.swift
//  TSUM_test
//

import Moya

enum CountriesTarget {
    case countries
}
extension CountriesTarget: TargetType {
    var baseURL: URL {
        return URL(string: "https://restcountries.eu/")!
    }
    
    var path: String {
        return "/rest/v2/all"
    }
    
    var method: Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .countries:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var sampleData: Data {
        return Data()
    }
}

struct CountriesResponse: Codable {
    let countries: [CountryResponse]
}
struct CountryResponse: Codable {
    let name: String
}
