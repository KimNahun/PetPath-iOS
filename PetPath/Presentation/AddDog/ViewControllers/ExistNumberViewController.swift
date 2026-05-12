//
//  ExistNumberViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Combine
import UIKit

final class ExistNumberViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: AddDogViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let numberCaptionTextField = BindableCaptionTextField(title: "동물 등록번호", mode: .common).then {
        $0.setPlaceHolder(text: "12자리 숫자 또는 15자리 숫자")
    }
    
    private let ownerNameTextField = BindableTextFieldView(title: "견주명").then {
        $0.setPlaceHolder(text: "견주 이름")
    }
    private let birthdayLabel = UILabel().then {
        $0.text = "강아지 생일"
        $0.font = FontSet.pretendardBold(size: 12)
        $0.textColor = .neutral6
    }
    private let yearDropdownButton = DropdownButton(placeholder: "년 선택", font: FontSet.pretendardMedium(size: 14), selectedTextColor: .dark)
    private let monthDropdownButton = DropdownButton(placeholder: "월 선택", font: FontSet.pretendardMedium(size: 14), selectedTextColor: .dark)
    private let certButton = BottomPlacedButton().then {
        $0.setTitle("강아지 인증", for: .normal)
    }
    
    init(viewModel: AddDogViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        certButton.addTarget(self, action: #selector(certButtonTapped), for: .touchUpInside)
        hideKeyboardWhenTappedAround()
        setupDropdownItems()
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNavigationTitle("강아지 등록")
    }
    // MARK: - Bind
    
    private func bind() {
        numberCaptionTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.registRequest.registNumber = text
        }.store(in: &subscriptions)
        
        ownerNameTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.registRequest.ownerName = text
        }.store(in: &subscriptions)
        
        yearDropdownButton.selectedItemPublisher.sink { [weak self] item in
            self?.viewModel.registRequest.birthYear = item.title.replacingOccurrences(of: "년", with: "")
        }.store(in: &subscriptions)
        
        monthDropdownButton.selectedItemPublisher.sink { [weak self] item in
            self?.viewModel.registRequest.birthMonth = item.title.replacingOccurrences(of: "월", with: "")
        }.store(in: &subscriptions)
        
        
        viewModel.$isCertButtonEnabled.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isEnable in
            self?.certButton.setupButtonStatus(isSelected: isEnable)
        }.store(in: &subscriptions)
        
        viewModel.certSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            guard let strongSelf = self else { return }
            self?.navigationController?.pushViewController(DogInfoViewController(viewModel: strongSelf.viewModel), animated: true)
        }.store(in: &subscriptions)
    }
    private func setupDropdownItems() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearItems = (2000...currentYear).map { DropdownItem(id: nil, title: "\($0)년") }.reversed()
        let monthItems = (1...12).map { DropdownItem(id: nil, title: "\($0)월") }
        
        yearDropdownButton.setDropdown(items: Array(yearItems))
        monthDropdownButton.setDropdown(items: monthItems)
    }
}

extension ExistNumberViewController {
    @objc private func certButtonTapped() {
        viewModel.getCertInfo()
    }
    
}

extension ExistNumberViewController {
    
    private func setupLayOuts() {
        [numberCaptionTextField, ownerNameTextField, birthdayLabel, yearDropdownButton, monthDropdownButton, certButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        numberCaptionTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(79)
        }
        ownerNameTextField.snp.makeConstraints {
            $0.top.equalTo(numberCaptionTextField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        birthdayLabel.snp.makeConstraints {
            $0.top.equalTo(ownerNameTextField.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        yearDropdownButton.snp.makeConstraints {
            $0.top.equalTo(birthdayLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(view.snp.centerX).inset(4)
            $0.height.equalTo(40)
        }
        monthDropdownButton.snp.makeConstraints {
            $0.bottom.equalTo(yearDropdownButton)
            $0.height.equalTo(40)
            $0.leading.equalTo(yearDropdownButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
        }
        certButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    private func setupComponents() {
        [yearDropdownButton, monthDropdownButton].forEach {
            $0.layer.borderWidth = 2
            $0.layer.cornerRadius = 8
            $0.layer.borderColor = ColorSet.neutral6.cgColor
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

