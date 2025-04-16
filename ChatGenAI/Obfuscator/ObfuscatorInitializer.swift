//
//  ObfuscatorInitializer.swift
//  LillyObfuscator
//
//  Created by Gaurav Sharma on 8/13/19.
//  Copyright © 2019 Lilly.com. All rights reserved.
//

import Foundation

/// An ObfuscatorInitializable component can call `self.obfuscatorInitializer.setup(salt:)`
public protocol ObfuscatorInitializable {
    var obfuscatorInitializer: ObfuscatorInitializer { get }
}

/// Providing DefaultObfuscatorInitializer
public extension ObfuscatorInitializable {
    var obfuscatorInitializer: ObfuscatorInitializer {
        return DefaultObfuscatorInitializer()
    }
}

/// Initializer for `DefaultObfuscator`
public protocol ObfuscatorInitializer {
    /// Setup initializer with salt
    func setup(salt: String?)
}

/// Default implementation of Initializer for `DefaultObfuscator`
public enum DefaultObfuscatorInitializer: ObfuscatorInitializer {
    /// Setup initializer
    public func setup(salt: String? = nil) {
        if let salt = salt {
            DefaultObfuscator.shared = DefaultObfuscator(salt: salt)
        } else {
            DefaultObfuscator.shared = DefaultObfuscator()
        }
    }

    // Initializer is stateless
    case stateless
    public init() {
        self = .stateless
    }
}
