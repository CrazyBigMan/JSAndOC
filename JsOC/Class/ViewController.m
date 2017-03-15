//
//  ViewController.m
//  JsOC
//
//  Created by 何亚运 on 16/9/10.
//  Copyright © 2016年 YYStar. All rights reserved.
//

#import "ViewController.h"
// iOS7之后
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSCallOCProtol <JSExport>

- (void)hide123;
- (void)addSomeView:(UIView *)view;
- (int)getStatusBarHeight;
@end

@interface ViewController ()<UIWebViewDelegate,JSCallOCProtol>

@property (nonatomic, strong) JSContext *jsContext;


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"jsoc" ofType:@"html"];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:pathStr]]];
    webView.delegate = self;
    [self.view addSubview:webView];
    NSLog(@"haha");
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.view bringSubviewToFront:webView];
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    /**
     *  此处将oc中得self传给js对象，jsContext的[@"show"]，这个show任意定义，但是在js中用的时候必须用此一样的名字，来调用我们oc中协议的方法例如上面的hide123，在js中此例子是通过了button的点击方法出发这个协议中得 方法，
     */
    // oc调用js方法
//    [self.jsContext evaluateScript: @"hide('oc掉jsalert方法')"];
    
    // oc掉js方法
//    [webView stringByEvaluatingJavaScriptFromString:@"hide()"];

    
    
    // js掉oc方法一 通过代理
    self.jsContext[@"show"] = self;
    
    
    // 方法二通过block
    __weak typeof(self) weakSelf = self;
    self.jsContext[@"hide"] = ^() {
        [weakSelf loggg];
    };
    
    self.jsContext.exceptionHandler = ^(JSContext *jsContext, JSValue *exceptionValue) {
        jsContext.exception = exceptionValue;
        NSLog(@"--异常信息-%@----", exceptionValue);
    };
}

// 点击hide  js调用oc方法
- (void)loggg {
    
    NSLog(@"=============");
    // 直接给html添加提示框
    NSString *str = @"alert('OC添加JS提示成功')";
    [self.jsContext evaluateScript:str];
    
}
// 点击show，js调用oc此方法
- (void)hide123 {

    NSLog(@"show");
    // 再回掉js的方法把内容传出去,在调用js方法
    JSValue *callBack = self.jsContext[@"callBack"];
    // 传值给web端，可以传参数
    [callBack callWithArguments:nil];
}

- (void)addSomeView:(UIView *)view {
    NSLog(@"22222" );
    [self.view addSubview:view];
}


- (int)getStatusBarHeight {
    NSLog(@"getStatusBarHeight");
//    [self.jsContext evaluateScript:@"foo(1)"];
    
    JSValue *callBack = self.jsContext[@"foo"];
    // 传值给web端
    [callBack callWithArguments:@[@(1)]];
    
    return 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
