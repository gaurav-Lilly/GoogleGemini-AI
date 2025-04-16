//
//  LillyObfuscator.swift
//  LillyObfuscator
//
//  Created by Gaurav Sharma on 6/17/19.
//  Copyright © 2019 Lilly.com. All rights reserved.
//

import Foundation

/// Data type a string is obfuscated to.
// TODO: Change `ObfuscatedType` to an associatedtype in `Obfuscator` in Swift 5.1.
public typealias ObfuscatedType = [UInt8]

/// An Obfuscatable component is able to access a `sharedObfuscator`.
public protocol Obfuscatable {
    var sharedObfuscator: Obfuscator { get }
}

/// The default implementation of Obfuscator.
public extension Obfuscatable {
    var sharedObfuscator: Obfuscator {
        return DefaultObfuscator.shared
    }
}

public enum PrintableType: CaseIterable {
    case constant
    case staticConstant
    case lazyVariable
}

/// Obfuscator is able to `obfuscate` and `reveal` strings.
public protocol Obfuscator {
    static var shared: Obfuscator! { get }

    /// Obfuscate a string to `ObfuscatedType`.
    @discardableResult func obfuscate(string: String, printableTypes: [PrintableType], enableAssertionFailure: Bool) -> ObfuscatedType

    /// Reveal an obfuscated string from `ObfuscatedType`.
    func reveal(obfuscated: ObfuscatedType) -> String
}

/// Default arguments
public extension Obfuscator {
    @discardableResult func obfuscate(string: String, printableTypes: [PrintableType] = [], enableAssertionFailure: Bool = false) -> ObfuscatedType {
        return obfuscate(string: string, printableTypes: printableTypes, enableAssertionFailure: enableAssertionFailure)
    }
}

/// A default obfuscator that obfuscate a string to [UInt8]
// From: https://gist.github.com/DejanEnspyra/80e259e3c9adf5e46632631b49cd1007
public struct DefaultObfuscator: Obfuscator {
    public static var shared: Obfuscator!

    /// The salt used to obfuscate and reveal the string.
    private var salt: String

    // MARK: - Initialization

    /// Init with default salt.
    public init() {
        salt = "\(String(describing: DefaultObfuscator.self))\(String(describing: Date.self))"
    }

    /// Init with a given salt.
    public init(salt: String) {
        self.salt = salt
    }

    // MARK: - Instance Methods

    /**
     This method obfuscates the string passed in using the salt
     that was used when the Obfuscator was initialized.

     - parameter string: the string to obfuscate

     - returns: the obfuscated string in a byte array
     */
    @discardableResult
    public func obfuscate(string: String, printableTypes: [PrintableType] = [], enableAssertionFailure: Bool = false) -> ObfuscatedType {
        let text = ObfuscatedType(string.utf8)
        let cipher = ObfuscatedType(salt.utf8)
        let length = cipher.count

        var obfuscated = ObfuscatedType()

        for character in text.enumerated() {
            obfuscated.append(character.element ^ cipher[character.offset % length])
        }

        #if DEBUG
            if !printableTypes.isEmpty {
                print("\n******** Obfuscator ********")
                print("Salt: '\(salt)'")
                print("Add the code below to your ObfuscationRepository")
                if printableTypes.contains(.constant) {
                    print("\n******** Singleton Version ********")
                    print("// Original string: '\(string)'")
                    print("let RENAME_ME_OBFUSCATED: \(ObfuscatedType.self) = \(obfuscated)")
                }
                if printableTypes.contains(.staticConstant) {
                    print("\n******** Static Version ********")
                    print("// Original string: '\(string)'")
                    print("static let RENAME_ME_OBFUSCATED = obfuscator.reveal(obfuscated: \(obfuscated))")
                }
                if printableTypes.contains(.lazyVariable) {
                    print("\n******** Protocol Version ********")
                    print("// Original string: '\(string)'")
                    print("lazy var RENAME_ME_OBFUSCATED = sharedObfuscator.reveal(obfuscated: \(obfuscated))")
                }
            }

            if enableAssertionFailure {
                print("\n******** IMPORTANT ********")
                assertionFailure("Remember to remove `obfuscate(string:)` from your codebase.")
            } else if !printableTypes.isEmpty {
                print("\n --------\n")
            }

        #endif

        return obfuscated
    }

    /**
     This method reveals the original string from the obfuscated
     byte array passed in. The salt must be the same as the one
     used to encrypt it in the first place.

     - parameter key: the byte array to reveal

     - returns: the original string
     */
    public func reveal(obfuscated: ObfuscatedType) -> String {
        let cipher = ObfuscatedType(salt.utf8)
        let length = cipher.count

        var decrypted = ObfuscatedType()

        for character in obfuscated.enumerated() {
            decrypted.append(character.element ^ cipher[character.offset % length])
        }

        return String(bytes: decrypted, encoding: .utf8)!
    }
}
