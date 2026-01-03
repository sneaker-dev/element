//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import MatrixRustSDK
import SwiftUI

typealias DialPadScreenViewModelType = StateStoreViewModel<DialPadScreenViewState, DialPadScreenViewAction>

class DialPadScreenViewModel: DialPadScreenViewModelType, DialPadScreenViewModelProtocol {
    private let userSession: UserSessionProtocol
    private let analytics: AnalyticsService
    private let userIndicatorController: UserIndicatorControllerProtocol
    
    private var actionsSubject: PassthroughSubject<DialPadScreenViewModelAction, Never> = .init()
    
    var actions: AnyPublisher<DialPadScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(userSession: UserSessionProtocol,
         analytics: AnalyticsService,
         userIndicatorController: UserIndicatorControllerProtocol) {
        self.userSession = userSession
        self.analytics = analytics
        self.userIndicatorController = userIndicatorController
        
        let bindings = DialPadScreenViewStateBindings()
        
        super.init(initialViewState: DialPadScreenViewState(phoneNumber: "",
                                                           bindings: bindings))
    }
    
    override func process(viewAction: DialPadScreenViewAction) {
        switch viewAction {
        case .dial:
            Task { await createRoomFromPhoneNumber() }
        case .appendDigit(let digit):
            state.phoneNumber += digit
        case .deleteDigit:
            if !state.phoneNumber.isEmpty {
                state.phoneNumber.removeLast()
            }
        case .clear:
            state.phoneNumber = ""
        }
    }
    
    private func createRoomFromPhoneNumber() async {
        defer {
            hideLoadingIndicator()
        }
        showLoadingIndicator()
        
        let roomName = state.phoneNumber
        
        switch await userSession.clientProxy.createRoom(name: roomName,
                                                        topic: nil,
                                                        isRoomPrivate: true,
                                                        isKnockingOnly: false,
                                                        userIDs: [],
                                                        avatarURL: nil,
                                                        aliasLocalPart: nil) {
        case .success(let roomID):
            guard case let .joined(roomProxy) = await userSession.clientProxy.roomForIdentifier(roomID) else {
                state.bindings.alertInfo = AlertInfo(id: .failedCreatingRoom,
                                                     title: L10n.commonError,
                                                     message: L10n.screenStartChatErrorStartingChat)
                return
            }
            analytics.trackCreatedRoom(isDM: false)
            actionsSubject.send(.createdRoom(roomProxy))
        case .failure:
            state.bindings.alertInfo = AlertInfo(id: .failedCreatingRoom,
                                                 title: L10n.commonError,
                                                 message: L10n.screenStartChatErrorStartingChat)
        }
    }
    
    private static let loadingIndicatorIdentifier = "\(DialPadScreenViewModel.self)-Loading"
    
    private func showLoadingIndicator() {
        userIndicatorController.submitIndicator(UserIndicator(id: Self.loadingIndicatorIdentifier,
                                                              type: .modal(progress: .indeterminate, interactiveDismissDisabled: true, allowsInteraction: false),
                                                              title: L10n.commonLoading,
                                                              persistent: true))
    }
    
    private func hideLoadingIndicator() {
        userIndicatorController.retractIndicatorWithId(Self.loadingIndicatorIdentifier)
    }
}

