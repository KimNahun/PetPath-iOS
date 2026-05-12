//
//  SettingViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/11/25.
//

import Combine
import UIKit

final class SettingViewController: UITableViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    private let viewModel: SettingViewModel
    private var subscriptions = Set<AnyCancellable>()
    private var sections: [[String]] = []
    private let walkerSections: [[String]] = [
        ["계좌 정보 설정", "정산내역", "카드 등록", "페널티 결제 내역", "워커 교육 이수"],
        ["서비스 이용약관", "개인정보 처리방침", "문의하기"],
        ["계정 정보", "알림 설정", "로그아웃"]
    ]
    private let ownerSections: [[String]] = [
        ["카드 등록", "결제내역", "쿠폰함", "강아지 관리"],
        ["서비스 이용약관", "개인정보 처리방침", "문의하기"],
        ["계정 정보", "알림 설정", "로그아웃"]
    ]
    private let logoutCheckModalViewController = ActionCheckModalViewController(message: "로그아웃 하시겠어요?")
    private let changeWalkerCheckModalViewController = ActionCheckModalViewController(message: "워커로 역할을 전환하시겠어요?")
    private let changeOwnerCheckModalViewController = ActionCheckModalViewController(message: "견주로 역할을 전환하시겠어요?")
    
    private var profileHeaderView: ProfileHeaderView?
    
    // MARK: - Init
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupProfileHeaderView()
        setupTableFooterView()
        tableView.sectionHeaderTopPadding = 0
        tableView.register(SettingCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.separatorStyle = .none
        navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getUserInfo()
        setNavigationTitle("설정")
    }
    
    
    // MARK: - Combine Binding
    private func bind() {
        changeWalkerCheckModalViewController.processPublisher.sink { [weak self] _ in
            self?.viewModel.changeUserType()
        }.store(in: &subscriptions)
        
        changeOwnerCheckModalViewController.processPublisher.sink { [weak self] _ in
            self?.viewModel.changeUserType()
        }.store(in: &subscriptions)
        
        logoutCheckModalViewController.processPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            KeychainWorker.shared.delete(key: .access)
            navigationController?.setViewControllers([SignInViewController(viewModel: SignInViewModel())], animated: true)
            ToastMessenger.shared.showToast(message: "로그아웃 되었습니다.")
        }.store(in: &subscriptions)
        viewModel.$userData.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] userData in
                switch userData.type {
                case .owner: self?.sections = self?.ownerSections ?? [[]]
                case .walker: self?.sections = self?.walkerSections ?? [[]]
                default: break
                }
                self?.profileHeaderView?.setUserData(data: userData)
                self?.tableView.tableHeaderView = self?.profileHeaderView
                self?.tableView.reloadWithFade()
            }.store(in: &subscriptions)
        
        viewModel.$trainSuccess.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isSuccess in
            guard let self = self, let isSuccess = isSuccess else { return }
            let viewController = isSuccess ? TrainSuccessViewController(viewModel: TrainViewModel()) : TrainListViewController(viewModel: TrainViewModel())
            navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
    }
    
    @objc private func handleDeleteAccount() {
        let viewContoller = DeleteAccountCheckViewController(viewModel: DeleteAccountViewModel())
        navigationController?.pushViewController(viewContoller, animated: true)
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .neutral4
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section][indexPath.row]
        switch item {
        case "카드 등록":
            navigationController?.pushViewController(CardListViewController(viewModel: CardListViewModel()), animated: true)
        case "쿠폰함":
            navigationController?.pushViewController(CouponViewController(viewModel: CouponViewModel()), animated: true)
        case "강아지 관리":
            navigationController?.pushViewController(ManageDogViewController(viewModel: ManageDogViewModel()), animated: true)
        case "로그아웃":
            present(logoutCheckModalViewController, animated: true)
        case "결제내역", "페널티 결제 내역":
            navigationController?.pushViewController(PaymentHistoryViewController(viewModel: PaymentHistoryViewModel()), animated: true)
        case "서비스 이용약관":
            if let url = UrlManager.service.url {
                UIApplication.shared.open(url)
            }
        case "개인정보 처리방침":
            if let url = UrlManager.privacy.url {
                UIApplication.shared.open(url)
            }
        case "계정 정보":
            navigationController?.pushViewController(ModifyUserInfoViewController(viewModel: ModifyUserInfoViewModel()), animated: true)
        case "정산내역":
            navigationController?.pushViewController(PayoutHistoryViewController(viewModel: PayoutViewModel()), animated: true)
        case "계좌 정보 설정":
            navigationController?.pushViewController(ShowPayoutContractViewController(viewModel: PayoutContractViewModel()), animated: true)
        case "워커 교육 이수":
            viewModel.getWalkerTrainStatus()
        case "알림 설정":
            switch viewModel.userData.type {
            case .owner: navigationController?.pushViewController(OwnerPushViewController(viewModel: PushViewModel()), animated: true)
            case .walker: navigationController?.pushViewController(WalkerPushViewController(viewModel: PushViewModel()), animated: true)
            case .unknown, .none: break
            }
        case "문의하기":
            navigationController?.pushViewController(InquiryViewController(viewModel: .init()), animated: true)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as? SettingCell else {
            return UITableViewCell()
        }
        let item = sections[indexPath.section][indexPath.row]
        let textColor: UIColor = item == "로그아웃" ? .dangerTertiary : .neutral11
        let showSeparator: Bool = indexPath.row != walkerSections[indexPath.section].count - 1 || item == "로그아웃"
        cell.configure(with: item, textColor: textColor, showSeparator: showSeparator)
        return cell
    }
    
    private func setupProfileHeaderView() {
        let headerView = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 57))
        tableView.tableHeaderView = headerView
        self.profileHeaderView = headerView
        
        headerView.buttonTappedPublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                switch viewModel.userData.type {
                case .owner: present(changeWalkerCheckModalViewController, animated: true)
                case .walker: present(changeOwnerCheckModalViewController, animated: true)
                case .unknown, .none: break
                }
        }.store(in: &subscriptions)
    }
    private func setupTableFooterView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 30))
        let deleteButton = UIButton()
        deleteButton.setTitle("회원탈퇴", for: .normal)
        deleteButton.setTitleColor(.neutral9, for: .normal)
        deleteButton.addTarget(self, action: #selector(handleDeleteAccount), for: .touchUpInside)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        footerView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(43)
            $0.height.equalTo(14)
        }
        tableView.tableFooterView = footerView
    }
}
