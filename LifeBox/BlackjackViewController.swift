//
//  BlackjackViewController.swift
//  LifeBox
//
//  Created by 최민준 on 6/14/25.
//

import UIKit
import FirebaseFirestore

class BlackjackViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    let todayKey = "lastCheckInDate"
    let pointKey = "userPoints"
    
    let db = Firestore.firestore()
    let documentID = "defaultUser"
    
    let deck = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    var playerCards: [String] = []
    var dealerCards: [String] = []
    var isGameOver = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPointFromFirestoreToLabel()
        loadSelectedTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSelectedTitle()
    }

    @IBAction func checkAttendanceButtonTapped(_ sender: UIButton) {
        if alreadyCheckedInToday() {
            showAlert(title: "알림", message: "이미 출석했습니다.")
        } else {
            loadPointFromFirestore { current in
                let newPoint = current + 10
                self.savePointToFirestore(newPoint)
                
                DispatchQueue.main.async {
                    self.pointLabel.text = "현재 포인트: \(newPoint)P"
                }

                self.saveToday()
                self.showAlert(title: "출석 완료", message: "+10포인트가 지급되었습니다.")
            }
        }
    }
    
    func loadPointFromFirestore(completion: @escaping (Int) -> Void) {
        db.collection("users").document(documentID).getDocument { snapshot, error in
            if let doc = snapshot, doc.exists {
                let data = doc.data()
                let point = data?["points"] as? Int ?? 0
                completion(point)
            } else {
                print("포인트 문서 없음")
                completion(0)
            }
        }
    }
    
    func loadPointFromFirestoreToLabel() {
        db.collection("users").document(documentID).getDocument { snapshot, error in
            if let doc = snapshot, doc.exists {
                let data = doc.data()
                let point = data?["points"] as? Int ?? 0
                DispatchQueue.main.async {
                    self.pointLabel.text = "현재 포인트: \(point)P"
                }
            } else {
                DispatchQueue.main.async {
                    self.pointLabel.text = "현재 포인트: 0P"
                }
            }
        }
    }
    
    func savePointToFirestore(_ points: Int) {
        db.collection("users").document(documentID).setData([
            "points": points
        ], merge: true) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    func alreadyCheckedInToday() -> Bool {
        guard let lastDate = userDefaults.string(forKey: todayKey) else { return false }
        return lastDate == currentDateString()
    }

    func saveToday() {
        userDefaults.set(currentDateString(), forKey: todayKey)
    }

    func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func loadSelectedTitle() {
        db.collection("users").document(documentID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                let selectedTitle = data["selectedTitle"] as? String ?? ""
                DispatchQueue.main.async {
                    if selectedTitle.isEmpty {
                        self.titleLabel.text = "칭호 없음"
                    } else {
                        self.titleLabel.text = "칭호: \(selectedTitle)"
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var playerCardsLabel: UILabel!
    @IBOutlet weak var dealerCardsLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func hitButtonTapped(_ sender: UIButton) {
        guard !playerCards.isEmpty && !dealerCards.isEmpty else {
            showGameStartAlert()
            return
        }

        if isGameOver { return }

        playerCards.append(drawCard())
        let score = calculateScore(playerCards)
        
        if score > 21 {
            isGameOver = true
            resultLabel.text = "💥 버스트! 패배"
            updateUI()
            updatePointAfterGame(delta: -5)
            return
        }

        updateUI()
    }
    
    @IBAction func standButtonTapped(_ sender: UIButton) {
        guard !playerCards.isEmpty && !dealerCards.isEmpty else {
            showGameStartAlert()
            return
        }

        if isGameOver { return }

        while calculateScore(dealerCards) < 17 {
            dealerCards.append(drawCard())
        }

        let playerScore = calculateScore(playerCards)
        let dealerScore = calculateScore(dealerCards)

        isGameOver = true

        var resultMessage = ""
        var pointDelta = 0

        if dealerScore > 21 || playerScore > dealerScore {
            resultMessage = "🎉 승리!"
            pointDelta = 10
        } else if playerScore == dealerScore {
            resultMessage = "😐 무승부"
            pointDelta = 0
        } else {
            resultMessage = "😭 패배"
            pointDelta = -5
        }

        resultLabel.text = resultMessage
        updateUI()
        updatePointAfterGame(delta: pointDelta)
    }
    
    @IBAction func newGameButtonTapped(_ sender: UIButton) {
        startNewGame()
        resultLabel.text = ""
    }
    
    func calculateScore(_ cards: [String]) -> Int {
        var total = 0
        var aceCount = 0

        for card in cards {
            switch card {
            case "A":
                aceCount += 1
                total += 11
            case "K", "Q", "J":
                total += 10
            default:
                total += Int(card) ?? 0
            }
        }

        while total > 21 && aceCount > 0 {
            total -= 10
            aceCount -= 1
        }

        return total
    }
    
    func startNewGame() {
        playerCards = [drawCard(), drawCard()]
        dealerCards = [drawCard(), drawCard()]
        isGameOver = false
        updateUI()
    }
    
    func drawCard() -> String {
        return deck.randomElement() ?? "A"
    }
    
    func updateUI() {
        playerCardsLabel.text = "플레이어: " + playerCards.joined(separator: ", ") + " (\(calculateScore(playerCards)))"
        
        let dealerScore = calculateScore(dealerCards)
        let dealerVisible = isGameOver ? dealerCards : [dealerCards.first ?? "?"] + Array(repeating: "?", count: dealerCards.count - 1)
        dealerCardsLabel.text = "딜러: " + dealerVisible.joined(separator: ", ") + (isGameOver ? " (\(dealerScore))" : "")
    }
    
    func showGameStartAlert() {
        let alert = UIAlertController(title: "알림", message: "먼저 '새게임' 버튼을 눌러주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func updatePointAfterGame(delta: Int) {
        db.collection("users").document(documentID).getDocument { snapshot, error in
            if let doc = snapshot, doc.exists {
                let data = doc.data()
                let current = data?["points"] as? Int ?? 0
                let newPoint = max(0, current + delta)

                self.db.collection("users").document(self.documentID).setData([
                    "points": newPoint
                ], merge: true) { error in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.pointLabel.text = "현재 포인트: \(newPoint)P"
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func shopButtonTapped(_ sender: UIButton) {
    }
}
