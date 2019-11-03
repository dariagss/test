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
            .subscribe(onSuccess: { res in
                print("res: \(res)")
            }) { er in
                print("error: \(er)")
            }
            .disposed(by: bag)
        
        service
            .requestInfo(name: "United Arab Emirates")
            .subscribe(onSuccess: { countries in
                print("got: \(countries)")
            })
            .disposed(by: bag)
    }
}

