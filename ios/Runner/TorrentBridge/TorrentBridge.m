#import "TorrentBridge.h"
#import <libtorrent_flutter/torrent_bridge.h>

static lt_session_t g_session = NULL;

@implementation TorrentBridge

+ (instancetype)shared {
    static TorrentBridge *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"createSession" isEqualToString:call.method]) {
        NSString *listen = call.arguments[@"listenInterface"] ?: @"0.0.0.0";
        NSNumber *dlLimit = call.arguments[@"downloadLimit"] ?: @0;
        NSNumber *ulLimit = call.arguments[@"uploadLimit"] ?: @0;
        if (g_session) {
            lt_destroy_session(g_session);
        }
        g_session = lt_create_session([listen UTF8String], [dlLimit intValue], [ulLimit intValue]);
        result(@(g_session != NULL));
    } else if ([@"destroySession" isEqualToString:call.method]) {
        if (g_session) { lt_destroy_session(g_session); g_session = NULL; }
        result(nil);
    } else if ([@"addMagnet" isEqualToString:call.method]) {
        NSString *uri = call.arguments[@"uri"];
        NSString *path = call.arguments[@"savePath"];
        NSNumber *streamOnly = call.arguments[@"streamOnly"] ?: @0;
        if (!g_session || !uri) { result(@(-1)); return; }
        lt_torrent_id tid = lt_add_magnet(g_session, [uri UTF8String],
                                          [path UTF8String], [streamOnly intValue]);
        result(@(tid));
    } else if ([@"removeTorrent" isEqualToString:call.method]) {
        NSNumber *tid = call.arguments[@"id"];
        NSNumber *del = call.arguments[@"deleteFiles"] ?: @0;
        if (g_session) lt_remove_torrent(g_session, [tid longLongValue], [del intValue]);
        result(nil);
    } else if ([@"pauseTorrent" isEqualToString:call.method]) {
        NSNumber *tid = call.arguments[@"id"];
        if (g_session) lt_pause_torrent(g_session, [tid longLongValue]);
        result(nil);
    } else if ([@"resumeTorrent" isEqualToString:call.method]) {
        NSNumber *tid = call.arguments[@"id"];
        if (g_session) lt_resume_torrent(g_session, [tid longLongValue]);
        result(nil);
    } else if ([@"recheckTorrent" isEqualToString:call.method]) {
        NSNumber *tid = call.arguments[@"id"];
        if (g_session) lt_recheck_torrent(g_session, [tid longLongValue]);
        result(nil);
    } else if ([@"getTorrentCount" isEqualToString:call.method]) {
        int count = g_session ? lt_get_torrent_count(g_session) : 0;
        result(@(count));
    } else if ([@"getAllStatuses" isEqualToString:call.method]) {
        if (!g_session) { result(@[]); return; }
        int count = lt_get_torrent_count(g_session);
        if (count <= 0) { result(@[]); return; }
        NSMutableArray *arr = [NSMutableArray array];
        lt_torrent_status *statuses = malloc(sizeof(lt_torrent_status) * count);
        int got = lt_get_all_statuses(g_session, statuses, count);
        for (int i = 0; i < got; i++) {
            [arr addObject:@{
                @"id": @(statuses[i].id),
                @"name": @(statuses[i].name),
                @"savePath": @(statuses[i].save_path),
                @"state": @(statuses[i].state),
                @"progress": @(statuses[i].progress),
                @"downloadRate": @(statuses[i].download_rate),
                @"uploadRate": @(statuses[i].upload_rate),
                @"totalDone": @(statuses[i].total_done),
                @"totalWanted": @(statuses[i].total_wanted),
                @"totalUploaded": @(statuses[i].total_uploaded),
                @"numPeers": @(statuses[i].num_peers),
                @"numSeeds": @(statuses[i].num_seeds),
                @"isPaused": @(statuses[i].is_paused),
                @"isFinished": @(statuses[i].is_finished),
                @"hasMetadata": @(statuses[i].has_metadata),
            }];
        }
        free(statuses);
        result(arr);
    } else if ([@"getFileCount" isEqualToString:call.method]) {
        NSNumber *tid = call.arguments[@"id"];
        int cnt = g_session ? lt_get_file_count(g_session, [tid longLongValue]) : 0;
        result(@(cnt));
    } else if ([@"getFiles" isEqualToString:call.method]) {
        NSNumber *tid = call.arguments[@"id"];
        if (!g_session) { result(@[]); return; }
        int cnt = lt_get_file_count(g_session, [tid longLongValue]);
        if (cnt <= 0) { result(@[]); return; }
        NSMutableArray *arr = [NSMutableArray array];
        lt_file_info *files = malloc(sizeof(lt_file_info) * cnt);
        int got = lt_get_files(g_session, [tid longLongValue], files, cnt);
        for (int i = 0; i < got; i++) {
            [arr addObject:@{
                @"index": @(files[i].index),
                @"name": @(files[i].name),
                @"path": @(files[i].path),
                @"size": @(files[i].size),
                @"isStreamable": @(files[i].is_streamable),
            }];
        }
        free(files);
        result(arr);
    } else if ([@"configureSession" isEqualToString:call.method]) {
        if (!g_session) { result(@NO); return; }
        lt_bt_config config;
        lt_get_default_config(&config);
        NSDictionary *args = call.arguments;
        if (args[@"cacheSize"]) config.cache_size = [args[@"cacheSize"] longLongValue];
        if (args[@"connectionsLimit"]) config.connections_limit = [args[@"connectionsLimit"] intValue];
        if (args[@"downloadRateLimit"]) config.download_rate_limit = [args[@"downloadRateLimit"] intValue];
        if (args[@"uploadRateLimit"]) config.upload_rate_limit = [args[@"uploadRateLimit"] intValue];
        if (args[@"enableDht"]) config.disable_dht = [args[@"enableDht"] intValue] ? 0 : 1;
        if (args[@"enableUpnp"]) config.disable_upnp = [args[@"enableUpnp"] intValue] ? 0 : 1;
        if (args[@"enableIpv6"]) config.enable_ipv6 = [args[@"enableIpv6"] intValue] ? 1 : 0;
        if (args[@"encrypt"]) config.force_encrypt = [args[@"forceEncrypt"] intValue] ? 0 : 0;
        lt_configure_session(g_session, &config);
        result(@YES);
    } else if ([@"setDownloadLimit" isEqualToString:call.method]) {
        NSNumber *limit = call.arguments[@"bytesPerSec"];
        if (g_session) lt_set_download_limit(g_session, [limit intValue]);
        result(nil);
    } else if ([@"setUploadLimit" isEqualToString:call.method]) {
        NSNumber *limit = call.arguments[@"bytesPerSec"];
        if (g_session) lt_set_upload_limit(g_session, [limit intValue]);
        result(nil);
    } else if ([@"version" isEqualToString:call.method]) {
        result(@(lt_version()));
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
