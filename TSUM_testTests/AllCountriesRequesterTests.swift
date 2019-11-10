//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import XCTest
@testable import TSUM_test
import RxSwift
import RxTest
import Moya

class AllCountriesRequesterTests: XCTestCase {
    let scheduler = TestScheduler(initialClock: 0)
    
    func testSuccess() {
        let service = makeService(response: { .networkResponse(200, CountriesTarget.countries.sampleData) })

        // Run
        let testObserver = scheduler.start {
            service.request().asObservable()
        }
        
        let expected = Country(name: "Spain", population: 123)
        
        // Test
        XCTAssertEqual(testObserver.events, [
            Recorded.next(200, [expected]),
            Recorded.completed(200)
            ])
    }
    
    func testError() {
        let error = MoyaError.requestMapping("")
        let service = makeService(response: { .networkError(error as NSError) })
        // Run
        let testObserver = scheduler.start {
            service.request().asObservable()
        }
        // Test
        XCTAssertEqual(testObserver.events, [
            Recorded.error(200, MoyaError.underlying(error, nil))
        ])
    }
    
    func makeService(response: @escaping Endpoint.SampleResponseClosure) -> CountriesService {
        let target = CountriesTarget.countries
        return .init(provider: .init(endpointClosure: { _ -> Endpoint in
            return .init(url: "https://restcountries.eu/rest/v2/all",
                         sampleResponseClosure: response,
                         method: target.method,
                         task: target.task,
                         httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub))
    }
}

