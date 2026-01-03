//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation
import MatrixRustSDK

enum DialPadScreenErrorType: Error {
    case failedCreatingRoom
    case unknown
}

enum DialPadScreenViewModelAction {
    case createdRoom(JoinedRoomProxyProtocol)
}

struct DialPadScreenViewState: BindableState {
    var phoneNumber: String
    var canDial: Bool {
        !phoneNumber.isEmpty
    }
    
    var bindings: DialPadScreenViewStateBindings
}

struct DialPadScreenViewStateBindings {
    var alertInfo: AlertInfo<DialPadScreenErrorType>?
}

enum DialPadScreenViewAction {
    case dial
    case appendDigit(String)
    case deleteDigit
    case clear
}

