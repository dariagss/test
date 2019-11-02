//
//  ViewController.swift
//  TSUM_test
//
//  Created by Artem Viter on 01/11/2019.
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import RxSwift

class ViewController: UIViewController {

    let bag = DisposeBag()
    let service = CountriesService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service
            .request()
            .subscribe(onSuccess: { countries in
                print("got: \(countries)")
            })
            .disposed(by: bag)
    }
}

