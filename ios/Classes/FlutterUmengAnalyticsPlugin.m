#import "FlutterUmengAnalyticsPlugin.h"

#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>


@implementation FlutterUmengAnalyticsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"flutter_umeng_analytics"
                                  binaryMessenger:[registrar messenger]];
  FlutterUmengAnalyticsPlugin* instance = [[FlutterUmengAnalyticsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"init" isEqualToString:call.method]) {
    [self init:call result:result];
  } else if ([@"logPageView" isEqualToString:call.method]) {
    [MobClick logPageView:call.arguments[@"name"] seconds:[call.arguments[@"seconds"] intValue]];
    result(nil);
  } else if ([@"beginPageView" isEqualToString:call.method]) {
    [MobClick beginLogPageView:call.arguments[@"name"]];
    result(nil);
  } else if ([@"endPageView" isEqualToString:call.method]) {
    [MobClick endLogPageView:call.arguments[@"name"]];
    result(nil);
  } else if ([@"logEvent" isEqualToString:call.method]) {
      NSString* eventId;
      NSString* label;
      NSMutableDictionary *dict=[NSMutableDictionary dictionary];
      [dict addEntriesFromDictionary:call.arguments];
      if ([dict objectForKey:@"eventId"]) {
          eventId = dict[@"eventId"];
          label = dict[@"label"];
          [dict removeObjectForKey:@"eventId"];
          if ([dict count] == 0) {
              [MobClick event:eventId];
          } else if (label != nil) {
              [MobClick event:eventId label:label];
          } else {
              NSDictionary*attributes = [NSDictionary dictionaryWithDictionary:dict];
              [MobClick event:eventId attributes:attributes];
          }
      }
    result(nil);
  } else if ([@"reportError" isEqualToString:call.method]) {
      result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)init:(FlutterMethodCall*)call result:(FlutterResult)result {
  [MobClick setAutoPageEnabled:NO];
  NSString* appKey = call.arguments[@"key"];
  // UMConfigInstance.secret = call.arguments[@"secret"];

  NSString* channel = call.arguments[@"channel"];
  
//  NSNumber* policy = call.arguments[@"policy"];
//  if (policy) UMConfigInstance.eSType = [policy intValue];
//
  NSNumber* reportCrash = call.arguments[@"reportCrash"];
  if (reportCrash) [MobClick setCrashReportEnabled:[reportCrash boolValue]];
//
//  [MobClick startWithConfigure:UMConfigInstance];
//
  NSNumber* logEnable = call.arguments[@"logEnable"];
  if (logEnable) [UMConfigure setLogEnabled:[logEnable boolValue]];
//
  NSNumber* encrypt = call.arguments[@"encrypt"];
  if (encrypt) [UMConfigure setEncryptEnabled:[encrypt boolValue]];
//
//  NSNumber* interval = call.arguments[@"interval"];
//  if (interval) [MobClick setLogSendInterval:[interval doubleValue]];
        
    //如果用户用组件化SDK,需要升级最新的UMCommon.framework版本。
    NSString * deviceID =[UMConfigure deviceIDForIntegration];
    NSLog(@"集成测试的deviceID:%@", deviceID);
    [UMConfigure initWithAppkey:appKey channel:channel];
}

@end
