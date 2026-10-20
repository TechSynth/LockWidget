import Foundation
import AppKit

public enum SpaceLevel: Int32 {
    case `default` = 0
    case securityAgent = 200
    case screenLock = 300
    case notificationCenterAtScreenLock = 400
}

@MainActor
public final class SkyLightHelper: @unchecked Sendable {
    public static let shared = SkyLightHelper()
    
    private typealias F_SLSMainConnectionID = @convention(c) () -> Int32
    private typealias F_SLSSpaceCreate = @convention(c) (Int32, Int32, Int32) -> Int32
    private typealias F_SLSSpaceSetAbsoluteLevel = @convention(c) (Int32, Int32, Int32) -> Int32
    private typealias F_SLSShowSpaces = @convention(c) (Int32, CFArray) -> Int32
    private typealias F_SLSSpaceAddWindowsAndRemoveFromSpaces = @convention(c) (Int32, Int32, CFArray, Int32) -> Int32
    
    private let connection: Int32
    private let space: Int32
    private let addWindowsFn: F_SLSSpaceAddWindowsAndRemoveFromSpaces
    
    private init() {
        let handle = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight", RTLD_NOW)
        let mainConn = unsafeBitCast(dlsym(handle, "SLSMainConnectionID"), to: F_SLSMainConnectionID.self)
        let spaceCreate = unsafeBitCast(dlsym(handle, "SLSSpaceCreate"), to: F_SLSSpaceCreate.self)
        let setLevel = unsafeBitCast(dlsym(handle, "SLSSpaceSetAbsoluteLevel"), to: F_SLSSpaceSetAbsoluteLevel.self)
        let showSpaces = unsafeBitCast(dlsym(handle, "SLSShowSpaces"), to: F_SLSShowSpaces.self)
        self.addWindowsFn = unsafeBitCast(dlsym(handle, "SLSSpaceAddWindowsAndRemoveFromSpaces"), to: F_SLSSpaceAddWindowsAndRemoveFromSpaces.self)
        
        self.connection = mainConn()
        self.space = spaceCreate(self.connection, 1, 0)
        _ = setLevel(self.connection, self.space, SpaceLevel.notificationCenterAtScreenLock.rawValue)
        _ = showSpaces(self.connection, [self.space] as CFArray)
    }
    
    public func attachWindowToLockSpace(_ windowNumber: Int) {
        _ = addWindowsFn(
            connection,
            space,
            [Int32(windowNumber)] as CFArray,
            7
        )
    }
}
