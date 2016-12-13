//
//  HSLColorView.swift
//  AirArt
//
//  Created by Aditya Ayyakad on 12/8/16.
//  Copyright © 2016 Adi. All rights reserved.
//

import UIKit

@IBDesignable
class HSColorView: HSBView {

    let crosshairView = CrosshairView()

    override func setup() {
        super.setup()

        addSubview(crosshairView)
    }

}

// MARK: - Action

extension HSColorView {

    func updateCrosshairs() {
        let colorHue = Utility.clamp(hue * frame.width, min: 0, max: bounds.width)
        let colorSat = Utility.clamp(sat * frame.height, min: 0, max: bounds.height)

        crosshairView.move(to: CGPoint(x: colorHue, y: colorSat))
    }

}

// MARK: - Gesture Recognizers

extension HSColorView {

    override func recognize(_ gesture: UIGestureRecognizer) {
        let point = gesture.location(in: self)
        let clampedPoint = CGPoint(x: Utility.clamp(point.x, min: 0, max: bounds.width),
                                   y: Utility.clamp(point.y, min: 0, max: bounds.height))

        let newHue = clampedPoint.x / frame.width
        let newSat = clampedPoint.y / frame.height

        var update = false

        if newHue != hue {
            hue = newHue
            update = true
        }

        if newSat != sat {
            sat = newSat
            update = true
        }

        if update {
            updateCrosshairs()
        }
    }

}

// MARK: - Draw

extension HSColorView {

    override func draw(_ rect: CGRect) {
        createHSL()
    }

    /**
     Creates the actual background of HSL generated colors
     */
    private func createHSL() {
        guard let context = UIGraphicsGetCurrentContext() else {
            NSLog("Could not get current context")
            return
        }

        for hue in 0..<Int(bounds.maxX) {
            for sat in 0..<Int(bounds.maxY) {
                UIColor(hue: CGFloat(hue)/bounds.maxX,
                        saturation: CGFloat(sat)/bounds.maxY,
                        brightness: brightness,
                        alpha: colorAlpha).setFill()

                context.fill(CGRect(x: hue, y: sat, width: 1, height: 1))
            }
        }
    }

}

class CrosshairView: UIView {

    public static let size: CGFloat = 10.0

    // MARK: - Inits

    convenience init() {
        self.init(frame: CGRect(origin: .zero, size: CGSize(width: CrosshairView.size,
                                                            height: CrosshairView.size)))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    // MARK: - Setup

    func setup() {
        center = CGPoint(x: CrosshairView.size / 2, y: CrosshairView.size / 2)

        let shapeLayer = CAShapeLayer()

        shapeLayer.path = createCrosshairs().cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = UIColor.clear.cgColor

        layer.addSublayer(shapeLayer)
    }

    // MARK: - Action

    func move(to point: CGPoint) {
        center = point
    }

    // MARK: - UIBezierPath Creator

    private func createCrosshairs() -> UIBezierPath {
        // circle
        let crosshairs = UIBezierPath(ovalIn: bounds)

        // top of the cross
        crosshairs.move(to: CGPoint(x: center.x, y: center.y - CrosshairView.size))
        crosshairs.addLine(to: CGPoint(x: center.x, y: center.y + CrosshairView.size))

        // bottom of cross
        crosshairs.move(to: CGPoint(x: center.x - CrosshairView.size, y: center.y))
        crosshairs.addLine(to: CGPoint(x: center.x + CrosshairView.size, y: center.y))

        return crosshairs
    }

}
