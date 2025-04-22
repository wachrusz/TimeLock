//
//  IndicatorView.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 21.04.2025.
//

import UIKit

final class GlobalProgressIndicator: UIView {
    private let foreground = UIView()
    private var widthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "indicatorBG")
        
        foreground.backgroundColor = UIColor(named: "indicatorFGSafe")
        foreground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(foreground)

        NSLayoutConstraint.activate([
            foreground.leadingAnchor.constraint(equalTo: leadingAnchor),
            foreground.topAnchor.constraint(equalTo: topAnchor),
            foreground.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        widthConstraint = foreground.widthAnchor.constraint(equalToConstant: 0)
        widthConstraint?.isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateProgress(ratio: CGFloat) {
        let clamped = max(0, min(ratio, 1))
        let targetColor = interpolatedColor(for: clamped)

        DispatchQueue.main.async {
            guard self.bounds.width > 0 else { return }
            self.widthConstraint?.constant = self.bounds.width * clamped
            UIView.animate(withDuration: 0.15) {
                self.foreground.backgroundColor = targetColor
                self.layoutIfNeeded()
            }
        }
    }

    private func interpolatedColor(for ratio: CGFloat) -> UIColor {
        let clamped = max(0, min(ratio, 1))

        let safe = UIColor(named: "indicatorFGSafe") ?? .green
        let medium = UIColor(named: "indicatorFGMedium") ?? .yellow
        let warning = UIColor(named: "indicatorFGWarning") ?? .orange
        let critical = UIColor(named: "indicatorFGCritical") ?? .red

        switch clamped {
        case 0.75...1.0:
            return interpolate(from: safe, to: medium, percent: (1.0 - clamped) / 0.25)
        case 0.5..<0.75:
            return interpolate(from: medium, to: warning, percent: (0.75 - clamped) / 0.25)
        case 0.25..<0.5:
            return interpolate(from: warning, to: critical, percent: (0.5 - clamped) / 0.25)
        default:
            return critical
        }
    }

    private func interpolate(from: UIColor, to: UIColor, percent: CGFloat) -> UIColor {
        var fRed: CGFloat = 0, fGreen: CGFloat = 0, fBlue: CGFloat = 0, fAlpha: CGFloat = 0
        var tRed: CGFloat = 0, tGreen: CGFloat = 0, tBlue: CGFloat = 0, tAlpha: CGFloat = 0

        from.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        to.getRed(&tRed, green: &tGreen, blue: &tBlue, alpha: &tAlpha)

        let red = fRed + (tRed - fRed) * percent
        let green = fGreen + (tGreen - fGreen) * percent
        let blue = fBlue + (tBlue - fBlue) * percent
        let alpha = fAlpha + (tAlpha - fAlpha) * percent

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

final class GlobalProgressIndicatorManager {
    static let shared = GlobalProgressIndicatorManager()
    
    private var indicator: GlobalProgressIndicator?
    
    private init() {}

    func attach(to window: UIWindow) {
        guard indicator == nil else { return }

        let bar = GlobalProgressIndicator()
        bar.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(bar)

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            bar.heightAnchor.constraint(equalToConstant: 4)
        ])
        
        self.indicator = bar
    }

    func update(ratio: CGFloat) {
        indicator?.updateProgress(ratio: ratio)
    }
}

