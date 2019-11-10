//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxReachability
import Reachability

struct CountriesViewModel {
    enum LoadError: Error { case noConnection }
    typealias LoadResult = Result<[Country], LoadError>
    private var _loadResult = BehaviorRelay<LoadResult>(value: .success([]))
    private var _isReachable = BehaviorRelay<Bool>(value: true)
    
    private let _reachability: Reachability?
    private let _bag = DisposeBag()
    
    // Input
    var loadCountries = PublishSubject<Void>()
    
    // Output
    var loadResult: Driver<LoadResult> {
        return _loadResult.asDriver()
    }
    var networkReachable: Driver<Bool> {
        return _isReachable.asDriver()
    }
    
    init(requestCountries: @escaping AllCountriesRequester, reachability: Reachability?) {
        _reachability = reachability
        try? _reachability?.startNotifier()
        
        _reachability?.rx.isReachable
            .bind(to: _isReachable)
            .disposed(by: _bag)
        
        loadCountries
            .startWith(())
            .flatMap(requestCountries)
            .map { .success($0) }
            .bind(to: _loadResult)
            .disposed(by: _bag)
    }
}

extension CountriesViewModel.LoadResult {
    var countries: [Country]? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
    var error: CountriesViewModel.LoadError? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
}
