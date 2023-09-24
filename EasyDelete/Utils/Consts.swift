//
//  Constants.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 21.07.2021.
//

import UIKit
import Combine

struct Keys {
    static let givenName = "givenName"
    static let isDeleted = "isDeleted"
    static let dayOfDeletion = "dayOfDeletion"
    static let scheduledDayForDeletion = "scheduledDayForDeletion"
    static let remainingDaysForDeletion = "remainingDaysForDeletion"
    static let isFirstLaunch = "isFirstLaunch"
}

struct Image {
    static let onboardingStep1 = "onboarding-1"
    static let onboardingStep2 = "onboarding-2"
    static let onboardingStep3 = "onboarding-3"
    static let onboardingStep4 = "onboarding-4"
}

struct Strings {
    static let undefined = "UNDEFINED"
    
    static let errorLocalizedDescription = "NSLocalizedDescription"
    static let errorLocalizedFailureReason = "NSLocalizedFailureReason"
    
    struct Title {
        static let contactsListTitle = NSLocalizedString("contactsListTitle", comment: "")
        static let deletedContactsListTitle = NSLocalizedString("deletedContactsListTitle", comment: "")
        static let contactDetailScreenTitle = NSLocalizedString("contactDetailScreenTitle", comment: "")
        
        static let emailsSectionTitle = NSLocalizedString("emailsSectionTitle", comment: "")
        static let phoneNumbersSectionTitle = NSLocalizedString("phoneNumbersSectionTitle", comment: "")
        
        static let deleteActionSheetTitle = NSLocalizedString("deleteActionSheetTitle", comment: "")
        static let permissionAlertTitle = NSLocalizedString("permissionAlertTitle", comment: "")
        static let errorAlertTitle = NSLocalizedString("errorAlertTitle", comment: "")
        static let noContactsAlertTitle = NSLocalizedString("noContactsAlertTitle", comment: "")
        static let selectContactAlertTitle = NSLocalizedString("selectContactAlertTitle", comment: "")
        
        static let okButtonTitle = NSLocalizedString("okButtonTitle", comment: "")
        static let cancelButtonTitle = NSLocalizedString("cancelButtonTitle", comment: "")
        static let confirmButtonTitle = NSLocalizedString("confirmButtonTitle", comment: "")
        static let deleteButtonTitle = NSLocalizedString("deleteButtonTitle", comment: "")
        static let deletedButtonTitle = NSLocalizedString("deletedButtonTitle", comment: "")
        static let doneButtonTitle = NSLocalizedString("doneButtonTitle", comment: "")
        static let manageButtonTitle = NSLocalizedString("manageButtonTitle", comment: "")
        static let openSettingsButtonTitle = NSLocalizedString("openSettingsButtonTitle", comment: "")
        static let recoverButtonTitle = NSLocalizedString("recoverButtonTitle", comment: "")
        static let selectButtonTitle = NSLocalizedString("selectButtonTitle", comment: "")
        static let selectAllButtonTitle = NSLocalizedString("selectAllButtonTitle", comment: "")
        static let unselectAllButtonTitle = NSLocalizedString("unselectAllButtonTitle", comment: "")
    }
    
    struct Placeholder {
        static let emailLabelPlaceholder = NSLocalizedString("emailLabelPlaceholder", comment: "")
        static let mobileLabelPlaceholder = NSLocalizedString("mobileLabelPlaceholder", comment: "")
    }
    
    struct Text {
        static let contactsCountText = NSLocalizedString("contactsCountText", comment: "")
        static let remainingDaysCountText = NSLocalizedString("remainingDaysCountText", comment: "")
        static let noResultsText = NSLocalizedString("noResultsText", comment: "")
        static let settingsText = NSLocalizedString("settingsText", comment: "")
        static let actionSheetPluralText = NSLocalizedString("actionSheetPluralText", comment: "")
        static let actionSheetText = NSLocalizedString("actionSheetText", comment: "")
        static let noContactsText = NSLocalizedString("noContactsText", comment: "")
        static let deletionSuccessfulText = NSLocalizedString("deletionSuccessfulText", comment: "")
        static let recoverySuccessfulText = NSLocalizedString("recoverySuccessfulText", comment: "")
    }
    
    struct Onboarding {
        static let onboardingStepStartButtonTitle = NSLocalizedString("onboardingStepStartButtonTitle", comment: "")
        static let onboardingStepButtonTitle = NSLocalizedString("onboardingStepButtonTitle", comment: "")
        static let onboardingStepEndButtonTitle = NSLocalizedString("onboardingStepEndButtonTitle", comment: "")
        
        static let onboardingStep1Title = NSLocalizedString("onboardingStep1Title", comment: "")
        static let onboardingStep2Title = NSLocalizedString("onboardingStep2Title", comment: "")
        static let onboardingStep3Title = NSLocalizedString("onboardingStep3Title", comment: "")
        static let onboardingStep4Title = NSLocalizedString("onboardingStep4Title", comment: "")
        
        static let onboardingStep1Message = NSLocalizedString("onboardingStep1Message", comment: "")
        static let onboardingStep2Message = NSLocalizedString("onboardingStep2Message", comment: "")
        static let onboardingStep3MessagePart1 = NSLocalizedString("onboardingStep3MessagePart1", comment: "")
        static let onboardingStep3MessagePart2 = NSLocalizedString("onboardingStep3MessagePart2", comment: "")
        static let onboardingStep3MessagePart3 = NSLocalizedString("onboardingStep3MessagePart3", comment: "")
        static let onboardingStep4MessagePart1 = NSLocalizedString("onboardingStep4MessagePart1", comment: "")
        static let onboardingStep4MessagePart2 = NSLocalizedString("onboardingStep4MessagePart2", comment: "")
    }
}
