// Copyright (c) 2015 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

// <http://owensd.io/2015/05/12/optionals-if-let.html>
func hasValue<T>(_ value: T?) -> Bool {
    switch (value) {
    case .some: return true
    case .none: return false
    }
}
