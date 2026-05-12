//
//  BottomSheetViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/24/25.
//

import UIKit

final class BottomSheetViewController: UIViewController {
    enum BottomSheetViewState {
        case expanded
        case normal
    }

    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = !isTouchPassable
        return view
    }()

    private lazy var bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = self.cornerRadius
        view.layer.cornerCurve = .continuous
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()

    private let dragIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        view.layer.cornerRadius = 1.5
        view.alpha = 0
        return view
    }()

    private var bottomSheetViewTopConstraint: NSLayoutConstraint!

    var defaultHeight: CGFloat = 500
    var cornerRadius: CGFloat = 16
    var dimmedAlpha: CGFloat = 0.4
    var bottomSheetPanMinTopConstant: CGFloat = 40
    var isPannedable: Bool = false
    private lazy var bottomSheetPanStartingTopConstant: CGFloat = bottomSheetPanMinTopConstant

    private let isTouchPassable: Bool
    private let contentViewController: UIViewController

    init(contentViewController: UIViewController,
         defaultHeight: CGFloat,
         cornerRadius: CGFloat = 16,
         dimmedAlpha: CGFloat = 0.4,
         isPannedable: Bool = false,
         isTouchPassable: Bool = false
    ) {
        self.contentViewController = contentViewController
        self.defaultHeight = defaultHeight
        self.cornerRadius = cornerRadius
        self.dimmedAlpha = dimmedAlpha
        self.isPannedable = isPannedable
        self.isTouchPassable = isTouchPassable

        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
        self.configureLayout()
        self.configureDimmedTapGesture()

        if isPannedable {
            self.configureViewPanGesture()
            self.dragIndicatorView.alpha = 1
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showBottomSheet()
    }

    private func showBottomSheet(atState: BottomSheetViewState = .normal) {
        let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding = view.safeAreaInsets.bottom
        let defaultTopConstant = (safeAreaHeight + bottomPadding) - defaultHeight

        if atState == .normal {
            bottomSheetViewTopConstraint.constant = max(defaultTopConstant, bottomSheetPanMinTopConstant)
        } else {
            bottomSheetViewTopConstraint.constant = bottomSheetPanMinTopConstant
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.dimmedView.alpha = self.dimmedAlpha
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK: Configure
extension BottomSheetViewController {
    private func configureUI() {
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        bottomSheetView.addSubview(dragIndicatorView)

        addChild(contentViewController)
        bottomSheetView.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)
    }

    private func configureLayout() {
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        dragIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            bottomSheetView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            // 아래 제약 조건 제거: bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomSheetView.heightAnchor.constraint(equalToConstant: defaultHeight),
            
            dragIndicatorView.widthAnchor.constraint(equalToConstant: 60),
            dragIndicatorView.heightAnchor.constraint(equalToConstant: 3),
            dragIndicatorView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            dragIndicatorView.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 12),
            
            contentViewController.view.topAnchor.constraint(equalTo: dragIndicatorView.bottomAnchor, constant: 8),
            contentViewController.view.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor)
        ])

        // 상단 제약 조건으로만 위치 조정 (애니메이션 시 변경)
        let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding = view.safeAreaInsets.bottom
        let initialTopConstant = safeAreaHeight + bottomPadding
        bottomSheetViewTopConstraint = bottomSheetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: initialTopConstant)
        bottomSheetViewTopConstraint.isActive = true
    }

    private func configureDimmedTapGesture() {
        guard !isTouchPassable else { return }
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped(_:)))
        dimmedView.addGestureRecognizer(dimmedTap)
    }

    private func configureViewPanGesture() {
        let viewPan = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
        viewPan.delaysTouchesBegan = false
        viewPan.delaysTouchesEnded = false
        bottomSheetView.addGestureRecognizer(viewPan)
    }
}

// MARK: Gesture
extension BottomSheetViewController {
    @objc private func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        self.hideBottomSheetAndGoBack()
    }
    
    // 해당 메소드는 사용자가 view를 드래그하면 실행됨
    @objc private func viewPanned(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: view)
        
        let velocity = panGestureRecognizer.velocity(in: view)
        
        switch panGestureRecognizer.state {
        case .began:
            bottomSheetPanStartingTopConstant = bottomSheetViewTopConstraint.constant
        case .changed:
            if bottomSheetPanStartingTopConstant + translation.y > bottomSheetPanMinTopConstant {
                bottomSheetViewTopConstraint.constant = bottomSheetPanStartingTopConstant + translation.y
            }
            
        case .ended:
            if velocity.y > 1500 {
                hideBottomSheetAndGoBack()
                return
            }
            
            let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
            let bottomPadding = view.safeAreaInsets.bottom
            let defaultPadding = safeAreaHeight+bottomPadding - defaultHeight
            
            let nearestValue = nearest(to: bottomSheetViewTopConstraint.constant, inValues: [bottomSheetPanMinTopConstant, defaultPadding, safeAreaHeight + bottomPadding])
            
            if nearestValue == bottomSheetPanMinTopConstant {
                showBottomSheet(atState: .expanded)
            } else if nearestValue == defaultPadding {
                // Bottom Sheet을 .normal 상태로 보여주기
                showBottomSheet(atState: .normal)
            } else {
                // Bottom Sheet을 숨기고 현재 View Controller를 dismiss시키기
                hideBottomSheetAndGoBack()
            }
        default:
            break
        }
    }
}

extension BottomSheetViewController {
    private func hideBottomSheetAndGoBack() {
        let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding = view.safeAreaInsets.bottom
        bottomSheetViewTopConstraint.constant = safeAreaHeight + bottomPadding
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.dimmedView.alpha = 0.0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    //주어진 CGFloat 배열의 값 중 number로 주어진 값과 가까운 값을 찾아내는 메소드
    private func nearest(to number: CGFloat, inValues values: [CGFloat]) -> CGFloat {
        guard let nearestVal = values.min(by: { abs(number - $0) < abs(number - $1) })
        else { return number }
        return nearestVal
    }
    
}
