//
//  DogCertViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/21/25.
//

import Combine
import UIKit

final class DogCertViewController: UIViewController  {
    
    // MARK: - Properties
    private let viewModel: ModifyDogViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let registNumberTextField = BindableTextFieldView(title: "동물 등록번호") .then {
        $0.setPlaceHolder(text: "12자리 또는 15자리 숫자")
    }
    
    private let nameTextField = BindableTextFieldView(title: "견주명") .then {
        $0.setPlaceHolder(text: "견주 이름")
    }
    
    private let certButton = BottomPlacedButton().then {
        $0.setTitle("강아지 인증", for: .normal)
    }
    
    init(viewModel: ModifyDogViewModel) {
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
        hideKeyboardWhenTappedAround()
        certButton.addTarget(self, action: #selector(certButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getDogCertInfoValidRequest = .init(ownerName: "", registNumber: "")
        setNavigationTitle("강아지 등록번호 인증")
    }
    
    // MARK: - Bind
    
    private func bind() {
        registNumberTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.getDogCertInfoValidRequest.registNumber = text
        }.store(in: &subscriptions)
        nameTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.getDogCertInfoValidRequest.ownerName = text
        }.store(in: &subscriptions)
        
        viewModel.$certButtonEnabled.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] enabled in
                self?.certButton.setupButtonStatus(isSelected: enabled)
            }.store(in: &subscriptions)
        
        viewModel.certSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] enabled in
            self?.navigationController?.popViewController(animated: true)
            ToastMessenger.shared.showToast(message: "인증번호 등록이 완료되었습니다.")
            }.store(in: &subscriptions)
    }
}

extension DogCertViewController {
    @objc private func certButtonTapped() {
        viewModel.getDogCertValidInfo()
    }
}

extension DogCertViewController {
    
    private func setupLayOuts() {
        [registNumberTextField, nameTextField, certButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        registNumberTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(registNumberTextField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        certButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

