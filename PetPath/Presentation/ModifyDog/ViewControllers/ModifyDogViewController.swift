//
//  ModifyDogViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Combine
import PhotosUI
import UIKit

final class ModifyDogViewController: UIViewController, PHPickerViewControllerDelegate, UITextViewDelegate  {
    
    // MARK: - Properties
    private let viewModel: ModifyDogViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private var pendingSelectedImage: UIImage?
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    private let imageView = AspectFitImageView().then {
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .component3
    }
    private let spinner = UIActivityIndicatorView(style: .large)
    private let cameraImageView = AspectFitImageView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "camera")
        $0.isUserInteractionEnabled = true
    }
    private let certButton = BottomPlacedButton(backColor: .secondary100)
    
    private let speciesGuideLabel = UILabel().then {
        $0.text = "견종"
    }
    private let speciesLabel = UILabel()
    
    private let speciesTextField = BindableTextField().then {
        $0.placeholder = "견종"
    }
    
    private let nameGuideLabel = UILabel().then {
        $0.text = "강아지 이름"
    }
    
    private let nameLabel = UILabel()
    
    private let nameTextField = BindableTextField().then {
        $0.placeholder = "강아지 이름"
    }
    
    private let birthGuideLabel = UILabel().then {
        $0.text = "강아지 생일"
        $0.font = FontSet.pretendardBold(size: 12)
        $0.textColor = .neutral6
    }
    
    private let yearDropdownButton = DropdownButton(
        placeholder: "년 선택",
        font: FontSet.pretendardMedium(size: 14),
        selectedTextColor: .dark
    )
    
    private let monthDropdownButton = DropdownButton(
        placeholder: "월 선택",
        font: FontSet.pretendardMedium(size: 14),
        selectedTextColor: .dark
    )
    
    private let genderGuideLabel = UILabel().then {
        $0.text = "강아지 성별"
    }
    
    private let maleButton = UIButton().then {
        $0.setTitle("남", for: .normal)
    }
    
    private let femaleButton = UIButton().then {
        $0.setTitle("여", for: .normal)
    }
    
    private let isNeuterGuideLabel = UILabel().then {
        $0.setTitle(text: "강아지 중성화 여부")
    }
    
    private let isNeuterButton = UIButton().then {
        $0.setTitle("네", for: .normal)
    }
    
    private let nonNeuterButton = UIButton().then {
        $0.setTitle("아니오", for: .normal)
    }
    
    private let sizeGuideLabel = UILabel().then {
        $0.text = "크기 설정"
    }
    
    private let bigSizeButton = UIButton().then {
        $0.setTitle("대형견", for: .normal)
    }
    
    private let middleSizeButton = UIButton().then {
        $0.setTitle("중형견", for: .normal)
    }
    
    private let smallSizeButton = UIButton().then {
        $0.setTitle("소형견", for: .normal)
    }
    
    private let sizeLabel = UILabel().then {
        $0.text = "대형견 : 20kg 초과\n중형견 : 10kg ~ 20kg\n소형견 : 10kg 미만"
        $0.numberOfLines = 3
    }
    
    private let personalityGuideLabel = UILabel().then {
        $0.text = "성격 설정 (최소 2개)"
    }
    
    private let personalityCollectionView: PersonalityCollectionView = {
        let layout = FixedSpacingFlowLayout(spacing: 8)
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .zero
        let collectionView = PersonalityCollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let addInfoLabel = UILabel().then {
        $0.text = "특이사항 or 요구사항"
    }
    
    private let addInfoCollectionView: AddInfoCollectionView = {
        let layout = FixedSpacingFlowLayout(spacing: 8)
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .zero
        let collectionView = AddInfoCollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let infoLabel = UILabel().then {
        $0.text = "부가 정보 입력"
    }
    
    private let infoTextView = UITextView()
    
    private let modifyButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("수정하기", for: .normal)
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
        viewModel.getKeywordTagList()
        hideKeyboardWhenTappedAround()
        infoTextView.delegate = self
        setupDropdownItems()
        modifyButton.addTarget(self, action: #selector(modifyButtonTapped), for: .touchUpInside)
        [bigSizeButton, middleSizeButton, smallSizeButton].forEach {
            $0.addTarget(self, action: #selector(sizeButtonTapped(_:)), for: .touchUpInside)
        }
        [maleButton, femaleButton].forEach {
            $0.addTarget(self, action: #selector(genderButtonTapped(_:)), for: .touchUpInside)
        }
        [isNeuterButton, nonNeuterButton].forEach {
            $0.addTarget(self, action: #selector(neuterButtonTapped(_:)), for: .touchUpInside)
        }
        let imageTapGesture1 = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(imageTapGesture1)
        
        let imageTapGesture2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cameraImageView.addGestureRecognizer(imageTapGesture2)
        certButton.addTarget(self, action: #selector(certButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("")
        reverseView()
    }
    
    // MARK: - Bind
    
    private func bind() {
        
        speciesTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.modifyDogInfoRequest.species = text
        }.store(in: &subscriptions)
        
        nameTextField.textPublisher.sink { [weak self] text in
            self?.viewModel.modifyDogInfoRequest.dogName = text
        }.store(in: &subscriptions)
        
        yearDropdownButton.selectedItemPublisher.sink { [weak self] item in
            self?.viewModel.modifyDogInfoRequest.birthYear = item.title.replacingOccurrences(of: "년", with: "")
        }.store(in: &subscriptions)
        
        monthDropdownButton.selectedItemPublisher.sink { [weak self] item in
            self?.viewModel.modifyDogInfoRequest.birthMonth = item.title.replacingOccurrences(of: "월", with: "")
        }.store(in: &subscriptions)
        
        personalityCollectionView.personalityPublisher.sink { [weak self] index in
            self?.viewModel.charTags[index].isSelected.toggle()
        }.store(in: &subscriptions)
        
        addInfoCollectionView.requirePublisher.sink { [weak self] index in
            self?.viewModel.requireTags[index].isSelected.toggle()
        }.store(in: &subscriptions)
        
        viewModel.$charTags.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] items in
                guard let strongSelf = self else { return }
                self?.personalityCollectionView.setKeywordList(item: items)
                strongSelf.personalityCollectionView.snp.updateConstraints {
                    $0.height.equalTo(strongSelf.personalityCollectionView.calculateDynamicHeight())
                }
            }.store(in: &subscriptions)
        
        viewModel.$requireTags.receive(on: DispatchQueue.main).dropFirst()
            .sink { [weak self] items in
                guard let strongSelf = self else { return }
                self?.addInfoCollectionView.setKeywordList(item: items)
                strongSelf.addInfoCollectionView.snp.updateConstraints {
                    $0.height.equalTo(strongSelf.addInfoCollectionView.calculateDynamicHeight())
                }
            }.store(in: &subscriptions)
        
        viewModel.dogInfoPublisher.receive(on: DispatchQueue.main).sink { [weak self] item in
            self?.setDogData(item)
        }.store(in: &subscriptions)
        
        viewModel.modifySuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            ToastMessenger.shared.showToast(message: "정보 수정이 완료됐습니다.")
            self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$modifyDogInfoRequest.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] request in
            guard let self = self else { return }
            if request.profileImage != nil && self.pendingSelectedImage != nil {
                self.spinner.stopAnimating()
                self.imageView.image = self.pendingSelectedImage
                self.pendingSelectedImage = nil
            }
        }.store(in: &subscriptions)
    }
}

extension ModifyDogViewController {
    private func setupDropdownItems() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearItems = (2000...currentYear).map { DropdownItem(id: nil, title: "\($0)년") }.reversed()
        let monthItems = (1...12).map { DropdownItem(id: nil, title: "\($0)월") }
        
        yearDropdownButton.setDropdown(items: Array(yearItems))
        monthDropdownButton.setDropdown(items: monthItems)
    }
    private func reverseView() {
        let item = viewModel.modifyDogInfoRequest
        nameTextField.isHidden = item.isVerified
        nameTextField.text = item.dogName
        nameLabel.isHidden = !item.isVerified
        nameLabel.text = item.dogName
        speciesTextField.isHidden = item.isVerified
        speciesTextField.text = item.species
        speciesLabel.isHidden = !item.isVerified
        speciesLabel.text = item.species
        if item.isVerified {
            certButton.setTitle("강아지 등록번호 인증완료", for: .normal)
            certButton.setupButtonStatus(isSelected: false)
        } else {
            certButton.setTitle("강아지 등록번호 인증하기", for: .normal)
            certButton.setupButtonStatus(isSelected: true)
        }
    }
    @objc private func certButtonTapped() {
        let viewController = DogCertViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.modifyDogInfoRequest.description = textView.text ?? ""
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
    
    private func selectButton(from buttons: [UIButton], selectedButton: UIButton?) {
        buttons.forEach { button in
            button.isSelected = (button == selectedButton)
        }
        updateButtonStyles(for: buttons)
    }
    
    @objc private func sizeButtonTapped(_ sender: UIButton) {
        selectButton(from: [bigSizeButton, middleSizeButton, smallSizeButton], selectedButton: sender)
        if sender == bigSizeButton { viewModel.modifyDogInfoRequest.size = .big }
        else if sender == middleSizeButton { viewModel.modifyDogInfoRequest.size = .middle }
        else { viewModel.modifyDogInfoRequest.size = .small }
    }
    
    @objc private func genderButtonTapped(_ sender: UIButton) {
        selectButton(from: [maleButton, femaleButton], selectedButton: sender)
        viewModel.modifyDogInfoRequest.gender = maleButton.isSelected ? .male : .female
    }
    
    @objc private func neuterButtonTapped(_ sender: UIButton) {
        selectButton(from: [isNeuterButton, nonNeuterButton], selectedButton: sender)
        viewModel.modifyDogInfoRequest.isNeuter = isNeuterButton.isSelected ? true : false
    }
    
    private func updateButtonStyles(for buttons: [UIButton]) {
        if buttons == [maleButton, femaleButton] || buttons == [isNeuterButton, nonNeuterButton] {
            buttons.forEach {
                if $0.isSelected {
                    $0.backgroundColor = .secondary300
                    $0.setTitleColor(.neutral1, for: .normal)
                    $0.layer.borderWidth = 0
                } else {
                    $0.setTitleColor(.neutral6, for: .normal)
                    $0.layer.borderWidth = 2
                    $0.backgroundColor = .clear
                }
            }
        } else {
            buttons.forEach {
                if $0.isSelected {
                    $0.setTitleColor(.dark, for: .normal)
                    $0.backgroundColor = ColorSet.fromHex("AFF4C6")
                } else {
                    $0.setTitleColor(.neutral7, for: .normal)
                    $0.backgroundColor = .neutral4
                }
            }
        }
    }
    private func setDogData(_ item: GetMyDogDetailDTO) {
        
        reverseView()
        imageView.loadImage(url: item.profileImg)
        infoTextView.text = item.description
        let age = item.birthday.extractYearMonth()
        if let year = age?.0 {
            yearDropdownButton.setSelectedItem(title: "\(year)년")
        }
        
        if let month = age?.1 {
            monthDropdownButton.setSelectedItem(title: "\(month)월")
        }
        
        switch item.size {
        case .big: selectButton(from: [bigSizeButton, middleSizeButton, smallSizeButton], selectedButton: bigSizeButton)
        case .middle: selectButton(from: [bigSizeButton, middleSizeButton, smallSizeButton], selectedButton: middleSizeButton)
        case .small: selectButton(from: [bigSizeButton, middleSizeButton, smallSizeButton], selectedButton: smallSizeButton)
        default: break
        }
        
        switch item.gender {
        case .male: selectButton(from: [maleButton, femaleButton], selectedButton: maleButton)
        case .female: selectButton(from: [maleButton, femaleButton], selectedButton: femaleButton)
        default: break
        }
        
        switch item.isNeuter {
        case true: selectButton(from: [isNeuterButton, nonNeuterButton], selectedButton: isNeuterButton)
        case false: selectButton(from: [isNeuterButton, nonNeuterButton], selectedButton: nonNeuterButton)
        }
        personalityCollectionView.setSelectedKeyword(item: item.char)
        addInfoCollectionView.setSelectedKeyword(item: item.require)
    }
    
    @objc private func modifyButtonTapped() {
        viewModel.modifyDogInfo()
    }
    
    
}

extension ModifyDogViewController {
    
    private func setupLayOuts() {
        [scrollView, modifyButton].forEach {
            view.addSubview($0)
        }
        [imageView, cameraImageView, certButton,
         speciesGuideLabel, speciesLabel, speciesTextField,
         nameGuideLabel, nameLabel, nameTextField,
         birthGuideLabel, yearDropdownButton, monthDropdownButton,
         genderGuideLabel, maleButton, femaleButton,
         isNeuterGuideLabel, isNeuterButton, nonNeuterButton,
         sizeGuideLabel, bigSizeButton, middleSizeButton, smallSizeButton,
         sizeLabel, personalityGuideLabel, personalityCollectionView,
         addInfoLabel, addInfoCollectionView, infoLabel, infoTextView
        ].forEach {
            scrollView.addSubview($0)
        }
        imageView.addSubview(spinner)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(modifyButton.snp.top).inset(10)
        }
        imageView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top).offset(16)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(80)
        }
        cameraImageView.snp.makeConstraints {
            $0.trailing.bottom.equalTo(imageView)
            $0.size.equalTo(24)
        }
        certButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(41)
        }
        speciesGuideLabel.snp.makeConstraints {
            $0.top.equalTo(certButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.height.equalTo(14)
        }
        speciesLabel.snp.makeConstraints {
            $0.top.equalTo(speciesGuideLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(37)
        }
        speciesTextField.snp.makeConstraints {
            $0.top.equalTo(speciesGuideLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(37)
        }
        nameGuideLabel.snp.makeConstraints {
            $0.top.equalTo(speciesTextField.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(nameGuideLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(37)
        }
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameGuideLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(37)
        }
        birthGuideLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.height.equalTo(17)
        }
        yearDropdownButton.snp.makeConstraints {
            $0.top.equalTo(birthGuideLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(view.snp.centerX).inset(4)
            $0.height.equalTo(40)
        }
        monthDropdownButton.snp.makeConstraints {
            $0.top.equalTo(birthGuideLabel.snp.bottom).offset(4)
            $0.leading.equalTo(view.snp.centerX).offset(4)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        genderGuideLabel.snp.makeConstraints {
            $0.top.equalTo(monthDropdownButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.height.equalTo(17)
        }
        maleButton.snp.makeConstraints {
            $0.top.equalTo(genderGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(view.snp.centerX).inset(4)
            $0.height.equalTo(37)
        }
        femaleButton.snp.makeConstraints {
            $0.top.equalTo(genderGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(view.snp.centerX).offset(4)
            $0.height.equalTo(37)
        }
        isNeuterGuideLabel.snp.makeConstraints {
            $0.top.equalTo(femaleButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.height.equalTo(17)
        }
        isNeuterButton.snp.makeConstraints {
            $0.top.equalTo(isNeuterGuideLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(view.snp.centerX).inset(4)
            $0.height.equalTo(37)
        }
        nonNeuterButton.snp.makeConstraints {
            $0.top.equalTo(isNeuterGuideLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(view.snp.centerX).offset(4)
            $0.height.equalTo(37)
        }
        sizeGuideLabel.snp.makeConstraints {
            $0.top.equalTo(nonNeuterButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview()
            $0.height.equalTo(19)
        }
        bigSizeButton.snp.makeConstraints {
            $0.top.equalTo(sizeGuideLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
            $0.width.equalTo(54)
            $0.height.equalTo(25)
        }
        middleSizeButton.snp.makeConstraints {
            $0.top.equalTo(sizeGuideLabel.snp.bottom).offset(12)
            $0.leading.equalTo(bigSizeButton.snp.trailing).offset(16)
            $0.width.equalTo(54)
            $0.height.equalTo(25)
        }
        smallSizeButton.snp.makeConstraints {
            $0.top.equalTo(sizeGuideLabel.snp.bottom).offset(12)
            $0.leading.equalTo(middleSizeButton.snp.trailing).offset(16)
            $0.width.equalTo(54)
            $0.height.equalTo(25)
        }
        sizeLabel.snp.makeConstraints {
            $0.top.equalTo(smallSizeButton.snp.bottom).offset(12)
            $0.leading.equalTo(bigSizeButton.snp.leading).offset(8)
        }
        personalityGuideLabel.snp.makeConstraints {
            $0.top.equalTo(sizeLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview()
            $0.height.equalTo(19)
        }
        personalityCollectionView.snp.makeConstraints {
            $0.top.equalTo(personalityGuideLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        addInfoLabel.snp.makeConstraints {
            $0.top.equalTo(personalityCollectionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview()
            $0.height.equalTo(19)
        }
        addInfoCollectionView.snp.makeConstraints {
            $0.top.equalTo(addInfoLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(addInfoCollectionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview()
            $0.height.equalTo(14)
        }
        infoTextView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(300)
            $0.bottom.equalTo(scrollView.snp.bottom).inset(30)
        }
        modifyButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        spinner.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    private func setupComponents() {
        [bigSizeButton, middleSizeButton, smallSizeButton].forEach {
            $0.backgroundColor = .neutral4
            $0.titleLabel?.font = FontSet.pretendardSemiBold(size: 14)
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.setTitleColor(.neutral7, for: .normal)
        }
        [maleButton, femaleButton, isNeuterButton, nonNeuterButton].forEach {
            $0.titleLabel?.font = FontSet.pretendardMedium(size: 14)
            $0.layer.borderColor = ColorSet.neutral6.cgColor
            $0.layer.borderWidth = 2
            $0.setTitleColor(.neutral6, for: .normal)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8
        }
        [speciesGuideLabel, nameGuideLabel, birthGuideLabel, genderGuideLabel, isNeuterGuideLabel, infoLabel].forEach {
            $0.font = FontSet.pretendardSemiBold(size: 12)
            $0.textColor = .neutral6
        }
        [sizeGuideLabel, personalityGuideLabel, addInfoLabel].forEach {
            $0.font = FontSet.pretendardBold(size: 16)
            $0.textColor = .neutral9
        }
        [nameLabel, speciesLabel].forEach {
            $0.font = FontSet.pretendardMedium(size: 14)
            $0.textColor = .neutral11
        }
        infoTextView.layer.borderWidth = 2
        infoTextView.layer.borderColor = ColorSet.neutral6.cgColor
        infoTextView.layer.masksToBounds = true
        infoTextView.layer.cornerRadius = 8
        infoTextView.textColor = .neutral10
        infoTextView.font = FontSet.pretendardMedium(size: 14)
        infoTextView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 8)
        
        sizeLabel.font = FontSet.pretendardMedium(size: 12)
        sizeLabel.textColor = .neutral8
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
