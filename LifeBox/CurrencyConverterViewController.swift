//
//  CurrencyConverterViewController.swift
//  LifeBox
//
//  Created by 최민준 on 6/14/25.
//

import UIKit

struct FrankfurterResponse: Codable {
    let rates: [String: Double]
}

class CurrencyConverterViewController: UIViewController {
    @IBOutlet weak var fromCurrencySegment: UISegmentedControl!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var toCurrencySegment: UISegmentedControl!
    @IBOutlet weak var resultLabel: UILabel!
    
    let currencyList = ["KRW", "USD", "JPY", "EUR"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.keyboardType = .decimalPad
        
        fromCurrencySegment.selectedSegmentIndex = 0
        toCurrencySegment.selectedSegmentIndex = 1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func converButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        convertCurrency()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func convertCurrency() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText) else {
            resultLabel.text = "금액을 정확히 입력하세요."
            return
        }

        let fromCurrency = currencyList[fromCurrencySegment.selectedSegmentIndex]
        let toCurrency = currencyList[toCurrencySegment.selectedSegmentIndex]

        if fromCurrency == toCurrency {
            resultLabel.text = "\(amount) \(toCurrency)"
            return
        }

        let urlStr = "https://api.frankfurter.app/latest?amount=\(amount)&from=\(fromCurrency)&to=\(toCurrency)"

        guard let url = URL(string: urlStr) else {
            resultLabel.text = "잘못된 URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.resultLabel.text = "\(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.resultLabel.text = "데이터가 없습니다."
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(FrankfurterResponse.self, from: data)
                if let converted = decoded.rates[toCurrency] {
                    DispatchQueue.main.async {
                        let formatted = String(format: "%.2f", converted)
                        self.resultLabel.text = "\(formatted) \(toCurrency)"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.resultLabel.text = "환율 정보 없음"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.resultLabel.text = "\(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
