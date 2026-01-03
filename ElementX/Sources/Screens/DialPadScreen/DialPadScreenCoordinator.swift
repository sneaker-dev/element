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

struct DialPadScreenCoordinatorParameters {
    let userSession: UserSessionProtocol
    let userIndicatorController: UserIndicatorControllerProtocol
    let appSettings: AppSettings
    let analytics: AnalyticsService
}

enum DialPadScreenCoordinatorAction {
    case createdRoom(JoinedRoomProxyProtocol)
}

final class DialPadScreenCoordinator: CoordinatorProtocol {
    private var viewModel: DialPadScreenViewModelProtocol
    private let actionsSubject: PassthroughSubject<DialPadScreenCoordinatorAction, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    var actions: AnyPublisher<DialPadScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(parameters: DialPadScreenCoordinatorParameters) {
        viewModel = DialPadScreenViewModel(userSession: parameters.userSession,
                                            analytics: parameters.analytics,
                                            userIndicatorController: parameters.userIndicatorController)
    }
    
    func start() {
        viewModel.actions.sink { [weak self] action in
            guard let self else { return }
            switch action {
            case .createdRoom(let roomProxy):
                actionsSubject.send(.createdRoom(roomProxy))
            }
        }
        .store(in: &cancellables)
    }
        
    func toPresentable() -> AnyView {
        AnyView(DialPadScreen(context: viewModel.context))
    }
}

