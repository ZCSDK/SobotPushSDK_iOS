//
//  AppDelegate.m
//  SobotPushDemo
//
//  Created by lizh on 2024/3/11.
//

#import "AppDelegate.h"
#import <UMPush/UMessage.h>
#import <UMCommon/UMCommon.h>
#import <SobotPush/SobotPushApi.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self.window makeKeyWindow];
    
    [SobotPushApi getUMVersionWithOptions:launchOptions delegate:self umKey:@"56cd1f26e0f55a6ae7000b3f"];
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    /**
     * 推送处理1
     */
    if ([application
         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert |
        UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    [self registerAPNS];
    
    return YES;
}


// 注册通知
- (void)registerAPNS {

    if (@available(iOS 10.0, *)) { // iOS10 以上
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
    } else {// iOS8.0 以上
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
}

/**
 * 推送处理2
 */
//注册用户通知设置
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"获取到Token---Token--%@", deviceToken);
    [SobotPushApi registerDeviceToken:deviceToken];
    NSString *token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13) {
        token = [self getHexStringFromData:deviceToken];
    }
    NSLog(@"devicetoken=\n%@\n",token);
}

-(NSString *) getHexStringFromData:(NSData *) data{
    NSUInteger len = [data length];
    char *chars = (char *)[data bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (int i=0; i<len ; i ++ ) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx",chars[i]]];
    }
    return  hexString;
               
}

/**
 *     友盟设置推送token
 **/
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"%@",userInfo);
    [SobotPushApi didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Regist fail%@",error);
}

//点击推送消息后回调
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^_Nonnull __strong)())completionHandler{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSString *showMsg = [self dictionaryToJson:userInfo];
//    NSDictionary *payload = [userInfo objectForKey:@"payload"];
//    NSString *sobot_chat_page = sobotConvertToString([payload objectForKey:@"sobot_chat_page"]);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"推送内容" message:showMsg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
    NSString *sobot_chat_page = [userInfo objectForKey:@"sobot_chat_page"];
    NSString *sobot_chat_url = [userInfo objectForKey:@"sobot_chat_url"];
    // sobot_chat_url 标识 要打开的链接
    // sobot_chat_page 标识 要打开的页面
    // sobot_chat_url 和 sobot_chat_page 不会同时出现
    
//    if (sobot_chat_page.length >0) {
//        if (self.zcPageType != ZCPageStateTypeChatLoadFinish) {
//            [self openSDK];
//        }
//    }else{
//        if (sobot_chat_url.length >0) {
//            [[UIApplication sharedApplication] openURL:sobotConvertToString(sobot_chat_url) options:0 completionHandler:^(BOOL success) {
//
//            }];
//        }
//    }
    NSLog(@"Userinfo %@",userInfo);
}


- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}



-(void)openSDK{
    // 进入聊天页面
//    __weak AppDelegate *weakSelf = self;
//    [ZCSobotApi openZCChat:[ZCKitInfo new] with:[self getCurrentVCFrom:_window.rootViewController] pageBlock:^(id  _Nonnull object, ZCPageStateType type) {
//        if([object isKindOfClass:[ZCChatView class]] && type == ZCPageStateTypeChatLoadFinish){
//           
//        }
//    weakSelf.zcPageType = type;
//    }];
    
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC = rootVC;
    while ([currentVC presentedViewController]) {
        // 视图是被presented出来的
        currentVC = [currentVC presentedViewController];
    }
    if ([currentVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [(UITabBarController *)currentVC selectedViewController];
    }
    if ([currentVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [(UINavigationController *)currentVC visibleViewController];
    }
    return currentVC;
}


@end
