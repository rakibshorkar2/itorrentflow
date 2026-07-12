#import <Flutter/Flutter.h>

@interface TorrentBridge : NSObject

+ (instancetype)shared;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

@end
