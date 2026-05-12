//
//  LocationContentViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/24/25.
//

import Combine
import UIKit

final class LocationContentViewController: UIViewController, UITextFieldDelegate {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: RequestWalkViewModel
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "chevronLeft"), for: .normal)
    }
    private let messageLabel = UILabel().then {
        $0.text = "픽업 위치 설정"
        $0.textColor = .dark
        $0.font = FontSet.pretendardBold(size: 20)
    }
    private let searchTextField = SearchTextField(placeHolder: "지번, 도로명, 건물명으로 검색")
    
    private let findButton = UIButton()
    
    private lazy var recentPickupTableView = RecentPickupTableView(viewModel: viewModel)
    
    private lazy var searchedAddressTableView = SearchAddressTableView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private lazy var setNowLocationView = SetNowLocationView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    init(viewModel: RequestWalkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        hideKeyboardWhenTappedAround()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        findButton.addTarget(self, action: #selector(findButtonTapped), for: .touchUpInside)
        setupUI()
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNowLocationView.isHidden = true
        searchedAddressTableView.isHidden = true
    }
    
    private func bind() {
        
        recentPickupTableView.selectCellPublisher.sink { [weak self] in
            self?.dismiss(animated: true)
        }.store(in: &subscriptions)
        
        searchedAddressTableView.cellIndexPublisher.receive(on: DispatchQueue.main).sink { [weak self] index in
            self?.setNowLocationView.moveCamera(index: index)
        }.store(in: &subscriptions)
        
        setNowLocationView.selectPublisher.sink { [weak self] in
            self?.dismiss(animated: true)
        }.store(in: &subscriptions)
    }
}

extension LocationContentViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let keyword = textField.text, !keyword.isEmpty else { return false }
        textField.resignFirstResponder()
        viewModel.searchAddressByKeyword(keyword: keyword)
        return true
    }
    
    @objc private func findButtonTapped() {
        view.endEditing(true)
        setNowLocationView.isHidden = false
    }
    
    @objc private func backButtonTapped() {
        if !setNowLocationView.isHidden {
            setNowLocationView.isHidden = true
        } else if !searchedAddressTableView.isHidden {
            searchedAddressTableView.isHidden = true
        } else {
            dismiss(animated: true)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension LocationContentViewController {
    private func setupLayOuts() {
        [backButton, messageLabel, searchTextField, findButton, recentPickupTableView, searchedAddressTableView, setNowLocationView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(19)
            $0.size.equalTo(24)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        setNowLocationView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(43)
        }
        findButton.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(34)
        }
        recentPickupTableView.snp.makeConstraints {
            $0.top.equalTo(findButton.snp.bottom).offset(16)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        searchedAddressTableView.snp.makeConstraints {
            $0.top.equalTo(findButton.snp.bottom).offset(16)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setupComponents() {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "location")
        var text = AttributedString("현재 위치로 찾기")
        text.font = FontSet.pretendardMedium(size: 14)
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .dark
        configuration.attributedTitle = text
        findButton.configuration = configuration
        findButton.layer.borderWidth = 1
        findButton.layer.cornerRadius = 5
        findButton.layer.masksToBounds = true
        findButton.layer.borderColor = ColorSet.neutral5.cgColor
        
    }
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
