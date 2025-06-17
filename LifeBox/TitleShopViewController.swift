//
//  TitleShopViewController.swift
//  LifeBox
//
//  Created by 최민준 on 6/16/25.
//

import UIKit
import FirebaseFirestore

struct TitleItem {
    let name: String
    let price: Int
}

class TitleShopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let documentID = "defaultUser"

    var points: Int = 0
    var selectedTitle: String?
    var ownedTitles: [String] = []

    let titles: [TitleItem] = [
        TitleItem(name: "도박왕", price: 100),
        TitleItem(name: "행운의 사나이", price: 150),
        TitleItem(name: "포인트부자", price: 200)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        fetchData()
    }

    func fetchData() {
        db.collection("users").document(documentID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.points = data["points"] as? Int ?? 0
                self.selectedTitle = data["selectedTitle"] as? String
                self.ownedTitles = data["titlesOwned"] as? [String] ?? []
            }
            DispatchQueue.main.async {
                self.pointLabel.text = "보유 포인트: \(self.points)P"
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = titles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "TitleCell")

        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "가격: \(item.price)P"

        if selectedTitle == item.name {
            cell.accessoryType = .checkmark
            cell.detailTextLabel?.text = "장착됨"
        } else if ownedTitles.contains(item.name) {
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = "보유 중 - 누르면 장착"
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = titles[indexPath.row]

        if ownedTitles.contains(item.name) {
            if selectedTitle == item.name {
                selectedTitle = nil
                saveTitleSelection()
                showAlert(title: "칭호 해제", message: "칭호가 해제되었습니다.")
            } else {
                selectedTitle = item.name
                saveTitleSelection()
                showAlert(title: "칭호 장착", message: "'\(item.name)' 칭호를 장착했습니다.")
            }
        } else {
            if points >= item.price {
                points -= item.price
                ownedTitles.append(item.name)
                selectedTitle = item.name
                savePurchase()
                showAlert(title: "구매 완료", message: "'\(item.name)' 칭호를 구매하고 장착했습니다.")
            } else {
                showAlert(title: "포인트 부족", message: "해당 칭호를 구매하기엔 포인트가 부족합니다.")
            }
        }

        DispatchQueue.main.async {
            self.pointLabel.text = "보유 포인트: \(self.points)P"
            self.tableView.reloadData()
        }
    }

    func savePurchase() {
        db.collection("users").document(documentID).updateData([
            "points": self.points,
            "titlesOwned": self.ownedTitles,
            "selectedTitle": self.selectedTitle ?? ""
        ]) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }

    func saveTitleSelection() {
        db.collection("users").document(documentID).updateData([
            "selectedTitle": self.selectedTitle ?? ""
        ]) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
