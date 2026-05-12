//
//  SearchWalkAddressContentViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/31/25.
//

import Combine
import UIKit

final class SearchWalkAddressContentViewController: UIViewController, UITextFieldDelegate {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: FindWalkViewModel
    
    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(named: "cancel"), for: .normal)
    }
    
    private let searchTextField = UITextField()
    
    private let searchButton = UIButton().then {
        $0.setImage(UIImage(named: "magnifyingGlass"), for: .normal)
    }
                
    private let locationButton = UIButton()
    
    private lazy var searchedResultTableView = SearchedResultTableView(viewModel: viewModel)
    
    init(viewModel: FindWalkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        searchTextField.delegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func bind() {
        viewModel.$positionResponse.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            self?.searchTextField.text = response.roadAddress
        }.store(in: &subscriptions)
    }
}
extension SearchWalkAddressContentViewController {
    @objc private func locationButtonTapped() {
        viewModel.positionToAddress(lat: viewModel.nowLocation.y, lng: viewModel.nowLocation.x)
    }
    
    @objc private func searchButtonTapped() {
        view.endEditing(true)
        viewModel.searchAddressByKeyword(keyword: searchTextField.text ?? "")
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        viewModel.searchAddressByKeyword(keyword: textField.text ?? "")
        return true
    }
}

extension SearchWalkAddressContentViewController {
    private func setupLayOuts() {
        [cancelButton, searchTextField, searchButton, locationButton, searchedResultTableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        cancelButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }
        searchTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(8)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-8)
            $0.height.equalTo(32)
        }
        searchButton.snp.makeConstraints {
            $0.top.size.equalTo(cancelButton)
            $0.trailing.equalToSuperview().offset(-16)
        }
        locationButton.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(14)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(34)
        }
        searchedResultTableView.snp.makeConstraints {
            $0.top.equalTo(locationButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    private func setupComponents() {
        searchTextField.font = FontSet.pretendardSemiBold(size: 12)
        searchTextField.tintColor = .neutral7
        searchTextField.textColor = .dark
        searchTextField.backgroundColor = .neutral4
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 24))
        searchTextField.leftView = containerView
        searchTextField.leftViewMode = .always
        searchTextField.placeholder = "지명 검색"
        searchTextField.layer.masksToBounds = true
        searchTextField.layer.cornerRadius = 5
        
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "location")
        var text = AttributedString("현재 위치로 찾기")
        text.font = FontSet.pretendardMedium(size: 14)
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .dark
        configuration.attributedTitle = text
        locationButton.configuration = configuration
        locationButton.layer.borderWidth = 1
        locationButton.layer.cornerRadius = 5
        locationButton.layer.masksToBounds = true
        locationButton.layer.borderColor = ColorSet.neutral5.cgColor
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
