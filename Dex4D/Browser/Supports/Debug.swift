// Copyright DApps Platform Inc. All rights reserved.

import Foundation

var isDebug: Bool {
    #if DEBUG
        return true
    #else
        return false
    #endif
}
