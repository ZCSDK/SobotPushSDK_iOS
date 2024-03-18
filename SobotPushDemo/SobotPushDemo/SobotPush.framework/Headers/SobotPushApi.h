//
//  SobotPushApi.h
//  SobotPush
//
//  Created by lizh on 2024/2/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotPushApi : NSObject
/**
 *  获取推送SDK版本
 */
+(void)getSDKVersion;

/** 初始化友盟所有组件产品
 @param umKey 开发者在友盟官网申请的appkey.
 @param delegate 代理
 @param launchOptions 系统的launchOptions启动消息参数用于处理用户通过消息打开应用相关信息。
 */
+(void)getUMVersionWithOptions:(NSDictionary *)launchOptions delegate:(NSObject*)delegate umKey:(NSString *)umKey;

/** 绑定一个别名至设备（含账户，和平台类型）,并解绑这个别名曾今绑定过的设备。
 @warning 添加Alias的先决条件是已经成功获取到device_token，否则失败(kUMessageErrorDependsErr)
 @param name 账户，例如email
 @param type 类型 partnerId、email 、tel
 @param handle block返回数据，error为获取失败时的信息，responseObject为成功返回的数据
 */
+ (void)setAlias:(NSString * __nonnull )name type:(NSString * __nonnull)type response:(void (^__nonnull)(id __nullable responseObject,NSError * __nullable error))handle;

/** 删除一个设备的别名绑定
 @warning 删除Alias的先决条件是已经成功获取到device_token，否则失败(kUMessageErrorDependsErr)
 @param name 账户，例如email
 @param type 类型  partnerId、email 、tel 
 @param handle block返回数据，error为获取失败时的信息，responseObject为成功返回的数据
 */
+ (void)removeAlias:(NSString * __nonnull)name type:(NSString * __nonnull)type response:(void (^__nonnull)(id __nullable responseObject, NSError * __nullable error))handle;

/** 应用处于运行时（前台、后台）的消息处理，回传点击数据
 @param userInfo 消息参数
 */
+ (void)didReceiveRemoteNotification:( NSDictionary * __nullable)userInfo;

/** 向友盟注册该设备的deviceToken，便于发送Push消息
 @param deviceToken APNs返回的deviceToken
 */
+ (void)registerDeviceToken:( NSData * __nullable)deviceToken;
@end

NS_ASSUME_NONNULL_END
