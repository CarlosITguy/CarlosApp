//
//  HapticFeedback.swift
//  CarlosV - Shared UI Components
//
//  Created by Carlos Valderrama on 3/1/25.
//

import UIKit

// MARK: - Haptic Feedback Utility

struct HapticFeedback {
    /// Triggers impact haptic feedback
    /// - Parameter style: The intensity of the impact feedback
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.impactOccurred()
    }
    
    /// Triggers notification haptic feedback
    /// - Parameter type: The type of notification feedback
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(type)
    }
    
    /// Triggers selection haptic feedback
    static func selection() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
}