//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import UIKit

class CountryShortDataCell: UITableViewCell {
    private let _nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    private let _populationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.addArrangedSubview(_nameLabel)
        stackView.addArrangedSubview(_populationLabel)
        
        contentView.addSubview(stackView, constraints: [
            equal(\.topAnchor, constant: 8),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.bottomAnchor, constant: -8)
        ])
    }
}

extension CountryShortDataCell {
    typealias ViewState = (name: String, population: Int)
    func render(with state: ViewState) {
        _nameLabel.text = state.name
        _populationLabel.text = "Population: \(state.population)"
    }
}
