// The sentry_c module is produced by build.zig from sentry.h. The defines
// the translation needs (SENTRY_BUILD_STATIC everywhere; on Windows also
// the _WINDOWS_ suppression and the EXCEPTION_POINTERS stand-in, because
// aro cannot parse the __ptr64 attribute the Windows SDK uses and sentry.h
// reaches windows.h for one field nothing on the Zig side references) live
// in that one list, next to the flags the C sources are compiled with.
pub const c = @import("sentry_c");
