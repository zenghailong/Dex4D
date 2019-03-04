//
//  EthereumAddressRule.swift
//  Dex4D
//
//  Created by zeng hai long on 18/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

struct EthereumAddressRule {
    
    public static func isValid(address: String?) -> Error? {
        guard let str = address else {
            return Errors.invalidAddress
        }
        return !CryptoAddressValidator.isValidAddress(str) ? Errors.invalidAddress : nil
    }
}

enum AddressValidatorType {
    case ethereum
    
    var addressLength: Int {
        switch self {
        case .ethereum: return 42
        }
    }
}

struct CryptoAddressValidator {
    static func isValidAddress(_ value: String?, type: AddressValidatorType = .ethereum) -> Bool {
        return value?.range(of: "^0x[a-fA-F0-9]{40}$", options: .regularExpression) != nil
    }
}
