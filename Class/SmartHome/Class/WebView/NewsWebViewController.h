//
//  webViewController.h
//
//
//  Created by yixingman on 12-8-29.
//  Copyright (c) 2012年 yixingman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXMBaseViewController.h"


@interface NewsWebViewController : YXMBaseViewController<UIWebViewDelegate>
{
    UIWebView *webview;
}
-(void)reloadWebviewurl:(NSString *)url andTitle:(NSString *)title;
@end
