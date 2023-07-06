//
//  Main.swift
//  QuickLookXD
//
//  Created by Ogbizi on 2023-07-05.
//

import CoreFoundation
import CoreServices
import QuickLook

//struct PluginConstants {
//    static let PRODUCT_ID = "com.qbrkts.QuickLookXDPlugin" as CFString
//    static let TYPE_ID = CFUUIDCreateFromString(kCFAllocatorDefault, PluginConstants.PRODUCT_ID)
//    static var INTERFACE_STUB = QLGeneratorInterfaceStruct()
//}

@objc class QuickLookGeneratorPlugin: NSObject {
    /// The registered plugin ID
    let typeID: CFUUID
    /// Pointer to the single instance of the quick look generator interface ``QuickLook.QLGenerator.QLGeneratorInterfaceStruct``
    let interfacePtr: UnsafeMutableRawPointer
    /// The number of references to the interface
    var refCount: UInt32

    init(typeID: CFUUID) {
        print("GeneratorPluginINIT!!!! \(String(describing: typeID))")
        self.typeID = typeID
        self.refCount = 0
        self.interfacePtr = UnsafeMutableRawPointer.allocate(
            byteCount: MemoryLayout<QLGeneratorInterfaceStruct>.size,
            alignment: MemoryLayout<QLGeneratorInterfaceStruct>.alignment)
        var interfaceStub = QLGeneratorInterfaceStruct()
        interfaceStub.QueryInterface = _PluginQueryInterface
        interfaceStub.AddRef = _PluginAddRef
        interfaceStub.Release = _PluginRelease
        self.interfacePtr.assumingMemoryBound(to: QLGeneratorInterfaceStruct.self).initialize(to: interfaceStub)
    }
    
    func prepareInterface() {
        print("PREPARE INTERFACE!!!! \(String(describing: typeID))")
        var interface = self.interfacePtr.assumingMemoryBound(to: QLGeneratorInterfaceStruct.self).pointee
        interface.CancelPreviewGeneration = _PluginCancelPreviewGeneration
        interface.CancelThumbnailGeneration = _PluginCancelThumbnailGeneration
        interface.GeneratePreviewForURL = _PluginGeneratePreviewForURL
        interface.GenerateThumbnailForURL = _PluginGenerateThumbnailForURL
    }
    
    func addRef() -> UInt32 {
        print("ADAD REF!!!!")
        self.refCount += 1;
        return self.refCount;
    }
    
    func deRef() -> UInt32 {
        print("DEDE REF!!!!")
        self.refCount -= 1;
        if (self.refCount == 0) {
            CFPlugInRemoveInstanceForFactory(self.typeID)
        }
        return self.refCount
    }
}

func _PluginQueryInterface(interfacePtr: UnsafeMutableRawPointer?, interfaceRefID: REFIID, pluginInstancePtr: UnsafeMutablePointer<LPVOID?>?) -> HRESULT {
    print("QueryInterface!!!! \(String(describing: interfaceRefID))")
    let interfaceID = CFUUIDCreateFromUUIDBytes(kCFAllocatorDefault, interfaceRefID)
        NSLog("InterfaceID: \(String(describing: interfaceID))")
    // TODO: check interface ID matches expected before assignment
    interfacePtr?.assumingMemoryBound(to: QuickLookGeneratorPlugin.self).pointee.prepareInterface()
    let refCount = _PluginAddRef(interfacePtr: interfacePtr)
    if refCount > 0 {
        pluginInstancePtr?.pointee = interfacePtr
        return S_OK
    } else {
        pluginInstancePtr?.pointee = nil
        return EAI_FAIL
    }
}

func _PluginAddRef(interfacePtr: UnsafeMutableRawPointer?) -> ULONG {
    print("ADD REF!!!!!!")
    return interfacePtr?.assumingMemoryBound(to: QuickLookGeneratorPlugin.self).pointee.addRef() ?? 0;
}

func _PluginRelease(interfacePtr: UnsafeMutableRawPointer?) -> ULONG {
    print("Release!!!!!!")
    let pluginPtr = interfacePtr?.assumingMemoryBound(to: QuickLookGeneratorPlugin.self)
    let refCount = pluginPtr?.pointee.deRef()
    if refCount == 0 {
        pluginPtr?.deinitialize(count: 1)
        pluginPtr?.deallocate()
    }
    return refCount ?? 0
}



// The thumbnail generation function to be implemented in GenerateThumbnailForURL.swift
func _PluginGenerateThumbnailForURL(interfacePtr: UnsafeMutableRawPointer?, request: QLThumbnailRequest?, url: CFURL?, contentTypeUTI: CFString?, options: CFDictionary?, maxSize: CGSize) -> OSStatus {
    return noErr
}

func _PluginCancelThumbnailGeneration(interfacePtr: UnsafeMutableRawPointer?, request: QLThumbnailRequest?) {
    // Implementation of cancel thumbnail generation
}

// The preview generation function to be implemented in GeneratePreviewForURL.swift
func _PluginGeneratePreviewForURL(interfacePtr: UnsafeMutableRawPointer?, request: QLPreviewRequest?, url: CFURL?, contentTypeUTI: CFString?, options: CFDictionary?) -> OSStatus {
    return noErr
}

func _PluginCancelPreviewGeneration(interfacePtr: UnsafeMutableRawPointer?, request: QLPreviewRequest?) {
    // Implementation of cancel preview generation
}

func QuickLookGeneratorPluginFactory(allocator: CFAllocator?, typeID: CFUUID?) -> UnsafeMutableRawPointer? {
    print("Factory init: \(String(describing: allocator)) \(String(describing: typeID))")
    let instance = QuickLookGeneratorPlugin(typeID: typeID!)
    return UnsafeMutableRawPointer(Unmanaged.passRetained(instance).toOpaque())
}

// Entry point: Register the Quick Look generator plug-in
func RegisterQuickLookGenerator() {
    let productID = "com.qbrkts.QuickLookXDPlugin" as CFString
    let typeID = CFUUIDCreateFromString(kCFAllocatorDefault, productID)
    print("Registering: \(String(describing: productID)) \(String(describing: typeID))")
    if !CFPlugInRegisterFactoryFunction(typeID!, QuickLookGeneratorPluginFactory) {
        // Handle error
        NSLog("Error registering Quick Look generator")
    }
}

// Cleanup: Unregister the Quick Look generator plug-in
func UnregisterQuickLookGenerator() {
    let productID = "com.qbrkts.QuickLookXDPlugin" as CFString
    let typeID = CFUUIDCreateFromString(kCFAllocatorDefault, productID)
    print("Unregistering: \(String(describing: productID)) \(String(describing: typeID))")
    CFPlugInUnregisterFactory(typeID)
}
