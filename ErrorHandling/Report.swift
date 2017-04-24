// Copyright (c) 2017 Christian Tietze
//
// See the file LICENSE for copying permission.

public struct Report {

    public let error: Error
    public let additionalInfo: String?

    public var localizedDescription: String {

        let errorMessage = error.localizedDescription
        let additionalInfo: String = {
            guard let info = self.additionalInfo else { return "" }
            return "\n\(info)"
        }()

        return "\(errorMessage)\(additionalInfo)"
    }

    public init(error: Error, additionalInfo: String?) {

        self.error = error
        self.additionalInfo = additionalInfo
    }
}
