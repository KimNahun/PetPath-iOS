//
//  ReportModalViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/2/25.
//

import Combine
import UIKit

protocol Reportable {
    func report(content: String)
    var reportSuccessPublisher: PassthroughSubject<Void, Never> { get }
}

final class ReportModalViewController: UIViewController, UITextViewDelegate {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: Reportable
    
    private let messageLabel = UILabel().then {
        $0.text = "신고하기"
    }
    
    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(named: "cancel"), for: .normal)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "신고 내용"
    }
    
    private let descriptionTextView = UITextView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = ColorSet.neutral6.cgColor
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 0)
        $0.layer.borderWidth = 2
        $0.font = FontSet.pretendardMedium(size: 14)
        $0.layer.cornerRadius = 8
        $0.textColor = .neutral6
        $0.text = "문제가 되는 부분을 작성해주세요"
    }
    
    private let textCountLabel = UILabel().then {
        $0.text = "0자"
    }
    
    private let reportButton = BottomPlacedButton().then {
        $0.setTitle("신고하기", for: .normal)
    }
    
    init(viewModel: Reportable) {
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
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        descriptionTextView.delegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    private func bind() {

    }
}
extension ReportModalViewController {
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func reportButtonTapped() {
        viewModel.report(content: descriptionTextView.text ?? "")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "문제가 되는 부분을 작성해주세요" {
            textView.text = ""
            textView.textColor = .dark
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "문제가 되는 부분을 작성해주세요"
            textView.textColor = .neutral6
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textCountLabel.text = "\(textView.text.count)자"
        
        let text = (textView.text == "문제가 되는 부분을 작성해주세요") ? "" : textView.text ?? ""
        reportButton.setupButtonStatus(isSelected: !text.isEmpty)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
}

extension ReportModalViewController {
    private func setupLayOuts() {
        [messageLabel, cancelButton, descriptionLabel, descriptionTextView, textCountLabel, reportButton].forEach {
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
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(240)
        }
        textCountLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom)
            $0.leading.equalTo(descriptionTextView.snp.leading).offset(20.22)
            $0.height.equalTo(22)
        }
        reportButton.snp.makeConstraints {
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
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
