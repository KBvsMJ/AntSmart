#import "MyTool.h"

#import "AppDelegate.h"

static CGRect oldframe;
@implementation MyTool

/**
 *@brief 重新设置图片的大小
 */
+(UIImage *)scale:(UIImage *)image toSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

/**
 *@brief 设置导航栏上的文字
 */
+(UILabel *)titleView:(NSString *)titleName font:(UIFont *)myFont{
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 0, 90, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = titleName;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = myFont;
    return titleLabel;
}

/**
 *@brief 根据两个点的经纬度计算两个点距离
 */
+(double)distanceBetweenOrderByLat1:(double)lat1 Andlng1:(double)lng1 Lat2:(double)lat2 Lng2:(double)lng2{
    double dd = M_PI/180;
    double x1=lat1*dd,x2=lat2*dd;
    double y1=lng1*dd,y2=lng2*dd;
    double R = 6371004;
    double distance = (2*R*asin(sqrt(2-2*cos(x1)*cos(x2)*cos(y1-y2) - 2*sin(x1)*sin(x2))/2));
    return   distance;
}

/**
 *@brief 根据时间戳计算出时间
 */
+(NSString*)TimestampToDate:(NSString*)timestamp
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:NSLocalizedString(@"PerformDate", @"")];//@"yyyy年MM月dd日"
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];  
    [formatter setTimeZone:timeZone];
    NSDate *datestamp = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    DLog(@"timestamp doubleValue = %ld",(long)[timestamp integerValue]);
    if (![self stringIsDigit:timestamp]) {
        return timestamp;
    }
    return [formatter stringFromDate:datestamp];
}

/**
 *@brief 根据时间戳计算出日期加时间,返回日期对象
 */
+(NSDate*)TimestampToDateAndTime:(NSString*)timestamp{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:NSLocalizedString(@"PerformDateAndTime", @"")];    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:[timestamp integerValue]];
    return d;
}

/**
 *  传入一个日期对象返回日期加时间的字符串
 *
 *  @param date 日期对象
 *
 *  @return 日期加时间的字符串
 */
+(NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}


/**
 *@brief 时间字符串转时间戳
 */
+(NSString*)dateNSStringToTimestamp:(NSString*)dateNSString{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[NSLocale currentLocale]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* inputDate = [inputFormatter dateFromString:dateNSString];
    NSString *timeSp = [[NSString alloc]initWithFormat:@"%ld", (long)[inputDate timeIntervalSince1970]];
    return timeSp;
}
/**
 *@brief 角度转换为弧度
 */
+(double)radians:(float)degrees{
    return (degrees*3.14159265)/180.0;
}
/**
 *@brief 写入JSON和Html文件，存储在Documents/LedCaches目录下
 */
+(void)writeCacherequestUrl:(NSString*)url{

}
/**
 *@brief 读取JSON和Html文件，存储在Documents/LedCaches，返回NSdata类型
 */
+(NSData*)readCacheData:(NSString*)urlStr{
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/LedCaches/"];
    NSString *filePath = [documentsDirectory
                         stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[urlStr md5Encrypt]]];
//    DLog(@"filePath= %@",filePath);
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *fileContentData = [fileMgr contentsAtPath:filePath];
    
    return fileContentData;
}

/**
 *@brief 读取JSON和Html文件，存储在Documents/LedCaches，返回NSString类型
 */
+(NSString*)readCacheString:(NSString*)urlStr{
    
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/LedCaches/"];
    
    NSString *filePath = [documentsDirectory
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[urlStr md5Encrypt]]];
//    DLog(@"filePath= %@",filePath);
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSData *fileContentData = [fileMgr contentsAtPath:filePath];
    
    NSString *fileContentStr = [[NSString alloc]initWithData:fileContentData encoding:NSUTF8StringEncoding];
    
    return fileContentStr;
}

+(BOOL)isExistsCacheFile:(NSString*)urlStr{
    return NO;
}

+(NSString*)fileExistsCacheFile:(NSString*)urlStr
{
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/LedCaches/"];
    NSString *filePath = [documentsDirectory
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[urlStr md5Encrypt]]];
//    DLog(@"filePath= %@",filePath);
    return filePath;
}

/**
 *@判断视频的文件路径是否有视频
 */
+(BOOL)isExistsVideoFile:(NSString*)urlStr{
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VideoFile/"];
    [fileMgr createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    NSString *filePath = [documentsDirectory
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[urlStr md5Encrypt]]];
//    DLog(@"filePath= %@",filePath);
    if ([fileMgr fileExistsAtPath:filePath]) {
        NSLog(@"!!!本地有下载的视频??");
    }
    return [fileMgr fileExistsAtPath:filePath];
}

/**
 *@返回视频的文件路径
 */
+(NSString *)getVideoFilePath:(NSString*)urlStr
{
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VideoFile/"];
    NSString *filePath = [documentsDirectory
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[urlStr md5Encrypt]]];
//    DLog(@"filePath= %@",filePath);
    return filePath;
}


/**
 *@brief 获得SDWebImage的图片存储路径
 */
+(NSString*)getSDWebImageFilePath:(NSString*)filepath{
    NSString *diskCachePath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
    const char *str = [filepath UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return [diskCachePath stringByAppendingPathComponent:filename];
}
/**
 *@brief 根据图片数据写入图片到SDWebImage的图片存储目录下
 */
+(void)writeImageCache:(NSData*)imageData requestUrl:(NSString*)url{
    
    [imageData writeToFile:[self getSDWebImageFilePath:url] atomically:YES];
    
}

/**
 *@brief 根据图片网络路径写入图片到SDWebImage的图片存储目录下
 */
+(void)writeImageCacheRequestUrl:(NSString*)url{

}

/**
 *@brief 读取SDWebImage的缓存文件，存储在Library/Caches/ImageCache，返回NSdata类型
 */
+(NSData*)readImageCache:(NSString*)urlStr{
    
    NSString *filePath = [self getSDWebImageFilePath:urlStr];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSData *fileContentData = [fileMgr contentsAtPath:filePath];
    
    return fileContentData;
}
/**
 *@brief 获得当前的时间，例如2013-08-11 16:05:03
 */
+(NSString*)getCurrentDateString{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd-HH:mm:ss"];
    NSString *  morelocationString=[dateformatter stringFromDate:senddate];
    return morelocationString;
}


+(void)writeCalculImageCache:(NSData*)imageData requestUrl:(NSString*)url{
    if (url==nil) {
        return;
    }
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/LedCalculCaches/"];
    
    NSString *filePath = [documentsDirectory
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[url md5Encrypt]]];
//    DLog(@"%@",filePath);
    [imageData writeToFile:filePath atomically:YES];
}

/**
 *@brief 根据图片的URL地址返回图片UIImage对象
 */
+(UIImage*)readCalculImageCache:(NSString*)urlStr{
    if (urlStr==nil) {
        return nil;
    }
    NSString *filePath = [self getSDWebImageFilePath:urlStr];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSData *fileContentData = [fileMgr contentsAtPath:filePath];
    
    UIImage *image=[[UIImage alloc]initWithData:fileContentData];
    
    return image;
}


/**
 *@brief 判断输入的email是否正确
 */
- (BOOL)CheckInputIsEmail:(NSString *)inputStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9._]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:inputStr];
}


/**
 *@brief 判断输入的手机号码是否正确
 */
-(BOOL)CheckInputIsTelNum:(NSString *)_text
{
    NSString *Regex = @"1\\d{10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [emailTest evaluateWithObject:_text];  
}

/**
 *@brief 判断用户的key是否存在，存在则表示登陆成功
 */
+(BOOL)CheckIsLogin{
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *user_alias = [ud objectForKey:@"user_alias"];
    if ((user_alias==nil)||([user_alias length]==0)) {
        return NO;
    }else{
        return YES;
    }
}



/**
 *@brief 写入JSON和Html文件，存储在Documents/LedCaches
 */
+(void)writeCache:(NSString *)responseStr requestUrl:(NSString*)url{
    
    if (responseStr==nil) {
        //DLog(@"responseStr 为空");
        return;
    }
    if (![responseStr isKindOfClass:[NSString class]]) {
        //DLog(@"responseStr 不是一个字符串");
        return;
    }
    if ([responseStr length]==0) {
        //DLog(@"responseStr 的长度为零");
        return;
    }
    NSError *error;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/LedCaches/"];
    
    [fileMgr createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    NSString *filePath= [documentsDirectory
                         stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[url md5Encrypt]]];
    
    if ([fileMgr fileExistsAtPath:filePath]) {
        [fileMgr removeItemAtPath:filePath error:&error];
    }
    
    
    [responseStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}



//传入一个图片用于放大
+(void)showImage:(UIImageView *)avatarImageView{
    UIImage *image=avatarImageView.image;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha=0;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    imageView.image=image;
    imageView.tag=1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=oldframe;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}


/**
 *@brief 获得应用的沙盒路径
 */
+ (NSString *)applicationDocumentsDirectory{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}




/**
 *@brief url中有中文的情况使用此方法转为UTF-8
 */
+(NSString*)stringCovertToUTF8:(NSString *)urlString{
    NSString *encodingString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return encodingString;
}


/**
 *@brief 性别的代码与字符串之间的转换
 */
+(NSString*)sexCodeCovertString:(NSString*)sexCode{
    if ([sexCode isEqualToString:@"0"]) {
        return NSLocalizedString(@"NSStringSexMan",@"男");
    }else{
        return NSLocalizedString(@"NSStringSexWoMan",@"女");
    }
}


/**
 *@brief 判断字符串是否全部为数字
 */
+(BOOL)stringIsDigit:(NSString*)inputStr{
    int inputStrLength = [inputStr length];
    char *covertChar = [inputStr cStringUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"covertChar =%s",covertChar);
    for(int i=0;i<inputStrLength;i++)
    {
        if(covertChar[i]<='0' || covertChar[i]>='9')
        {
            DLog(@"不是数字");
            return NO;
        }
    }
    return YES;
}

/**
 *  从返回的html中获取SSID字符串
 *
 *  @param html 请求返回的html
 *
 *  @return 返回SSID字符串
 */
+(NSString *)getSSIDWithString:(NSString *)responseHtml{
    NSRange ssidStartRange = [responseHtml rangeOfString:@"ssid000 = \""];
    NSString *ssidString = [responseHtml substringFromIndex:(ssidStartRange.location+ssidStartRange.length)];
    ssidString = [ssidString substringToIndex:[ssidString rangeOfString:@"\";"].location];
    return ssidString;
}

/**
 *  获得wifi的密码
 *
 *  @param responseHtml 请求返回的html
 *
 *  @return 密码
 */
+(NSString *)getWIFIPassword:(NSString *)responseHtml{
    NSRange wifipasswrod = [responseHtml rangeOfString:@"def_wirelesspassword = \""];
    NSString *wifipasswrodString = [responseHtml substringFromIndex:(wifipasswrod.location+wifipasswrod.length)];
    wifipasswrodString = [wifipasswrodString substringToIndex:[wifipasswrodString rangeOfString:@"\","].location];
    return wifipasswrodString;
}

/**
 *  判断登陆路由器的密码是否合法，如果非法则返回NO,合法返回YES
 *
 *  @param responseURL 通过传入响应页面的URL来判断
 *
 *  @return 返回密码是否合法
 */
+(BOOL)isPasswordValidate:(NSString *)responseURL{
    NSRange rangeOfResponseURL = [responseURL rangeOfString:@"login.asp?0"];
    if (rangeOfResponseURL.location == NSNotFound) {
        return YES;
    }
    return NO;
}

/**
 *  读取一个设备标示给插座来区分不同手机用
 *
 *  @return 字符串
 */
+(NSString*)readUUID{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

/**
 *  获得一个类似标示符
 *
 *  @return 字符串
 */
+(NSString *)readLocalMac{
    NSString *tempString = [MyTool readUUID];
    NSString *tempString1 = [tempString substringWithRange:NSMakeRange([tempString length]-12, 12)];
    NSMutableString *localMacString = [[NSMutableString alloc]init];
    for (int i=0; i<[tempString1 length]; i++) {
        if (i!=0) {
            if (i%2==0) {
                [localMacString appendFormat:@":"];
            }
        }
        NSString *macsub = [[tempString1 substringWithRange:NSMakeRange(i, 2)] lowercaseString];

        [localMacString appendFormat:@"%@",macsub];
        i++;
    }
    return localMacString;
}


/**
 *  过滤从广播中得来的ip地址中的非法字符串
 *
 *  @param oriangeIPAddress 未过滤的源ip地址
 *
 *  @return 过滤后的ip地址
 */
+(NSString *)filterIPAddress:(NSString *)oriangeIPAddress{
    NSString *sIPAddress = nil;
    if (oriangeIPAddress) {
        sIPAddress = [[NSString alloc]initWithFormat:@"%@",[oriangeIPAddress stringByReplacingOccurrencesOfString:@"::ffff:" withString:@""]];
    }
    return sIPAddress;
}
@end
