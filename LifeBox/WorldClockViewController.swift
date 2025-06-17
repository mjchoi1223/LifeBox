//
//  WorldClockViewController.swift
//  LifeBox
//
//  Created by 최민준 on 6/14/25.
//

import UIKit

class WorldClockViewController: UIViewController {
    @IBOutlet weak var kstLabel: UILabel!
    @IBOutlet weak var utcLabel: UILabel!
    @IBOutlet weak var estLabel: UILabel!
    @IBOutlet weak var pstLabel: UILabel!
    @IBOutlet weak var gmtLabel: UILabel!
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startClockTimer()
    }
    
    func startClockTimer() {
         updateClocks()
         timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
             self.updateClocks()
         }
     }

    func updateClocks() {
        let now = Date()
        kstLabel.attributedText = formattedThreeLineTimeAttributed(for: now, in: "Asia/Seoul")
        utcLabel.attributedText = formattedThreeLineTimeAttributed(for: now, in: "UTC")
        estLabel.attributedText = formattedThreeLineTimeAttributed(for: now, in: "America/New_York")
        pstLabel.attributedText = formattedThreeLineTimeAttributed(for: now, in: "America/Los_Angeles")
        gmtLabel.attributedText = formattedThreeLineTimeAttributed(for: now, in: "GMT")
    }

    func formattedThreeLineTimeAttributed(for date: Date, in timeZoneID: String) -> NSAttributedString {
        guard let timeZone = TimeZone(identifier: timeZoneID) else {
            return NSAttributedString(string: "Invalid TimeZone")
        }

        let locale = Locale(identifier: "ko_KR")

        let timeZoneNames: [String: String] = [
            "Asia/Seoul": "대한민국 표준시 (KST)",
            "UTC": "협정 세계시 (UTC)",
            "America/New_York": "미국 동부 표준시 (EST)",
            "America/Los_Angeles": "태평양 표준시 (PST)",
            "GMT": "그리니치 표준시 (GMT)"
        ]
        
        let displayName = timeZoneNames[timeZoneID] ?? "\(timeZoneID)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.timeZone = timeZone
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let dateStr = dateFormatter.string(from: date)

        let timeFormatter = DateFormatter()
        timeFormatter.locale = locale
        timeFormatter.timeZone = timeZone
        timeFormatter.dateFormat = "a h시 mm분 ss초"
        let timeStr = timeFormatter.string(from: date)

        let fullText = "\(displayName)\n\(dateStr)\n\(timeStr)"
        let attributed = NSMutableAttributedString(string: fullText)

        let line1Range = (fullText as NSString).range(of: displayName)
        let boldFont = UIFont.boldSystemFont(ofSize: 17)

        attributed.addAttributes([
            .foregroundColor: UIColor.systemBlue,
            .font: boldFont
        ], range: line1Range)
        
        return attributed
    }
}
