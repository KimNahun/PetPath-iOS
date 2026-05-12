//
//  ToastMessenger.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import UIKit

final class ToastMessenger {
    
    static let shared = ToastMessenger()
    
    private init() { }
    
    func showToast(message: String) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return
            }
            let backgroundColor: UIColor = .secondary900.withAlphaComponent(0.8)
            let toastLabel = PaddingLabel(frame: CGRect(x: 16, y: window.frame.height - 81, width: window.frame.width - 32, height: 54))
            toastLabel.font = FontSet.pretendardRegular(size: 14)
            toastLabel.textAlignment = .left
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 5
            toastLabel.clipsToBounds = true
            toastLabel.backgroundColor = backgroundColor
            toastLabel.textColor = .neutral1
            window.addSubview(toastLabel)
            let animator = UIViewPropertyAnimator(duration: 3.0, curve: .easeOut) {
                toastLabel.alpha = 0.1
            }
            animator.addCompletion { _ in
                toastLabel.removeFromSuperview()
            }
            animator.startAnimation()
        }
    }
}
