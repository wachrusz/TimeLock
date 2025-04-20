//
//  HomeCellView.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 18.04.2025.
//

import UIKit

// MARK: - Custom Cell
final class HomeCell: UITableViewCell {
    private let codeLabel = UILabel()
    private let sourceLabel = UILabel()
    private let indicatorView = UIView()
    private let innerContainer = UIView()
    private let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with entity: HomeEntity) {
        codeLabel.text = entity.code
        sourceLabel.text = entity.source
        let total = 30.0
        let remaining = Double(entity.timeRemaining)
        let ratio = CGFloat(remaining / total)
        indicatorView.frame.size.width = 200 * ratio
    }

    private func setup() {
        containerView.backgroundColor = UIColor(named: "entity")
        containerView.layer.cornerRadius = 24
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        innerContainer.backgroundColor = UIColor(named: "button")
        innerContainer.layer.cornerRadius = 12
        innerContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(innerContainer)

        codeLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        codeLabel.textColor = UIColor(named: "text")

        sourceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sourceLabel.textColor = UIColor(named: "sub")

        indicatorView.backgroundColor = UIColor(named: "indicator")
        indicatorView.layer.cornerRadius = 15
        indicatorView.translatesAutoresizingMaskIntoConstraints = false

        let labelStack = UIStackView(arrangedSubviews: [codeLabel, sourceLabel, indicatorView])
        labelStack.axis = .vertical
        labelStack.spacing = 6
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(labelStack)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            innerContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            innerContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            innerContainer.widthAnchor.constraint(equalToConstant: 48),
            innerContainer.heightAnchor.constraint(equalToConstant: 48),

            labelStack.leadingAnchor.constraint(equalTo: innerContainer.trailingAnchor, constant: 16),
            labelStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            labelStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            labelStack.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),

            indicatorView.heightAnchor.constraint(equalToConstant: 11)
        ])
    }
}
