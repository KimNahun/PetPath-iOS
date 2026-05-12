//
//  SelectWalkConditionViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/24/25.
//

import Combine
import UIKit

final class SelectWalkConditionViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RequestWalkViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let messageLabel = UILabel().then {
        $0.setTitleBold(text: "산책 시간과 픽업 위치를\n설정해주세요")
        $0.numberOfLines = 2
    }
    
    private let selectTimeButton = SelectButton(title: "산책 날짜와 시간을 설정해주세요", leftImage: UIImage(named: "clock"))
    private let selectLocationButton = SelectButton(title: "픽업 위치를 지정해주세요.", leftImage: UIImage(named: "marker"))
    private let requireButton = SelectButton(title: "요청 사항을 작성해주세요", leftImage: nil)
    
    private let requestButton = BottomPlacedButton().then {
        $0.setTitle("워커 모집하기", for: .normal)
    }
    
    private lazy var locationConentViewController = LocationContentViewController(viewModel: viewModel)
    
    private lazy var timeContentViewController = TimeContentViewController(viewModel: viewModel)
    
    private lazy var requireContentViewController = RequireModalViewController(viewModel: viewModel).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let predictedPriceView = UIView().then {
        $0.backgroundColor = .primary100
        $0.isHidden = true
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    
    private let priceGuideLabel = UILabel().then {
        $0.text = "최소 예상 금액"
        $0.textColor = .neutral10
        $0.font = FontSet.pretendardBold(size: 16)
    }
    
    private let priceLabel = UILabel().then {
        $0.textColor = .neutral10
        $0.font = FontSet.pretendardSemiBold(size: 14)
    }
    
    init(viewModel: RequestWalkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "산책 요청"
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
        selectTimeButton.addTarget(self, action: #selector(selectTimeButtonTapped), for: .touchUpInside)
        selectLocationButton.addTarget(self, action: #selector(selectLocationButtonTapped), for: .touchUpInside)
        requireButton.addTarget(self, action: #selector(requireButtonTapped), for: .touchUpInside)
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("산책 요청")
    }
    // ???: 이런것들 enable버튼같은것들도 전부 초기화 해야하나 ?
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.requestWalkRequest = .init()
        viewModel.finalRequest = .init()
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.walkRequestSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            ToastMessenger.shared.showToast(message: "워커 모집 요청에 성공했습니다.")
            self?.navigationController?.popToViewControllerOrReplace(ofType: OwnerMainPageViewController.self, createNew: {
                OwnerMainPageViewController(viewModel: MainPageViewModel())
            })
        }.store(in: &subscriptions)
        
        viewModel.$finalRequest.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] request in
            guard let strongSelf = self else { return }
            if !request.startAt.isEmpty {
                let startTime = request.startAt.extractDateComponentsFromISO()
                let endTime = request.endAt.extractDateComponentsFromISO()
                self?.selectTimeButton.updateText(mainText: "산책 시간", subText: "\(startTime.month)/\(startTime.day)(\(startTime.weekday)) \(startTime.hour):\(startTime.minute) ~ \(endTime.month)/\(endTime.day)(\(endTime.weekday)) \(endTime.hour):\(endTime.minute) (\(self?.viewModel.computedResult.priceText ?? ""))")
                strongSelf.selectTimeButton.snp.updateConstraints {
                    $0.height.equalTo(71)
                }
            }
            if !request.address.isEmpty {
                self?.selectLocationButton.updateText(mainText: "픽업 위치", subText: request.address, guideText: request.pickupDetail)
                strongSelf.selectLocationButton.snp.updateConstraints {
                    $0.height.equalTo(request.pickupDetail.isEmpty ? 71 : 93)
                }
            }
            if !request.require.isEmpty {
                self?.requireButton.updateText(mainText: "요청사항", subText: request.require)
                strongSelf.requireButton.snp.updateConstraints {
                    $0.height.equalTo(71)
                }
            }
        }.store(in: &subscriptions)
        
        viewModel.$predictedPrice.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] price in
            self?.priceLabel.text = "\(price.formattedWithComma) 원"
        }.store(in: &subscriptions)
        
        viewModel.$requestButtonEnabled.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] enabled in
            self?.requestButton.setupButtonStatus(isSelected: enabled)
            self?.predictedPriceView.isHidden = !enabled
        }.store(in: &subscriptions)
    }
}

extension SelectWalkConditionViewController {
    @objc private func requestButtonTapped() {
        requestPermissionsIfNeeded([.notification]) { [weak self] isPermit in
            guard let self = self else { return }
            if isPermit {
                viewModel.requestWalk()
            } else {
                present(PermissionBlockModalViewController(message: "산책 관련 알림을 받기 위해서는 권한이 필요합니다.\n설정으로 이동해서 알림 권한을 활성화 해주세요"), animated: true)
            }
        }
    }
    
    @objc private func selectTimeButtonTapped() {
        requestPermissionsIfNeeded([.location]) { [weak self] isPermit in
            guard let self = self else { return }
            if isPermit {
                let viewController = BottomSheetViewController(contentViewController: timeContentViewController, defaultHeight: 500, cornerRadius: 20, isPannedable: false)
                viewController.modalPresentationStyle = .overFullScreen
                viewController.modalTransitionStyle = .crossDissolve
                present(viewController, animated: true)
            } else {
                present(PermissionBlockModalViewController(message: "지도에서 위치를 보기 위해서는 권한이 필요합니다.\n설정으로 이동해서 위치 권한을 활성화 해주세요."), animated: true)
            }
        }
    }
    
    @objc private func selectLocationButtonTapped() {
        let viewController = BottomSheetViewController(contentViewController: locationConentViewController, defaultHeight: UIScreen.main.bounds.height - 99, cornerRadius: 20, isPannedable: false)
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        present(viewController, animated: true)
    }
    
    @objc private func requireButtonTapped() {
        present(requireContentViewController, animated: true)
    }
    
}

extension SelectWalkConditionViewController {
    
    private func setupLayOuts() {
        [messageLabel, selectTimeButton, selectLocationButton, requireButton, predictedPriceView, requestButton].forEach {
            view.addSubview($0)
        }
        [priceGuideLabel, priceLabel].forEach {
            predictedPriceView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(63)
        }
        selectTimeButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(60)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        selectLocationButton.snp.makeConstraints {
            $0.top.equalTo(selectTimeButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        requireButton.snp.makeConstraints {
            $0.top.equalTo(selectLocationButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        predictedPriceView.snp.makeConstraints {
            $0.height.equalTo(78)
            $0.bottom.equalTo(requestButton.snp.top).offset(-16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        priceGuideLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.height.equalTo(19)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(priceGuideLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(17)
        }
        requestButton.snp.makeConstraints {
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

