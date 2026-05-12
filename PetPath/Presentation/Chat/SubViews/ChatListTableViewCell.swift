//
//  ChatListTableViewCell.swift
//  PetPath
//
//  Created by 김나훈 on 4/29/25.
//

import Combine
import UIKit

final class ChatListTableViewCell: UITableViewCell {
    
    private let dogImageView = AspectFitImageView()
    
    private let dogNameLabel = UILabel()
    
    private let recentMessageLabel = UILabel()
    
    private let timeLabel = UILabel()
    
    private let unreadChatCountLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: GetChatRoomListDTO) {
        if let imageUrl = item.profileImage.first {
            dogImageView.loadImage(url: imageUrl)
        }
        dogNameLabel.text = item.title
        recentMessageLabel.text = item.lastChatContent
        
        // --- 여기부터 날짜 포맷 처리 ---
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var date = isoFormatter.date(from: item.lastChatAt ?? "")
        if date == nil {
            isoFormatter.formatOptions = [.withInternetDateTime]
            date = isoFormatter.date(from: item.lastChatAt ?? "")
        }
        
        guard let date else {
            timeLabel.text = ""
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "a h:mm"
            timeLabel.text = formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            timeLabel.text = "어제"
        } else if calendar.component(.year, from: now) == calendar.component(.year, from: date) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "M월 d일"
            timeLabel.text = formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yy년 M월 d일"
            timeLabel.text = formatter.string(from: date)
        }
        let unreadCount = item.unreadMessage ?? 0
        if unreadCount == 0 {
            unreadChatCountLabel.text = ""
            unreadChatCountLabel.isHidden = true
        } else {
            unreadChatCountLabel.text = "\(unreadCount)"
            unreadChatCountLabel.isHidden = false
            
//            unreadChatCountLabel.snp.updateConstraints {
//                $0.width.equalTo(unreadChatCountLabel.intrinsicContentSize.width + 8)
//            }
            
        }
    }
    
}

extension ChatListTableViewCell {
    
}

extension ChatListTableViewCell {
    private func setupLayouts() {
        [dogImageView, dogNameLabel, timeLabel, recentMessageLabel, unreadChatCountLabel].forEach {
            contentView.addSubview($0)
        }
    }
    private func setupConstraints() {
        dogImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(72)
        }
        dogNameLabel.snp.makeConstraints {
            $0.top.equalTo(dogImageView)
            $0.leading.equalTo(dogImageView.snp.trailing).offset(16)
            $0.trailing.equalTo(timeLabel.snp.leading)
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(dogImageView)
            $0.trailing.equalToSuperview().offset(-17)
        }
        recentMessageLabel.snp.makeConstraints {
            $0.top.equalTo(dogNameLabel.snp.bottom).offset(8)
            $0.leading.equalTo(dogNameLabel)
            $0.trailing.equalTo(timeLabel.snp.leading)
        }
        unreadChatCountLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(9)
            $0.trailing.equalTo(timeLabel)
            $0.width.equalTo(16)
            $0.height.equalTo(16)
        }
    }
    private func setupComponents() {
        dogImageView.layer.masksToBounds = true
        dogImageView.layer.cornerRadius = 20
        dogImageView.backgroundColor = ColorSet.fromHex("D9D9D9")
        
        dogNameLabel.textColor = .dark
        dogNameLabel.font = FontSet.pretendardBold(size: 16)
        timeLabel.textColor = .neutral7
        timeLabel.font = FontSet.pretendardMedium(size: 10)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        recentMessageLabel.textColor = .neutral9
        recentMessageLabel.font = FontSet.pretendardMedium(size: 14)
        unreadChatCountLabel.textColor = .neutral9
        unreadChatCountLabel.font = FontSet.pretendardMedium(size: 10)
        unreadChatCountLabel.backgroundColor = ColorSet.fromHex("FEE773")
        unreadChatCountLabel.textAlignment = .center
        unreadChatCountLabel.layer.cornerRadius = 8
        unreadChatCountLabel.layer.masksToBounds = true
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
        contentView.backgroundColor = .systemBackground
    }
}

