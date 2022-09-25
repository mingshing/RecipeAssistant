//
//  RecipeDirectionCell.swift
//  RecipeAssistant
//
//  Created by mingshing on 2022/8/16.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit

class RecipeDirectionsCell: UITableViewCell {
    /*
    let stepLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    */
    
    let directionsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 80, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor(named: "textBlack")
        return label
    }()
    
    let requireIngredientLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor(named: "textBlack")
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //backgroundColor = .red
        selectionStyle = .none
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        /*
        contentView.addSubview(stepLabel)
        stepLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        */
        
        contentView.addSubview(directionsLabel)
        contentView.addSubview(requireIngredientLabel)
        directionsLabel.snp.makeConstraints { make in
            make.right.left.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(40)
        }
        
        requireIngredientLabel.snp.makeConstraints { make in
            make.left.right.equalTo(directionsLabel)
            make.top.equalTo(directionsLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview().inset(40)
        }
    }
}
