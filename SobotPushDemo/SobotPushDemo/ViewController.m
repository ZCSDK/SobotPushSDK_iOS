//
//  ViewController.m
//  SobotPushDemo
//
//  Created by lizh on 2024/3/11.
//

#import "ViewController.h"
#import <SobotPush/SobotPushApi.h>
#import <UMPush/UMessage.h>
#import <UMCommon/UMCommon.h>

#define RgbColor(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define SobotRgbColorAlpha(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ColorFromRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@interface ViewController ()<UITextFieldDelegate,UITextViewDelegate>
{
    CGFloat contentSizeHeight;
    UITextField *umkeyTf; // 友盟key
    UITextField *aliasTf;// 别名
    UITextField *appkeyTf;// appkey
    UITextField *apiHost;// 域名
    UITextField *uidTf;// 对接用户ID
    UITextField *aliasTypeTf;//别名类型
}
@property(nonatomic,strong) UIScrollView *mainScroll;
@property(nonatomic,strong) UITextField *tf;
@property(nonatomic,strong) UITextView *textV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.redColor;
    [self createSubViews];
    [SobotPushApi getSDKVersion];
//    [self initSobotSDK];
}
-(void)createSubViews{
    self.view.backgroundColor = RgbColor(249, 249, 249);
    _mainScroll = [[UIScrollView alloc] init];
    [_mainScroll setFrame:self.view.bounds];
    _mainScroll.autoresizesSubviews = YES;
    _mainScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_mainScroll];
    
    CGFloat y = 0;
    UILabel *lab = [self createLabel:0 title:@"友盟key，默认使用 56cd1f26e0f55a6ae7000b3f " y:y];
    [lab sizeToFit];
    y = CGRectGetMaxY(lab.frame);
    umkeyTf  = [self createTextField:1 holder:@"请输入友盟key" y:y+5];
    y=CGRectGetMaxY(umkeyTf.frame);
    
    UILabel *lab2 = [self createLabel:0 title:@"别名" y:y+10];
    [lab2 sizeToFit];
    y = CGRectGetMaxY(lab2.frame);
    aliasTf  = [self createTextField:2 holder:@"请输入别名" y:y+5];
    y=CGRectGetMaxY(aliasTf.frame);
    
    UILabel *lab6 = [self createLabel:0 title:@"别名类型 支持 partnerId 、email 、tel 3种类型" y:y+10];
    [lab6 sizeToFit];
    y = CGRectGetMaxY(lab6.frame);
    aliasTypeTf = [self createTextField:4 holder:@"请输入别名类型" y:y+5];
    y=CGRectGetMaxY(aliasTypeTf.frame);
        
    UIButton *btn3 = [self createButton:3 title:@"注册推送" y:y+20];
    y=CGRectGetMaxY(btn3.frame);
    
    [_mainScroll setContentSize:CGSizeMake(self.view.frame.size.width, y+20+44)];
    contentSizeHeight = y+22+44;
    umkeyTf.text = @"56cd1f26e0f55a6ae7000b3f";
       
}

#pragma mark -- 点击按钮
-(void)click:(UIButton*)sender{
    if (sender.tag == 3) {
        // 注册推送 设置别名
        if (aliasTf.text.length == 0) {
            NSLog(@"请输入别名");
            return;
        }
        
        if (aliasTypeTf.text.length == 0) {
            aliasTypeTf.text = @"partnerId";
        }
        
        // partnerId
        [SobotPushApi setAlias:aliasTf.text type:aliasTypeTf.text response:^(id responseObject, NSError *error) {
            NSLog(@"responseObject=%@ error=%@",responseObject,error.localizedDescription);
            if (error.localizedDescription.length >0) {
                NSLog(@"%@",error.localizedDescription);
            }else if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject !=nil){
                NSString *successStr = [responseObject objectForKey:@"success"];
                NSLog(@"%@",successStr);
            }
            
        }];
        return;
    }
}

-(UIButton *) createButton:(int )tag title:(NSString *) title y:(CGFloat) y{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:0];
    btn.tag = tag;
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 44)];
    btn.autoresizesSubviews = YES;
    btn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [btn setTitleColor:UIColor.blueColor forState:0];
    [btn setBackgroundColor:UIColor.lightGrayColor];
    [_mainScroll addSubview:btn];
    return btn;
}

-(UILabel *) createLabel:(int )tag title:(NSString *) title y:(CGFloat )y{
    UILabel *btn = [[UILabel alloc] init];
    [btn setText:title];
    [btn setTextAlignment:NSTextAlignmentLeft];
    btn.numberOfLines = 0;
    btn.tag = tag;
    [btn setFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 44)];
    btn.autoresizesSubviews = YES;
    btn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [btn setTextColor:UIColor.darkTextColor];
    
    [_mainScroll addSubview:btn];
    return btn;
}


-(UITextField *) createTextField:(int )tag holder:(NSString *) holder y:(CGFloat ) y{
    UITextField *btn = [[UITextField alloc] init];
    [btn setPlaceholder:holder];
    [btn setTextAlignment:NSTextAlignmentLeft];
    [btn setBorderStyle:UITextBorderStyleLine];
    btn.tag = tag;
    [btn setFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 44)];
    btn.autoresizesSubviews = YES;
    btn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [btn setTextColor:UIColor.darkTextColor];
    btn.returnKeyType = UIReturnKeyDone;
    btn.delegate = self;
    [_mainScroll addSubview:btn];
    return btn;
}



-(UITextView *) createTextView:(int )tag holder:(NSString *) holder y:(CGFloat ) y{
    UITextView *btn = [[UITextView alloc] init];
    [btn setTextAlignment:NSTextAlignmentLeft];
    btn.tag = tag;
    [btn setFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 104)];
    btn.autoresizesSubviews = YES;
    btn.layer.borderColor = UIColor.grayColor.CGColor;
    btn.layer.borderWidth = 1.0f;
    btn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [btn setTextColor:UIColor.darkTextColor];
    btn.returnKeyType = UIReturnKeyDone;
    btn.delegate = self;
    [_mainScroll addSubview:btn];
    return btn;
}

- (void)textViewDidChange:(UITextView *)textView{
    self.textV = textView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    self.tf = nil;
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.tf = textField;
    return YES;
}


- (void)keyboardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
     //设置偏移量
        UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
        CGRect rect=[self.tf convertRect: self.tf.bounds toView:window];
        CGFloat scrH = window.bounds.size.height;
        if ((scrH - keyboardHeight)< (rect.size.height + rect.origin.y)) {
            [self.mainScroll setContentSize:CGSizeMake(self.view.frame.size.width, contentSizeHeight+keyboardHeight)];
            [self.mainScroll setContentOffset:CGPointMake(0,(rect.size.height + rect.origin.y)- (scrH - keyboardHeight) + 150) animated:YES];
        }
    }
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        [self.mainScroll setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.mainScroll setContentSize:CGSizeMake(self.view.frame.size.width, contentSizeHeight)];
    }];
}

@end
