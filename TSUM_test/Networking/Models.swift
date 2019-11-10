//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

struct Country {
    let name: String
    let population: Int
}

struct CountryInfo {
    let name: String
    let capital: String
    let population: Int
    let borders: [String]
    let currencies: [Currency]
}

struct Currency {
    let code: String
    let name: String
    let symbol: String
}

