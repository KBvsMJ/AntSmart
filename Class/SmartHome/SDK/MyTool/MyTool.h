#import <Foundation/Foundation.h>
#import "NSString+MD5.h"
@interface MyTool : NSObject



/**
 *@brief 根据两个点的经纬度计算两个点距离
 */
+(double)distanceBetweenOrderByLat1:(double)lat1 Andlng1:(double)lng1 Lat2:(double)lat2 Lng2:(double)lng2;

/**
 *@brief 根据时间戳计算出日期
 */
+(NSString*)TimestampToDate:(NSString*)timestamp;


/**
 *@brief 根据时间戳计算出日期加时间
 */
+(NSDate*)TimestampToDateAndTime:(NSString*)timestamp;

/**
 *  传入一个日期对象返回日期加时间的字符串
 *
 *  @param date 日期对象
 *
 *  @return 日期加时间的字符串
 */
+(NSString *)stringFromDate:(NSDate *)date;

/**
 *@brief 角度转换为弧度
 */
+(double)radians:(float)degrees;

/**
 *@brief 写入JSON和Html文件，存储在Documents/Caches
 */
+(void)writeCacherequestUrl:(NSString*)url;
/**
 *@brief 读取JSON和Html文件，存储在Documents/Caches，返回NSdata类型
 */
+(NSData*)readCacheData:(NSString*)urlStr;
/*
 *获取存储的文件路径
 */
+(NSString*)fileExistsCacheFile:(NSString*)urlStr;
/**
 *@brief 读取JSON和Html文件，存储在Documents/Caches，返回NSString类型
 */
+(NSString*)readCacheString:(NSString*)urlStr;
/**
 *@brief 判断缓存文件是否存在
*/

/**
 *@判断视频的文件路径是否有视频
 */
+(BOOL)isExistsVideoFile:(NSString*)urlStr;
/**
 *@返回视频的文件路径
 */
+(NSString *)getVideoFilePath:(NSString*)urlStr;


+(BOOL)isExistsCacheFile:(NSString*)urlStr;
/**
 *@brief 获得SDWebImage的图片存储路径
 */
+(NSString*)getSDWebImageFilePath:(NSString*)filepath;

/**
 *@brief 写入图片到SDWebImage的图片存储目录下
 */
+(void)writeImageCache:(NSData*)imageData requestUrl:(NSString*)url;
/**
 *@brief 根据图片网络路径写入图片到SDWebImage的图片存储目录下
 */
+(void)writeImageCacheRequestUrl:(NSString*)url;

/**
 *@brief 获得当前的时间，例如2013-08-11 16:05:03
 */
+(NSString*)getCurrentDateString;


+(void)writeCalculImageCache:(NSData*)imageData requestUrl:(NSString*)url;


+(void)writeCache:(NSString *)responseStr requestUrl:(NSString*)url;


/**
 *@brief 获得应用的沙盒路径
 */
+ (NSString *)applicationDocumentsDirectory;



/**
 *@brief url中有中文的情况使用此方法转为UTF-8
 */
+(NSString*)stringCovertToUTF8:(NSString *)urlString;

/**
 *@brief 性别的代码与字符串之间的转换
 */
+(NSString*)sexCodeCovertString:(NSString*)sexCode;

/**
 *@brief 时间字符串转时间戳
 */
+(NSString*)dateNSStringToTimestamp:(NSString*)dateNSString;

/**
 *@brief 判断字符串是否全部为数字
 */
+(BOOL)stringIsDigit:(NSString*)inputStr;


/**
 *  从返回的html中获取SSID字符串
 *
 *  @param html 请求返回的html
 *
 *  @return 返回SSID字符串
 */
+(NSString *)getSSIDWithString:(NSString *)responseHtml;

/**
 *  判断登陆路由器的密码是否合法，如果非法则返回NO,合法返回YES
 *
 *  @param responseURL 通过传入响应页面的URL来判断
 *
 *  @return 返回密码是否合法
 */
+(BOOL)isPasswordValidate:(NSString *)responseURL;

/**
 *  获得wifi的密码
 *
 *  @param responseHtml 请求返回的html
 *
 *  @return 密码
 */
+(NSString *)getWIFIPassword:(NSString *)responseHtml;


/**
 *  读取一个设备标示给插座来区分不同手机用
 *
 *  @return 字符串
 */
+(NSString*)readUUID;


/**
 *  获得一个类似标示符
 *
 *  @return 字符串
 */
+(NSString *)readLocalMac;


/**
 *  过滤从广播中得来的ip地址中的非法字符串
 *
 *  @param oriangeIPAddress 未过滤的源ip地址
 *
 *  @return 过滤后的ip地址
 */
+(NSString *)filterIPAddress:(NSString *)oriangeIPAddress;
@end
