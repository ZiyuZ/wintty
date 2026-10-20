//! App-scoped render device for the DirectX 12 backend.
//!
//! The renderer model this tree follows owns one app-scoped device type
//! shared by every surface renderer (`renderer.Device`, created once by
//! the first surface and dropped at app shutdown; see App.zig). The D3D12
//! backend's real device strategy is process-wide instead: device.zig
//! keeps a warm ID3D12Device singleton primed by `warmup()` on a
//! background thread at app start, hands it to the first renderer that
//! creates a device, and drops a still-parked reference on recovery and
//! at teardown. This type adapts that global to the app-scoped shape:
//! `init` is an empty attach (the per-renderer path in DirectX12.zig
//! owns all real device work through device.zig), `warmup` forwards to
//! the warm-device machinery, and `deinit` releases a parked warm
//! reference so the process exits clean. `Device.init` in device.zig
//! consumes the warm singleton exactly as before; nothing about the
//! runtime device lifecycle changes.
const std = @import("std");
const Allocator = std.mem.Allocator;
const dx12_device = @import("device.zig");

pub const Device = struct {
    /// The DX12 app device has no options: the warm-device machinery
    /// picks the adapter (see device.zig's device selection), so there is
    /// nothing for an apprt to influence here.
    pub const Options = struct {};

    pub fn init(alloc: Allocator, options: Options) !*Device {
        _ = options;
        const self = try alloc.create(Device);
        self.* = .{};
        return self;
    }

    /// Release a still-parked warm reference, if one never got consumed.
    /// A consumed singleton is owned by the renderer that took it and is
    /// released on its own teardown path, so this is a no-op by then.
    pub fn deinit(self: *Device, alloc: Allocator) void {
        dx12_device.dropWarmDevice();
        alloc.destroy(self);
    }

    /// Detected via @hasDecl by App.zig and run on a background thread at
    /// app startup, well before the first renderer needs a device.
    pub fn warmup() void {
        dx12_device.warmup();
    }
};
