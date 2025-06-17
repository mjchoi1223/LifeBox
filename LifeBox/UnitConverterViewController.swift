//
//  UnitConverterViewController.swift
//  LifeBox
//
//  Created by 최민준 on 6/14/25.
//

import UIKit

class UnitConverterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var unitTypeSegment: UISegmentedControl!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var fromPicker: UIPickerView!
    @IBOutlet weak var toPicker: UIPickerView!
    @IBOutlet weak var resultLabel: UILabel!
    
    let unitOptions: [[String]] = [
        ["mm", "cm", "m", "km", "inch"],
        ["°C", "°F"],
    ]

    var selectedFromUnit: String = "mm"
    var selectedToUnit: String = "cm"

    override func viewDidLoad() {
        super.viewDidLoad()
        fromPicker.dataSource = self
        fromPicker.delegate = self
        toPicker.dataSource = self
        toPicker.delegate = self
        updatePickerUnits()
        valueTextField.keyboardType = .decimalPad
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func unitTpyeCahnged(_ sender: UISegmentedControl) {
        updatePickerUnits()
    }
    
    @IBAction func converButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        convertValue()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func updatePickerUnits() {
        fromPicker.reloadAllComponents()
        toPicker.reloadAllComponents()

        fromPicker.selectRow(0, inComponent: 0, animated: false)
        toPicker.selectRow(1, inComponent: 0, animated: false)

        selectedFromUnit = unitOptions[unitTypeSegment.selectedSegmentIndex][0]
        selectedToUnit = unitOptions[unitTypeSegment.selectedSegmentIndex][1]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unitOptions[unitTypeSegment.selectedSegmentIndex].count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return unitOptions[unitTypeSegment.selectedSegmentIndex][row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = unitOptions[unitTypeSegment.selectedSegmentIndex][row]
        if pickerView == fromPicker {
            selectedFromUnit = selected
        } else {
            selectedToUnit = selected
        }
    }

    func convertValue() {
        guard let inputText = valueTextField.text, let input = Double(inputText) else {
            resultLabel.text = "값을 정확히 입력하세요."
            return
        }

        let typeIndex = unitTypeSegment.selectedSegmentIndex

        switch typeIndex {
        case 0:
            let result = convertLength(value: input, from: selectedFromUnit, to: selectedToUnit)
            resultLabel.text = "\(result) \(selectedToUnit)"

        case 1:
            let result = convertTemperature(value: input, from: selectedFromUnit, to: selectedToUnit)
            resultLabel.text = "\(result) \(selectedToUnit)"

        default:
            resultLabel.text = "지원하지 않는 단위입니다."
        }
    }
    
    func convertLength(value: Double, from: String, to: String) -> Double {
        let base: [String: Double] = [
            "mm": 1.0,
            "cm": 10.0,
            "m": 1_000.0,
            "inch": 25.4,
            "km": 1_000_000.0
        ]
        if let fromFactor = base[from], let toFactor = base[to] {
            return (value * fromFactor) / toFactor
        }
        return value
    }

    func convertTemperature(value: Double, from: String, to: String) -> Double {
        if from == to {
            return value
        } else if from == "°C" && to == "°F" {
            return value * 9 / 5 + 32
        } else if from == "°F" && to == "°C" {
            return (value - 32) * 5 / 9
        }
        return value
    }
}
