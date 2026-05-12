//
//  ModifyPayoutContractViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/3/25.
//

import Combine
import PhotosUI
import UIKit

final class ModifyPayoutContractViewController: UIViewController, PHPickerViewControllerDelegate {
    
    // MARK: - Properties
    private let viewModel: PayoutContractViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private enum UploadType {
        case account
        case identify
    }
    private var currentUploadType: UploadType?
    // MARK: - UI Components
    
    private let spinner = UIActivityIndicatorView(style: .large)
    
    private let identifyNumGuideLabel = UILabel().then {
        $0.text = "주민등록번호"
    }
    private let identifySubMessageLabel = UILabel().then {
        $0.text = "소득세법 - 제127조(원천징수의무)에 의거하여 국세청 신고에 필요한 정보입니다."
    }
    
    private let firstTextField = BindableTextField(numberPad: true).then {
        $0.placeholder = "000000"
    }
    
    private let separator = UILabel().then {
        $0.text = "-"
    }
    
    private let secondTextField = BindableTextField(mode: .secure, numberPad: true).then {
        $0.placeholder = "*******"
    }
    private let identifyWarningLabel = UILabel().then {
        $0.text = "*주민등록번호를 잘못 입력하면 수익금이 입금되지 않아요\n*계정에 가입된 본인 명의의 신분증만 등록 가능합니다"
        $0.numberOfLines = 2
    }
    
    private let identifyUploadButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("신분증 사본 업로드", for: .normal)
    }
    
    private let identifyDeniedReasonLabel = UILabel().then {
        $0.isHidden = true
    }
    
    private let identifyStatusLabel = UILabel().then {
        $0.text = "*선택된 파일 없음"
    }
    
    private let bankGuideLabel = UILabel().then {
        $0.text = "입금계좌 은행"
    }
    
    private let selectBankButton = DropdownButton(placeholder: "입금계좌 은행 선택")
    
    private let accountTextFieldView = BindableTextFieldView(title: "계좌번호", numberPad: true).then {
        $0.setPlaceHolder(text: "111111111111111")
    }
    
    private let accountWarningLabel = UILabel().then {
        $0.text = "*계좌번호를 잘못 입력하면 수익금이 입금되지 않아요"
    }
    
    private let nameTextFieldView = BindableTextFieldView(title: "예금주 명").then {
        $0.setPlaceHolder(text: "예금주 명")
    }
    
    private let nameWarningLabel = UILabel().then {
        $0.text = "*본인 명의의 계좌가 아니면 수익금이 입금되지 않아요"
    }
    private let bankUploadButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("통장 사본 업로드", for: .normal)
    }
    
    private let accountDeniedReasonLabel = UILabel().then {
        $0.isHidden = true
    }
    
    private let bankStatusLabel = UILabel().then {
        $0.text = "*선택된 파일 없음"
    }
    
    private let saveButton = BottomPlacedButton().then {
        $0.setTitle("저장", for: .normal)
    }
    init(viewModel: PayoutContractViewModel) {
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
        selectBankButton.setDropdown(items: [
            DropdownItem(id: nil, title: "우리은행"),
            DropdownItem(id: nil, title: "국민은행"),
            DropdownItem(id: nil, title: "기업은행"),
            DropdownItem(id: nil, title: "농협"),
            DropdownItem(id: nil, title: "산업은행"),
            DropdownItem(id: nil, title: "새마을금고"),
            DropdownItem(id: nil, title: "신한은행"),
            DropdownItem(id: nil, title: "우체국"),
            DropdownItem(id: nil, title: "카카오뱅크"),
            DropdownItem(id: nil, title: "케이뱅크"),
            DropdownItem(id: nil, title: "토스뱅크"),
            DropdownItem(id: nil, title: "하나은행")
        ])
        fillComponents()
        saveButton.setupButtonStatus(isSelected: viewModel.saveButtonEnabled)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        bankUploadButton.addTarget(self, action: #selector(bankUploadTapped), for: .touchUpInside)
        identifyUploadButton.addTarget(self, action: #selector(identifyUploadTapped), for: .touchUpInside)
        firstTextField.delegate = self
        secondTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("입금 계좌 정보 수정")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$saveButtonEnabled.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] status in
            self?.saveButton.setupButtonStatus(isSelected: status)
        }.store(in: &subscriptions)
        
        viewModel.successPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscriptions)
        
        firstTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.modifyRequest?.firstNum = text
        }.store(in: &subscriptions)
        
        secondTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.modifyRequest?.secondNum = text
        }.store(in: &subscriptions)
        
        selectBankButton.selectedItemPublisher.sink { [weak self] bank in
            self?.viewModel.modifyRequest?.bankName = bank.title
        }.store(in: &subscriptions)
        
        accountTextFieldView.textPublisher.sink { [weak self] text in
            self?.viewModel.modifyRequest?.accountNum = text
        }.store(in: &subscriptions)
        
        nameTextFieldView.textPublisher.sink { [weak self] text in
            self?.viewModel.modifyRequest?.accountOwnerName = text
        }.store(in: &subscriptions)
    }
}

extension ModifyPayoutContractViewController: UITextFieldDelegate {
    @objc private func saveButtonTapped() {
        viewModel.modifyPayoutContract()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let currentText = textField.text as NSString? else { return true }

            let updatedText = currentText.replacingCharacters(in: range, with: string)

            if textField == firstTextField {
                return updatedText.count <= 6
            } else if textField == secondTextField {
                return updatedText.count <= 7
            }

            return true
        }
    @objc private func bankUploadTapped() {
        currentUploadType = .account
        presentImagePicker()
    }
    
    @objc private func identifyUploadTapped() {
        currentUploadType = .identify
        presentImagePicker()
    }
    
    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        spinner.startAnimating()
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self,
                  let selectedImage = image as? UIImage,
                  let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async { self?.spinner.stopAnimating() }
                return
            }
            
            self.viewModel.fileUpload(imageData: imageData) { fileToken in
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    if let token = fileToken {
                        switch self.currentUploadType {
                        case .account:
                            self.viewModel.modifyRequest?.accountPhoto = token
                            self.bankStatusLabel.textColor = .tertiary
                            self.bankStatusLabel.text = "*photo.jpg"
                        case .identify:
                            self.viewModel.modifyRequest?.identifyPhoto = token
                            self.identifyStatusLabel.textColor = .tertiary
                            self.identifyStatusLabel.text = "*photo.jpg"
                        case .none:
                            break
                        }
                    }
                }
            }
        }
    }
    private func fillComponents() {
        if let bank = viewModel.payoutDto?.bankName {
            selectBankButton.setSelectedItem(title: bank)
            viewModel.modifyRequest?.bankName = bank
        }
        accountTextFieldView.setText(text: viewModel.payoutDto?.accountNum ?? "")
        nameTextFieldView.setText(text: viewModel.payoutDto?.accountOwnerName ?? "")
        if let status = viewModel.payoutDto?.identifyStatus {
            identifyStatusLabel.text = "*\(status.koreanDescription)"
            if status == .allow || status == .pending {
                identifyStatusLabel.textColor = .tertiary
                identifyUploadButton.setupButtonStatus(isSelected: false)
                firstTextField.text = viewModel.payoutDto?.identifyNum
                firstTextField.isUserInteractionEnabled = false
                secondTextField.text = "0000000"
                secondTextField.isUserInteractionEnabled = false
            }
        }
        if let status = viewModel.payoutDto?.accountStatus {
            bankStatusLabel.text = "*\(status.koreanDescription)"
            if status == .allow {
                bankStatusLabel.textColor = .tertiary
                bankUploadButton.setTitle("통장 사본 재업로드", for: .normal)
            }
        }
        if let reason = viewModel.payoutDto?.identifyDeniedReason {
            identifyDeniedReasonLabel.isHidden = false
            identifyDeniedReasonLabel.text = "*\(reason)"
        }
        if let reason = viewModel.payoutDto?.accountDeniedReason {
            accountDeniedReasonLabel.isHidden = false
            accountDeniedReasonLabel.text = "*\(reason)"
        }
    }
}

extension ModifyPayoutContractViewController {
    
    private func setupLayOuts() {
        [identifyNumGuideLabel, identifySubMessageLabel, firstTextField, separator, secondTextField, identifyWarningLabel, identifyUploadButton, identifyDeniedReasonLabel, identifyStatusLabel, bankGuideLabel, selectBankButton, accountTextFieldView, accountWarningLabel, nameTextFieldView, nameWarningLabel, bankUploadButton, bankStatusLabel, accountDeniedReasonLabel, saveButton, spinner].forEach { view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        spinner.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.size.equalTo(50)
        }
        identifyNumGuideLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        identifySubMessageLabel.snp.makeConstraints {
            $0.top.equalTo(identifyNumGuideLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
        }
        firstTextField.snp.makeConstraints {
            $0.top.equalTo(identifySubMessageLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(34.27)
            $0.trailing.equalTo(separator.snp.leading).offset(-10)
        }
        separator.snp.makeConstraints {
            $0.centerY.equalTo(firstTextField)
            $0.centerX.equalToSuperview()
        }
        secondTextField.snp.makeConstraints {
            $0.top.equalTo(firstTextField)
            $0.leading.equalTo(separator.snp.trailing).offset(10)
            $0.height.equalTo(34.27)
            $0.trailing.equalToSuperview().offset(-16)
        }
        identifyWarningLabel.snp.makeConstraints {
            $0.top.equalTo(firstTextField.snp.bottom).offset(4.37)
            $0.leading.equalTo(firstTextField.snp.leading)
        }
        identifyUploadButton.snp.makeConstraints {
            $0.top.equalTo(identifyWarningLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(136)
            $0.height.equalTo(33)
        }
        identifyDeniedReasonLabel.snp.makeConstraints {
            $0.top.equalTo(identifyUploadButton.snp.bottom).offset(6)
            $0.leading.equalTo(identifyUploadButton)
        }
        identifyStatusLabel.snp.makeConstraints {
            $0.leading.equalTo(identifyUploadButton.snp.trailing).offset(8)
            $0.bottom.equalTo(identifyUploadButton)
        }
        bankGuideLabel.snp.makeConstraints {
            $0.top.equalTo(identifyUploadButton.snp.bottom).offset(42)
            $0.leading.equalToSuperview().offset(16)
        }
        selectBankButton.snp.makeConstraints {
            $0.top.equalTo(bankGuideLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        accountTextFieldView.snp.makeConstraints {
            $0.top.equalTo(selectBankButton.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        accountWarningLabel.snp.makeConstraints {
            $0.top.equalTo(accountTextFieldView.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
        }
        nameTextFieldView.snp.makeConstraints {
            $0.top.equalTo(accountWarningLabel.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        nameWarningLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextFieldView.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
        }
        bankUploadButton.snp.makeConstraints {
            $0.top.equalTo(nameWarningLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(136)
            $0.height.equalTo(33)
        }
        accountDeniedReasonLabel.snp.makeConstraints {
            $0.top.equalTo(bankUploadButton.snp.bottom).offset(6)
            $0.leading.equalTo(bankUploadButton)
        }
        bankStatusLabel.snp.makeConstraints {
            $0.leading.equalTo(bankUploadButton.snp.trailing).offset(8)
            $0.bottom.equalTo(bankUploadButton)
        }
        saveButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupComponents() {
        identifyNumGuideLabel.textColor = .dark
        identifyNumGuideLabel.font = FontSet.pretendardSemiBold(size: 12)
        identifySubMessageLabel.textColor = ColorSet.fromHex("4E4E4E")
        identifySubMessageLabel.font = FontSet.pretendardRegular(size: 10)
        [identifyStatusLabel, bankStatusLabel].forEach {
            $0.font = FontSet.pretendardSemiBold(size: 12)
            $0.textColor = .error1
        }
        bankGuideLabel.textColor = .neutral11
        bankGuideLabel.font = FontSet.pretendardSemiBold(size: 12)
        [identifyWarningLabel, nameWarningLabel, accountWarningLabel].forEach {
            $0.textColor = .error1
            $0.font = FontSet.pretendardSemiBold(size: 10)
        }
        [accountDeniedReasonLabel, identifyDeniedReasonLabel].forEach {
            $0.font = FontSet.pretendardSemiBold(size: 10)
            $0.textColor = .error1
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

