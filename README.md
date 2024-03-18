

# iOS 推送 SDK


智齿推送SDK



相关限制及注意事项  
1、开启网络请求权限  
2、App开启推送功能  
3、集成友盟推送SDK



####  文档介绍

##### ● 文件说明
**SDK包含SobotPush.framework、SobotDemo、和Doc相关说明文档。**

| 文件名   | 说明   |备注|
|:----|:----|:----|
| SobotPush.framework   | 智齿推送接口代码库   |    |
| SobotPushApi.h   | 该文件提供接入功能   |    |


#### 集成方式
##### ● 手动集成

下载链接：[iOS_Push_SDK](https://github.com/ZCSDK/SobotPushSDK_iOS.git)

解压[iOS_SDK]，添加必要文件SobotPush.framework和友盟推送SDK集成包到你的工程里。智齿推送SDK基于友盟SDK的实现，依赖了一些系统的框架，在开发应用时需要在工程里加入这些框架。开发者首先点击工程右边的工程名，然后在工程名右边依次选择TARGETS -> BuiLd Phases -> Link Binary With Libraries，展开 LinkBinary With Libraries后点击展开后下面的 + 来添加下面的依赖项:

* CoreAudio.framework
* libz.tbd
* SystemConfiguration.framework
* libsqlite3.tbd
* UserNotifications.framework
* CoreTelephony.framework


##### ● 初始化
初始化友盟推送

主要调用代码如下：

接口：

```js
[SobotPushApi getUMVersionWithOptions:launchOptions delegate:self umKey:@"友盟平台申请的key"];

```
参数：  

| 参数名   | 类型   | 描述   |
|:----|:----|:----|
| launchOptions   | NSDictionary   | 系统的launchOptions启动消息参数用于处理用户通过消息打开应用相关信息   |
| delegate   | NSString   | 代理   |
| umKey   | NSString   | 开发者在友盟官网申请的appkey  |

示例代码：

```js

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.window makeKeyWindow];   
    [SobotPushApi getUMVersionWithOptions:launchOptions delegate:self umKey:@"56cd1f26e0f55a6ae7000b3f"];
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [self registerAPNS];
    return YES;
}

```


###### 3. 权限设置
 需要加入的权限

```js
<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
```
##### ●  注册推送
###### 1. 注册远程推送
注册远程推送 在
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 方法中添加注册推送代码
示例代码

```js

 if (@available(iOS 10.0, *)) { // iOS10 以上
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
    } else {// iOS8.0 以上
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
    
```

###### 2.向友盟注册该设备的deviceToken
向友盟注册该设备的deviceToken，便于发送Push消息

示例

```js

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"获取到Token---Token--%@", deviceToken);
    [SobotPushApi registerDeviceToken:deviceToken];
}

```

###### 3. 绑定别名
绑定一个别名至设备（含账户，和平台类型）,并解绑这个别名曾今绑定过的设备。注意 添加Alias的先决条件是已经成功获取到device_token，否则失败(kUMessageErrorDependsErr)

用户登录后可以有三种方式设置别名方式
1.对接ID  partnerId
2.邮箱    email
3.电话    tel
选择其中一种方式设置别名，调用时机，app登录成功后，向友盟注册该设备的deviceToken之后。
示例

```js

[SobotPushApi setAlias:sobotConvertToString(aliasTf.text) type:@"partnerId" response:^(id responseObject, NSError *error) {
            NSLog(@"responseObject=%@ error=%@",responseObject,error.localizedDescription);
            if (sobotConvertToString(error.localizedDescription).length >0) {
                [[SobotToast shareToast] showToast:error.localizedDescription duration:2 position:SobotToastPositionCenter];
            }else if ([responseObject isKindOfClass:[NSDictionary class]] && !sobotIsNull(responseObject)){
                NSString *successStr = sobotConvertToString([responseObject objectForKey:@"success"]);
                [[SobotToast shareToast] showToast:successStr duration:2 position:SobotToastPositionCenter];
            }
            
        }];

```

##### ●  点击推送消息事件

点击推送消息跳转App指定页面或者打开链接

```js

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^_Nonnull __strong)())completionHandler{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSString *showMsg = [self dictionaryToJson:userInfo];   
    NSString *sobot_chat_page = sobotConvertToString([userInfo objectForKey:@"sobot_chat_page"]);
    NSString *sobot_chat_url = sobotConvertToString([userInfo objectForKey:@"sobot_chat_url"]);
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
    
```


##### ● iOS富文本推送

如果想在推送消息中添加图片，可以通过添加Notification Service Extension来实现

首先我们创建一个Notification Service Extension，具体步骤如下：File——>New——>Target——->Notification Service Extension——->命名创建的Notification Service Extension

将下面的代码复制到NotificationService.m文件中，也可以自行编写相关代码。

```js
 
-(void)didReceiveNotificationRequest:(UNNotificationRequest*)request
                   withContentHandler:(void(^)(UNNotificationContent*_Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent =[request.content mutableCopy];
    //[modified]这个是一个标示，可以实现对服务器下发下来的内容进行更改 仅测试使用
    self.bestAttemptContent.title =[NSString stringWithFormat:@"%@ [modified]",self.bestAttemptContent.title];
 
    NSDictionary*apsDic =[request.content.userInfo objectForKey:@"aps"];
    NSString*attachUrl =[apsDic objectForKey:@"sobot_chat_big_img"];
 
    NSString*category =[apsDic objectForKey:@"category"];
    self.bestAttemptContent.categoryIdentifier = category;
 
    NSURLSession*session =[NSURLSession sharedSession];
    NSURL *url =[NSURL URLWithString:attachUrl];
    NSURLSessionDownloadTask*downloadTask =[session downloadTaskWithURL:url
                                                        completionHandler:^(NSURL *_Nullable location,
    NSURLResponse*_Nullable response,
    NSError*_Nullable error){
    NSString*caches =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) lastObject];
    NSString*file =[caches stringByAppendingPathComponent:response.suggestedFilename];
    NSFileManager*mgr =[NSFileManager defaultManager];
    [mgr moveItemAtPath:location.path toPath:file error:nil];
 
    if(file &&![file  isEqualToString:@""])
    {
      UNNotificationAttachment*attch=[UNNotificationAttachment attachmentWithIdentifier:@"photo"
                                                                                                                                                URL:[NSURL URLWithString:[@"file://" stringByAppendingString:file]]
                                                                                                                                            options:nil
                                                                                                                                              error:nil];
       if(attch)
       {
          self.bestAttemptContent.attachments =@[attch];
       }
    }
    self.contentHandler(self.bestAttemptContent);
   }];
  [downloadTask resume];
 
}
- (void)downloadAndSave:(NSURL *)fileURL handler:(void (^)(NSString *))handler {
    // 这里需要用系统网络请求来下载图片
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:fileURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *localPath = nil;
        if (!error) {
            // 临时文件夹路径，APP没有运行时会自动清除图片，不会占用内存
            NSString *localURL = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), fileURL.lastPathComponent];
            if ([[NSFileManager defaultManager] moveItemAtPath:location.path toPath:localURL error:nil]) {
                localPath = localURL;
            }
        }
        handler(localPath);
    }];
    [task resume];
}

```
*注意*  
1. self.bestAttemptContent.title = [NSString stringWithFormat:@”%@ [modified]”, self.bestAttemptContent.title];可以用来测试项目是否调用了notification service
2.图片大小不能超过10M，并且内容链接必须是https的
3.Notification Service Extension项目的info.plist文件中要添加网络权限
<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
4.测试推送的时候打包选择NotifiactionService Target
5.测试推送需要打包成adHoc格式去验证


##### ● 自定义推送UI
如果想修改推送UI可以添加 Notification Content Extension来实现自定义UI
首先我们创建一个Notification Content Extension，具体步骤如下：File——>New——>Target——->Notification Content Extension——->命名创建的Notification Content Extension

将下面的代码复制到NotificationViewController.m文件中，添加自定义的UI代码
示例


```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    self.iconImg = [[UIImageView alloc]init];
    self.iconImg.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    [self.view addSubview:self.iconImg];
}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = notification.request.content.body;
//    NSString * lastComment = notification.request.content.userInfo[@"last-comments"];
    //附件的提取
    UNNotificationAttachment * attachment = notification.request.content.attachments[0];
    if ([attachment.URL startAccessingSecurityScopedResource]) {
        NSData *imageData = [NSData dataWithContentsOfURL:attachment.URL];
        [self.iconImg setImage:[UIImage imageWithData:imageData]];
        [attachment.URL stopAccessingSecurityScopedResource];
    }
    if ([notification.request.content.body isEqualToString:@""]) {
        self.iconImg.hidden = YES;
    } else {
        self.label.text = notification.request.content.body;
    }
}

```

#### 友盟集成文档
####  [友盟推送SDK_iOS集成文档](https://developer.umeng.com/docs/67966/detail/66734) 

