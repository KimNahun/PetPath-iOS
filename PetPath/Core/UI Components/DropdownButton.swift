//
//  DropdownButton.swift
//  PetPath
//
//  Created by 김나훈 on 4/26/25.
//

import UIKit
import Combine
import DropDown

struct DropdownItem: Identifiable, Equatable {
    let id: String?
    let title: String
}

final class DropdownButton: UIView {
    
    // MARK: - UI Components
    private let button = UIButton(type: .system)
    private let dropdownImage = UIImageView(image: UIImage(named: "chevronDown"))
    private let dropDown = DropDown()
    
    // MARK: - Data
    private var items: [DropdownItem] = []
    private var selectedItem: DropdownItem?
    private let placeholder: String
    private let font: UIFont
    private let placeholderTextColor: UIColor
    private let selectedTextColor: UIColor
    
    // MARK: - Publishers
    let selectedItemPublisher = PassthroughSubject<DropdownItem, Never>()
    
    // MARK: - Initialization
    init(
        placeholder: String,
        font: UIFont = FontSet.pretendardSemiBold(size: 12),
        placeholderTextColor: UIColor = .neutral6,
        selectedTextColor: UIColor = .neutral10
    ) {
        self.placeholder = placeholder
        self.font = font
        self.placeholderTextColor = placeholderTextColor
        self.selectedTextColor = selectedTextColor
        super.init(frame: .zero)
        setupUI()
        configureDropDown()
        updateButton(title: placeholder, isPlaceholder: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // View styling
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        clipsToBounds = true
        
        // Button styling
        button.setTitleColor(.neutral6, for: .normal)
        button.contentHorizontalAlignment = .left
        var config = UIButton.Configuration.plain()
        config.title = placeholder
        config.baseForegroundColor = .neutral6
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 32)
        config.imagePadding = 4
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(showDropdown), for: .touchUpInside)
        
        // Add button to view
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Dropdown image styling
        dropdownImage.contentMode = .scaleAspectFit
        dropdownImage.tintColor = .gray
        addSubview(dropdownImage)
        dropdownImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dropdownImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            dropdownImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            dropdownImage.widthAnchor.constraint(equalToConstant: 16),
            dropdownImage.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    // MARK: - DropDown Configuration
    private func configureDropDown() {
        dropDown.anchorView = self
        dropDown.bottomOffset = CGPoint(x: 0, y: 40)
        dropDown.direction = .bottom
        dropDown.dismissMode = .automatic
        
        dropDown.selectionAction = { [weak self] index, title in
            guard let self = self else { return }
            let item = self.items[index]
            self.selectedItem = item
            self.updateButton(title: item.title, isPlaceholder: false)
            self.selectedItemPublisher.send(item)
        }
    }
    func setSelectedItem(title: String) {
        if let item = items.first(where: { $0.title == title }) {
            selectedItem = item
            updateButton(title: item.title, isPlaceholder: false)
        }
    }
    // MARK: - Public Methods
    func setDropdown(items: [DropdownItem]) {
        self.items = items
        dropDown.dataSource = items.map { $0.title }
    }
    
    func setPlaceholder(_ placeholder: String) {
        updateButton(title: placeholder, isPlaceholder: true)
    }
    
    // MARK: - Actions
    @objc private func showDropdown() {
        dropDown.show()
    }
    
    // MARK: - Helper Methods
    private func updateButton(title: String, isPlaceholder: Bool) {
            var config = button.configuration ?? UIButton.Configuration.plain()
            
            let color = isPlaceholder ? placeholderTextColor : selectedTextColor
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: color,
                .font: font
            ]
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            config.attributedTitle = AttributedString(attributedTitle)
            
            button.configuration = config
        }
}
