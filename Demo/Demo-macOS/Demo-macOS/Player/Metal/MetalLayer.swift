import Foundation
import AppKit

// workaround for MoltenVK problem that causes flicker
// https://github.com/mpv-player/mpv/pull/13651
class MetalLayer: CAMetalLayer {

    // workaround for a MoltenVK that sets the drawableSize to 1x1 to forcefully complete
    // the presentation, this causes flicker and the drawableSize possibly staying at 1x1
    override var drawableSize: CGSize {
        get { return super.drawableSize }
        set {
            if Int(newValue.width) > 1 && Int(newValue.height) > 1 {
                super.drawableSize = newValue
            }
        }
    }
    
    // Hack for fix [target-colorspace-hint] option:
    // Update wantsExtendedDynamicRangeContent need run in main thread to activate screen EDR mode, other thread can't activate
    override var wantsExtendedDynamicRangeContent: Bool  {
        get {
            return super.wantsExtendedDynamicRangeContent
        }
        set {
            if Thread.isMainThread {
                super.wantsExtendedDynamicRangeContent = newValue
            } else {
                DispatchQueue.main.sync {
                    super.wantsExtendedDynamicRangeContent = newValue
                }
            }
        }
    }
}


extension MTLPixelFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid: return "Invalid"
        case .a8Unorm: return "A8Unorm"
        case .r8Unorm: return "R8Unorm"
        case .r8Unorm_srgb: return "R8UnormSrgb"
        case .r8Snorm: return "R8Snorm"
        case .r8Uint: return "R8Uint"
        case .r8Sint: return "R8Sint"
        case .r16Unorm: return "R16Unorm"
        case .r16Snorm: return "R16Snorm"
        case .r16Uint: return "R16Uint"
        case .r16Sint: return "R16Sint"
        case .r16Float: return "R16Float"
        case .rg8Unorm: return "RG8Unorm"
        case .rg8Unorm_srgb: return "RG8UnormSrgb"
        case .rg8Snorm: return "RG8Snorm"
        case .rg8Uint: return "RG8Uint"
        case .rg8Sint: return "RG8Sint"
        case .r32Uint: return "R32Uint"
        case .r32Sint: return "R32Sint"
        case .r32Float: return "R32Float"
        case .rg16Unorm: return "RG16Unorm"
        case .rg16Snorm: return "RG16Snorm"
        case .rg16Uint: return "RG16Uint"
        case .rg16Sint: return "RG16Sint"
        case .rg16Float: return "RG16Float"
        case .rgba8Unorm: return "RGBA8Unorm"
        case .rgba8Unorm_srgb: return "RGBA8UnormSrgb"
        case .rgba8Snorm: return "RGBA8Snorm"
        case .rgba8Uint: return "RGBA8Uint"
        case .rgba8Sint: return "RGBA8Sint"
        case .bgra8Unorm: return "BGRA8Unorm"
        case .bgra8Unorm_srgb: return "BGRA8UnormSrgb"
        case .rgb10a2Unorm: return "RGB10A2Unorm"
        case .rgb10a2Uint: return "RGB10A2Uint"
        case .rg11b10Float: return "RG11B10Float"
        case .rgb9e5Float: return "RGB9E5Float"
        case .rg32Uint: return "RG32Uint"
        case .rg32Sint: return "RG32Sint"
        case .rg32Float: return "RG32Float"
        case .rgba16Unorm: return "RGBA16Unorm"
        case .rgba16Snorm: return "RGBA16Snorm"
        case .rgba16Uint: return "RGBA16Uint"
        case .rgba16Sint: return "RGBA16Sint"
        case .rgba16Float: return "RGBA16Float"
        case .rgba32Uint: return "RGBA32Uint"
        case .rgba32Sint: return "RGBA32Sint"
        case .rgba32Float: return "RGBA32Float"
        case .depth32Float: return "Depth32Float"
        case .stencil8: return "Stencil8"
        case .depth24Unorm_stencil8: return "Depth24Unorm_Stencil8"
        case .depth32Float_stencil8: return "Depth32Float_Stencil8"
        case .gbgr422: return "GBGR422"
        case .bgrg422: return "BGRG422"
        case .x32_stencil8: return "X32_Stencil8"
        case .x24_stencil8: return "X24_Stencil8"
        default: return "\(self.rawValue)"
        }
    }
}
