//
//  ApplyWalkContentViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/30/25.
//

import Combine
import UIKit

final class ApplyWalkContentViewController: UIViewController, UITextViewDelegate {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: WalkerWalkDetailViewModel
    
    private let messageLabel = UILabel().then {
        $0.text = "지원하기"
    }
    
    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(named: "cancel"), for: .normal)
    }
    
    private let priceTextField =  BindableTextFieldView(title: "제시 금액", numberPad: true).then {
        $0.setPlaceHolder(text: "제시 금액을 입력해주세요")
    }
    
    private let captionImageView = AspectFitImageView().then {
        $0.image = UIImage(named: "caption")
        
    }
    
    private let captionLabel = UILabel().then {
        $0.font = FontSet.pretendardSemiBold(size: 10)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "어필 내용"
    }
    
    private let descriptionTextView = UITextView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = ColorSet.neutral6.cgColor
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 0)
        $0.layer.borderWidth = 2
        $0.font = FontSet.pretendardMedium(size: 14)
        $0.layer.cornerRadius = 8
        $0.textColor = .neutral6
        $0.text = "어필내용을 입력해주세요"
    }
    
    private let textCountLabel = UILabel().then {
        $0.text = "0자"
    }
    private let applyButton = BottomPlacedButton().then {
        $0.setTitle("산책 지원하기", for: .normal)
    }
    
    init(viewModel: WalkerWalkDetailViewModel) {
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
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        descriptionTextView.delegate = self
        let price = viewModel.walkDetailResponse?.price ?? 0
        captionLabel.text = "최소 금액: \(price.formattedWithComma)원"
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    private func bind() {
        viewModel.$isRequestValid.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] enabled in
            self?.applyButton.setupButtonStatus(isSelected: enabled)
        }.store(in: &subscriptions)
        
        priceTextField.textPublisher.sink { [weak self] text in
            guard let self = self else { return }
            let price = Int(text.filter { $0.isNumber })
            self.viewModel.applyWalkRequest?.price = price
        }.store(in: &subscriptions)
        
        viewModel.applySuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.dismiss(animated: true)
            ToastMessenger.shared.showToast(message: "산책 지원에 성공했습니다.")
            self?.viewModel.popPublisher.send()
        }.store(in: &subscriptions)
    }
}
extension ApplyWalkContentViewController {
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func applyButtonTapped() {
        viewModel.applyWalker()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "어필내용을 입력해주세요" {
            textView.text = ""
            textView.textColor = .dark
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "어필내용을 입력해주세요"
            textView.textColor = .neutral6
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textCountLabel.text = "\(textView.text.count)자"
        
        let text = (textView.text == "어필내용을 입력해주세요") ? "" : textView.text ?? ""
        viewModel.applyWalkRequest?.description = text.isEmpty ? nil : text
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
}

extension ApplyWalkContentViewController {
    private func setupLayOuts() {
        [messageLabel, cancelButton, priceTextField, captionImageView, captionLabel, descriptionLabel, descriptionTextView, textCountLabel, applyButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.top)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
        priceTextField.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
        }
        captionImageView.snp.makeConstraints {
            $0.top.equalTo(priceTextField.snp.bottom).offset(5)
            $0.leading.equalTo(priceTextField.snp.leading).offset(4)
            $0.size.equalTo(12)
        }
        captionLabel.snp.makeConstraints {
            $0.centerY.equalTo(captionImageView)
            $0.leading.equalTo(captionImageView.snp.trailing).offset(4)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(captionLabel.snp.bottom).offset(13)
            $0.horizontalEdges.equalTo(priceTextField)
            $0.height.equalTo(14)
        }
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalTo(priceTextField)
            $0.height.equalTo(240)
        }
        textCountLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom)
            $0.leading.equalTo(descriptionTextView.snp.leading).offset(20.22)
            $0.height.equalTo(22)
        }
        applyButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    private func setupComponents() {
        messageLabel.textColor = .dark
        messageLabel.font = FontSet.pretendardBold(size: 20)
        descriptionLabel.textColor = .neutral6
        descriptionLabel.font = FontSet.pretendardSemiBold(size: 12)
        textCountLabel.textColor = .neutral6
        textCountLabel.font = FontSet.pretendardSemiBold(size: 10)
        captionLabel.textColor = .neutral6
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
