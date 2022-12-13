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

// define modalMode value
extension EnvironmentValues {
    var modalMode: Binding<Bool> {
        get {
            return self[ModalModeKey.self]
        }
        set {
            self[ModalModeKey.self] = newValue
        }
    }
}
