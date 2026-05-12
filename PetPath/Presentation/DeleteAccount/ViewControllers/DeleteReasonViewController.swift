//
//  DeleteReasonViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/21/25.
//

import Combine
import UIKit

final class DeleteReasonViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: DeleteAccountViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    private let deleteCheckModalViewController = ActionCheckModalViewController(message: "정말 탈퇴하시겠어요?")
    
    enum ReasonItem: String, CaseIterable, CustomStringConvertible {
        case reSignIn = "탈퇴 후 다시 가입 예정이예요"
        case notGoodService = "산책 서비스의 품질이 아쉬워요"
        case noMatching = "산책 매칭이 잘 되지 않아요"
        case uncomfortable = "앱 이용 과정이 불편해요"
        case expensive = "가격 또는 수수료가 너무 높아요"
        case notUse = "자주 사용하지 않아요"
        case manyPush = "알림이 너무 자주 와요"
        case personalInfo = "내 개인정보가 걱정돼요"
        case etc = "기타"
        
        var description: String {
            switch self {
            case .reSignIn: return ""
            case .notGoodService: return "(선택) 산책에 대해 어떤 점이 아쉬우셨나요?"
            case .noMatching: return "(선택) 어떤 점이 원활하지 못했나요?"
            case .uncomfortable: return "(선택) 어떤 부분이 불편하다고 느끼셨나요?"
            case .expensive: return "(선택) 주로 워커, 견주 중 어느 역할이셨나요?"
            case .notUse: return "(선택) 자주 사용하지 않으신 이유는 무엇인가요?"
            case .manyPush: return ""
            case .personalInfo: return ""
            case .etc: return "(필수) 더 자세히 알려주세요"
            }
        }
    }
    
    private let scrollView = UIScrollView()
    
    private let messageLabel = UILabel()
    
    private let profileImageView = AspectFitImageView().then {
        $0.layer.cornerRadius = 45
        $0.layer.masksToBounds = true
        $0.backgroundColor = ColorSet.fromHex("D9D9D9")
    }
    
    private let nameLabel = UILabel()
    
    private let reasonGuideLabel = UILabel().then {
        $0.text = "펫패스를 떠나시려는 이유를 알려주세요"
    }
    private let reasonTextField = BindableTextField(font: FontSet.pretendardSemiBold(size: 12), leftWidth: 4).then {
        $0.isHidden = true
    }
    
    private let reasonButton = DropdownButton(placeholder: "이유 선택")
    
    private let noticeView = UIView().then {
        $0.backgroundColor = ColorSet.fromHex("FFF8D6")
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
    }
    private let warningLabel = UILabel().then {
        $0.text = "탈퇴 요청 전 주의사항"
    }
    private let warningMessageLabel = UILabel()
    
    private let agreementView = UIView().then {
        $0.backgroundColor = ColorSet.fromHex("FFF8D6")
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
    }
    private let checkButton = UIButton().then {
        $0.setImage(UIImage(named: "checkbox"), for: .normal)
        $0.setImage(UIImage(named: "checkboxFill"), for: .selected)
    }
    private let checkMessageLabel = UILabel().then {
        $0.text = "회원 탈퇴 유의사항을 확인하였으며 동의합니다"
        $0.isUserInteractionEnabled = true
    }
    private let deleteRequestButton = BottomPlacedButton().then {
        $0.setTitle("탈퇴요청", for: .normal)
    }
    
    // MARK: - UI Components
    
    init(viewModel: DeleteAccountViewModel) {
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
        viewModel.getUserInfo()
        fillComponents()
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(checkButtonTapped))
        checkMessageLabel.addGestureRecognizer(tap)
        deleteRequestButton.addTarget(self, action: #selector(deleteRequestButtonTapped), for: .touchUpInside)
        reasonButton.setDropdown(items: ReasonItem.allCases.map { DropdownItem(id: nil, title: $0.rawValue) })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.deleteRequest = DeleteAccountRequest()
        setNavigationTitle("회원탈퇴")
    }
    
    // MARK: - Bind
    
    private func bind() {
        deleteCheckModalViewController.processPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            viewModel.deleteAccount()
        }.store(in: &subscriptions)
        
        viewModel.deleteSuccessPublisher.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] in
            let viewController = DeleteOKViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        reasonButton.selectedItemPublisher
            .sink { [weak self] item in
                guard let self = self else { return }
                guard let selectedReason = ReasonItem.allCases.first(where: { $0.rawValue == item.title }) else {
                    return
                }
                reasonTextField.placeholder = selectedReason.description
                reasonTextField.text = ""
                viewModel.deleteRequest = DeleteAccountRequest(reason: selectedReason.rawValue)
                switch selectedReason {
                case .reSignIn, .manyPush, .personalInfo: reasonTextField.isHidden = true
                case .notGoodService, .noMatching, .uncomfortable, .expensive, .notUse, .etc : reasonTextField.isHidden = false
                }
            }.store(in: &subscriptions)
        
        reasonTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.deleteRequest.reasonDetail = text
        }.store(in: &subscriptions)
        
        viewModel.$buttonEnabled.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isEnabled in
            guard let self = self else { return }
            self.deleteRequestButton.setupButtonStatus(isSelected: isEnabled)
        }.store(in: &subscriptions)
        
        viewModel.$deleteFailReason.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] text in
            guard let self = self, let text = text else { return }
            let viewController = NotDeletableModalViewController(message: text)
            viewController.modalPresentationStyle = .overFullScreen
            viewController.modalTransitionStyle = .crossDissolve
            present(viewController, animated: true)
        }.store(in: &subscriptions)
    }
}

extension DeleteReasonViewController {
    
    private func fillComponents() {
        guard let userData = viewModel.userDTO else { return }
        messageLabel.setTitleBold(text: "\(userData.name) 회원님\n정말 탈퇴하시겠어요?")
        nameLabel.text = userData.name
        profileImageView.loadImage(url: userData.profileImg)
        warningMessageLabel.text = """
지금 탈퇴하시면 \(userData.name)님의 과거 산책 데이터, 등록한 정보, 고객센터 문의내역 등 펫패스 앱 내에서 활동하신 정보에 더 이상 접근하실 수 없게 되어요.

워커님이신 경우, 정산 및 지급 내역 등도 모두 사라져요.

견주님이신 경우, 등록하신 강아지 정보와 보유하신 쿠폰 및 결제내역 등도 모두 사라져요.

지금 탈퇴하시면 추후에 동일 정보로 재가입하셔도 과거의 어떠한 활동 정보나 이용 내역도 복구되지 않아요.
"""
    }
    @objc private func checkButtonTapped() {
        checkButton.isSelected.toggle()
        viewModel.isAgreementChecked = checkButton.isSelected
    }
    @objc private func deleteRequestButtonTapped() {
        present(deleteCheckModalViewController, animated: true)
    }
}

extension DeleteReasonViewController {
    
    private func setupLayOuts() {
        [scrollView, deleteRequestButton].forEach {
            view.addSubview($0)
        }
        [messageLabel, profileImageView, nameLabel, reasonGuideLabel, reasonButton, reasonTextField, noticeView, agreementView].forEach {
            scrollView.addSubview($0)
        }
        [warningLabel, warningMessageLabel].forEach {
            noticeView.addSubview($0)
        }
        [checkButton, checkMessageLabel].forEach {
            agreementView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(deleteRequestButton.snp.top).offset(-4)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(63)
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(30)
            $0.size.equalTo(90)
            $0.centerX.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        reasonGuideLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(16)
        }
        reasonButton.snp.makeConstraints {
            $0.top.equalTo(reasonGuideLabel.snp.bottom).offset(9)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.horizontalEdges.equalTo(view).inset(16)
            $0.height.equalTo(33)
        }
        reasonTextField.snp.makeConstraints {
            $0.top.equalTo(reasonButton.snp.bottom).offset(7)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(33)
        }
        noticeView.snp.makeConstraints {
            $0.top.equalTo(reasonTextField.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view).inset(16)
        }
        agreementView.snp.makeConstraints {
            $0.top.equalTo(noticeView.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-4)
        }
        warningLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
        }
        warningMessageLabel.snp.makeConstraints {
            $0.top.equalTo(warningLabel.snp.bottom).offset(10)
            $0.horizontalEdges.bottom.equalToSuperview().inset(16)
        }
        deleteRequestButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        checkButton.snp.makeConstraints {
            $0.centerY.equalTo(agreementView)
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(24)
        }
        checkMessageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(checkButton.snp.trailing).offset(4)
        }
    }
    
    private func setupComponents() {
        messageLabel.numberOfLines = 2
        messageLabel.textColor = .dark
        nameLabel.textColor = .dark
        nameLabel.font = FontSet.pretendardBold(size: 16)
        reasonGuideLabel.textColor = .dark
        reasonGuideLabel.font = FontSet.pretendardMedium(size: 14)
        reasonButton.layer.cornerRadius = 8
        reasonButton.layer.masksToBounds = true
        reasonButton.layer.borderColor = ColorSet.neutral6.cgColor
        reasonButton.layer.borderWidth = 2
        warningLabel.textColor = ColorSet.fromHex("918130")
        warningLabel.font = FontSet.pretendardBold(size: 14)
        warningMessageLabel.numberOfLines = 0
        warningMessageLabel.textColor = ColorSet.fromHex("918130")
        warningMessageLabel.font = FontSet.pretendardMedium(size: 12)
        checkMessageLabel.textColor = .neutral9
        checkMessageLabel.font = FontSet.pretendardRegular(size: 12)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}

