//
//  HomeCellView.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 18.04.2025.
//

import UIKit

final class HomeCell: UITableViewCell {

    private let codeLabel = UILabel()
    private let sourceLabel = UILabel()
    private let logoImageView = UIImageView()
    private let containerView = UIView()

    private var panGesture: UIPanGestureRecognizer!
    private var originalCenter: CGPoint = .zero
    private var deleteOnRelease = false
    private var copiedCode: String?
    var onDelete: (() -> Void)?
    var onCopy: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setupSwipeGesture()
    }

    func resetTransform() {
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = .identity
        }
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        containerView.addGestureRecognizer(tap)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let code = copiedCode else { return }
        UIPasteboard.general.string = code
        
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        
        onCopy?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with entity: HomeEntity) {
        codeLabel.text = formattedCode(entity.code)
        sourceLabel.text = entity.source
        
        copiedCode = entity.code
        
        let icon = IconGenerator.shared.generateIdenticon(from: entity.secret, size: 51)
        logoImageView.image = icon
    }

    private func formattedCode(_ code: String) -> String {
        let clean = code.filter(\.isNumber)
        guard clean.count == 6 else { return code }
        let padded = clean.padding(toLength: 6, withPad: "0", startingAt: 0)
        let first = padded.prefix(3)
        let last = padded.suffix(3)
        return "\(first)-\(last)"
    }

    private func setupSwipeGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: containerView)

        switch gesture.state {
        case .began:
            originalCenter = center
        case .changed:
            let limitedTranslationX = min(0, translation.x)
            containerView.transform = CGAffineTransform(translationX: limitedTranslationX, y: 0)
            deleteOnRelease = limitedTranslationX < -containerView.frame.size.width / 2
        case .ended, .cancelled:
            if deleteOnRelease {
                UIView.animate(withDuration: 0.2) {
                    self.containerView.transform = CGAffineTransform(translationX: -100, y: 0)
                } completion: { _ in
                    self.onDelete?()
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    UIView.animate(withDuration: 0.2) {
                        self.containerView.transform = .identity
                    }
                }
            }
        default:
            break
        }
    }
    
    func resetPosition() {
        containerView.transform = .identity
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        let deleteBackgroundView = UIView()
        deleteBackgroundView.backgroundColor = .systemRed
        deleteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deleteBackgroundView)
        deleteBackgroundView.layer.cornerRadius = 24

        NSLayoutConstraint.activate([
            deleteBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            deleteBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            deleteBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        let trashIcon = UIImageView(image: UIImage(systemName: "trash.fill"))
        trashIcon.tintColor = .white
        trashIcon.translatesAutoresizingMaskIntoConstraints = false
        deleteBackgroundView.addSubview(trashIcon)

        NSLayoutConstraint.activate([
            trashIcon.centerYAnchor.constraint(equalTo: deleteBackgroundView.centerYAnchor),
            trashIcon.trailingAnchor.constraint(equalTo: deleteBackgroundView.trailingAnchor, constant: -24)
        ])

        containerView.backgroundColor = UIColor(named: "entity")
        containerView.layer.cornerRadius = 24
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        contentView.bringSubviewToFront(containerView)

        logoImageView.backgroundColor = UIColor(named: "button")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.cornerRadius = 12
        logoImageView.clipsToBounds = true
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        codeLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        codeLabel.textColor = UIColor(named: "text")

        sourceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sourceLabel.textColor = UIColor(named: "sub")

        let labelStack = UIStackView(arrangedSubviews: [codeLabel, sourceLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 5
        labelStack.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(logoImageView)
        containerView.addSubview(labelStack)

        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            logoImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            logoImageView.widthAnchor.constraint(equalToConstant: 51),
            logoImageView.heightAnchor.constraint(equalToConstant: 51),

            labelStack.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 16),
            labelStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            labelStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            labelStack.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
        
        setupTapGesture()
    }
}
