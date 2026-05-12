//
//  WalkCancelReasonModalViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/30/25.
//

import UIKit

final class CancelReasonModalViewController: UIViewController {

    // MARK: - UI
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.text = "취소 사유"
        $0.textColor = .black
        $0.font = FontSet.pretendardBold(size: 20)
        $0.textAlignment = .center
    }

    private let reasonLabel = UILabel().then {
        $0.textColor = .black
        $0.font = FontSet.pretendardMedium(size: 14)
        $0.numberOfLines = 0
    }

    private let cancelButton = UIButton().then {
        $0.setImage(UIImage(named: "cancel"), for: .normal)
    }

    private let closeButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("닫기", for: .normal)
    }

    // MARK: - Init
    init(reason: String) {
        self.reasonLabel.text = reason
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        setupUI()
        setupConstraints()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    // MARK: - Layout
    private func setupUI() {
        view.addSubview(containerView)
        [titleLabel, cancelButton, reasonLabel, closeButton].forEach {
            containerView.addSubview($0)
        }
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }
        reasonLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(reasonLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
