//
//  ModifyUserInfoViewController.swift
//  PetPath
//
//  Created by 김나훈 on 4/25/25.
//

import Combine
import PhotosUI
import UIKit

final class ModifyUserInfoViewController: UIViewController, PHPickerViewControllerDelegate {
    
    // MARK: - Properties
    private let viewModel: ModifyUserInfoViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private var pendingSelectedImage: UIImage?
    
    private let scrollView = UIScrollView()
    
    private let imageView = AspectFitImageView().then {
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = ColorSet.fromHex("D9D9D9")
    }
    private let spinner = UIActivityIndicatorView(style: .large)
    private let cameraImageView = AspectFitImageView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "camera")
        $0.isUserInteractionEnabled = true
    }
    private let messageLabel = UILabel().then {
        $0.text = "사진은 워커가 견주에게 보여지는 사진입니다."
    }
    private let nameGuideLabel = UILabel().then {
        $0.text = "이름"
    }
    private let nameLabel = UILabel()
    
    private let phoneNumberGuideLabel = UILabel().then {
        $0.text = "전화번호"
    }
    private let phoneNumberLabel = UILabel()
    
    private let genderGuideLabel = UILabel().then {
        $0.text = "성별"
    }
    private let genderLabel = UILabel()
    
    private let mainPasswordTextFieldView = BindableTextFieldView(title: "비밀번호 설정", mode: .secure).then {
        $0.setPlaceHolder(text: "비밀번호 설정")
    }
    
    private let letterConditionCheckView = ConditionCheckView(text: "영문 대/소문자, 숫자, 특수문자 중 2개 이상 포함").then { _ in}
    
    private let passwordConditionLabel = UILabel().then {
        $0.font = FontSet.pretendardRegular(size: 10)
        $0.textColor = .gray500
        $0.text = "특수문자는 !@#$%^&*?만 가능"
    }
    
    private let countConditionCheckView = ConditionCheckView(text: "8자리 이상").then { _ in }
    
    private let repeatPasswordCheckTextFieldView = BindableCaptionTextField(title: "비밀번호 확인", mode: .secure).then {
        $0.setPlaceHolder(text: "비밀번호 확인")
    }
    
    private let saveButton = BottomPlacedButton().then {
        $0.setTitle("저장", for: .normal)
    }
    
    // MARK: - UI Components
    
    init(viewModel: ModifyUserInfoViewModel) {
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
        viewModel.getUserFullInfo()
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        let imageTapGesture1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(imageTapGesture1)
        
        let imageTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cameraImageView.addGestureRecognizer(imageTapGesture2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("프로필 변경")
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.popPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$modifyRequest.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] request in
            guard let self = self else { return }
            if request.profileImage != nil && self.pendingSelectedImage != nil {
                self.spinner.stopAnimating()
                self.imageView.image = self.pendingSelectedImage
                self.pendingSelectedImage = nil
            }

            let isAllNil = request.newPw == nil && request.profileImage == nil
            let isAllSuccess = viewModel.passwordLetterSuccess != .fail && viewModel.passwordCountSuccess != .fail && viewModel.passwordMatchSuccess != .fail && viewModel.mainPassword == viewModel.repeatPassword
            saveButton.setupButtonStatus(isSelected: !isAllNil && isAllSuccess)
        }.store(in: &subscriptions)
        
        
        viewModel.$userInfo.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] userData in
            guard let userData = userData, let self = self else { return }
            nameLabel.text = userData.name
            phoneNumberLabel.text = userData.phoneNumber
            genderLabel.text = userData.gender.koreanDescription
            imageView.loadImage(url: userData.profileImg)
        }.store(in: &subscriptions)
        
        mainPasswordTextFieldView.textPublisher.assign(to: \.mainPassword, on: viewModel)
            .store(in: &subscriptions)
        repeatPasswordCheckTextFieldView.textPublisher.assign(to: \.repeatPassword, on: viewModel)
            .store(in: &subscriptions)
        
        viewModel.$passwordLetterSuccess
            .receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] state in
                self?.letterConditionCheckView.setState(state: state)
            }.store(in: &subscriptions)
        viewModel.$passwordCountSuccess
            .receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] state in
                self?.countConditionCheckView.setState(state: state)
            }.store(in: &subscriptions)
        viewModel.$passwordMatchSuccess
            .receive(on: RunLoop.main).dropFirst()
            .sink { [weak self] success in
                switch success {
                case .common:
                    self?.repeatPasswordCheckTextFieldView.setState(state: .normal)
                case .success:
                    self?.repeatPasswordCheckTextFieldView.setState(state: .success)
                    self?.repeatPasswordCheckTextFieldView.setCaptionText(text: "비밀번호가 일치합니다.")
                case .fail:
                    self?.repeatPasswordCheckTextFieldView.setState(state: .error)
                    self?.repeatPasswordCheckTextFieldView.setCaptionText(text: "비밀번호가 일치하지 않습니다.")
                }
            }.store(in: &subscriptions)
    }
}

extension ModifyUserInfoViewController {
    @objc private func saveButtonTapped() {
        viewModel.modifyUser()
    }
    @objc private func imageTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1 // ✅ 1장만 선택 가능
        config.filter = .images  // ✅ 이미지 파일만 선택
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        // ✅ 이미지 선택되면 스피너 돌리기
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
        imageView.image = nil
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let selectedImage = image as? UIImage else {
                DispatchQueue.main.async { self?.spinner.stopAnimating() }
                return
            }

            guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async { self.spinner.stopAnimating() }
                return
            }

            // ✅ 이미지만 미리 저장, 표시하지는 않음
            self.pendingSelectedImage = selectedImage

            // ✅ 업로드 시작
            self.viewModel.fileUpload(imageData: imageData)
        }
    }
}

extension ModifyUserInfoViewController {
    
    private func setupLayOuts() {
        view.addSubview(scrollView)
        view.addSubview(saveButton)
        [imageView, cameraImageView, messageLabel, nameGuideLabel, nameLabel, phoneNumberGuideLabel, phoneNumberLabel, genderGuideLabel, genderLabel, mainPasswordTextFieldView, letterConditionCheckView, passwordConditionLabel, countConditionCheckView, repeatPasswordCheckTextFieldView].forEach {
            scrollView.addSubview($0)
        }
        imageView.addSubview(spinner)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalTo(view.snp.width)
            $0.bottom.equalTo(saveButton.snp.top).offset(-10)
        }
        imageView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(80)
        }
        cameraImageView.snp.makeConstraints {
            $0.trailing.bottom.equalTo(imageView)
            $0.size.equalTo(24)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        nameGuideLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(nameGuideLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(17)
        }
        phoneNumberGuideLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(16)
        }
        phoneNumberLabel.snp.makeConstraints {
            $0.top.equalTo(phoneNumberGuideLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(17)
        }
        genderGuideLabel.snp.makeConstraints {
            $0.top.equalTo(phoneNumberLabel.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(16)
        }
        genderLabel.snp.makeConstraints {
            $0.top.equalTo(genderGuideLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(17)
        }
        mainPasswordTextFieldView.snp.makeConstraints {
            $0.top.equalTo(genderLabel.snp.bottom).offset(59)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.horizontalEdges.equalTo(view).inset(16)
            $0.height.equalTo(57)
        }
        letterConditionCheckView.snp.makeConstraints {
            $0.top.equalTo(mainPasswordTextFieldView.snp.bottom).offset(8)
            $0.leading.equalTo(mainPasswordTextFieldView)
            $0.height.equalTo(14)
            $0.width.equalTo(267)
        }
        passwordConditionLabel.snp.makeConstraints {
            $0.top.equalTo(letterConditionCheckView.snp.bottom).offset(4)
            $0.leading.equalTo(mainPasswordTextFieldView).offset(20)
            $0.height.equalTo(12)
        }
        countConditionCheckView.snp.makeConstraints {
            $0.top.equalTo(passwordConditionLabel.snp.bottom).offset(8)
            $0.leading.equalTo(mainPasswordTextFieldView)
            $0.height.equalTo(14)
            $0.width.equalTo(267)
        }
        repeatPasswordCheckTextFieldView.snp.makeConstraints {
            $0.top.equalTo(countConditionCheckView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(57)
            $0.bottom.equalToSuperview().offset(-30)
        }
        saveButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        spinner.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupComponents() {
        messageLabel.textColor = .neutral8
        messageLabel.font = FontSet.pretendardRegular(size: 12)
        [nameGuideLabel, phoneNumberGuideLabel, genderGuideLabel].forEach {
            $0.textColor = .neutral6
            $0.font = FontSet.pretendardSemiBold(size: 12)
        }
        [nameLabel, phoneNumberLabel, genderLabel].forEach {
            $0.textColor = .neutral11
            $0.font = FontSet.pretendardMedium(size: 14)
        }
        passwordConditionLabel.textColor = ColorSet.fromHex("6C757D")
        passwordConditionLabel.font = FontSet.pretendardRegular(size: 10)
        
        spinner.hidesWhenStopped = true
        spinner.color = .gray
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
