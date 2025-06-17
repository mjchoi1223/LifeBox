//
//  RouletteViewController.swift
//  LifeBox
//
//  Created by 최민준 on 6/14/25.
//

import UIKit

class RouletteViewController: UIViewController {
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var rouletteView: UIView!
    
    var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemTextField.keyboardType = .default
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let radius = min(rouletteView.bounds.width, rouletteView.bounds.height) / 2
        rouletteView.layer.cornerRadius = radius
        rouletteView.clipsToBounds = true
        rouletteView.backgroundColor = .clear
        view.backgroundColor = .systemBackground
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let text = itemTextField.text, !text.isEmpty else { return }
        items.append(text)
        itemTextField.text = ""
        drawRoulette()
    }
    
    @IBAction func spinButtonTapped(_ sender: UIButton) {
        spinRoulette()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        items.removeAll()
        rouletteView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func drawRoulette() {
        rouletteView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let radius = min(rouletteView.bounds.width, rouletteView.bounds.height) / 2
        let center = CGPoint(x: rouletteView.bounds.midX, y: rouletteView.bounds.midY)
        let count = items.count
        
        guard count > 0 else { return }
        
        let anglePerItem = CGFloat(Double.pi * 2) / CGFloat(count)
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemTeal, .brown, .magenta]
        
        for i in 0..<count {
            let startAngle = anglePerItem * CGFloat(i)
            let endAngle = startAngle + anglePerItem
            
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true)
            
            let slice = CAShapeLayer()
            slice.path = path.cgPath
            slice.fillColor = colors[i % colors.count].cgColor
            rouletteView.layer.addSublayer(slice)
            
            let midAngle = (startAngle + endAngle) / 2
            let textLayer = CATextLayer()
            textLayer.string = items[i]
            textLayer.fontSize = 14
            textLayer.foregroundColor = UIColor.white.cgColor
            textLayer.alignmentMode = .center
            textLayer.contentsScale = UIScreen.main.scale
            
            let textRadius = radius * 0.65
            let x = center.x + textRadius * cos(midAngle) - 30
            let y = center.y + textRadius * sin(midAngle) - 10
            textLayer.frame = CGRect(x: x, y: y, width: 60, height: 20)
            
            rouletteView.layer.addSublayer(textLayer)
        }
    }
        
    func spinRoulette() {
        guard items.count > 0 else { return }

        let fullRotation = CGFloat.pi * 2
        let randomRounds = CGFloat(Int.random(in: 10...15))
        let randomOffset = CGFloat.random(in: 0..<fullRotation)
        let totalRotation = fullRotation * randomRounds + randomOffset

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = totalRotation
        rotationAnimation.duration = 2.5
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = .forwards

        rouletteView.layer.add(rotationAnimation, forKey: "spin")
    }
}
