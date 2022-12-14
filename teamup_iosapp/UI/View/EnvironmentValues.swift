//
//  EnvironmentValues.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/12/13.
//

import SwiftUI

// define env key to store our modal mode values
struct ModalModeKey: EnvironmentKey {
    static let defaultValue = Binding<Bool>.constant(false)
}

struct TabBarSelectionKey: EnvironmentKey {
    static let defaultValue = Binding<Tab>.constant(.home)
}

// define modalMode value
extension EnvironmentValues {
    var modalMode: Binding<Bool> {
        get {
            self[ModalModeKey.self]
        }
        set {
            self[ModalModeKey.self] = newValue
        }
    }

    var tabBarSelection: Binding<Tab> {
        get {
            self[TabBarSelectionKey.self]
        }
        set {
            self[TabBarSelectionKey.self] = newValue
        }
    }
}
