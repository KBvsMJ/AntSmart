//
//  CurveGraphController.m
//  蚂蚁智能
//
//  Created by IOS－001 on 15-4-23.
//  Copyright (c) 2015年 N/A. All rights reserved.
//

#import "CurveGraphController.h"
#import "Config.h"


@interface CurveGraphController ()
{
    CGRect _rectOfGraph;
    NSInteger xCoordinateInMoniter;
}
@property (nonatomic , strong) HeartLive *translationMoniterView;

@end

@implementation CurveGraphController
+ (CurveGraphController *)sharedManager
{
    static CurveGraphController *sharedCurveGraphInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedCurveGraphInstance = [[self alloc] init];
    });
    return sharedCurveGraphInstance;
}

- (HeartLive *)translationMoniterView
{
    if (!_translationMoniterView) {
        _translationMoniterView = [[HeartLive alloc] initWithFrame:CGRectMake(0, 0, _rectOfGraph.size.width, _globalTopViewHeight)];
        _translationMoniterView.backgroundColor = [UIColor clearColor];
    }
    return _translationMoniterView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self initCurveGraphViewWithFrame:CGRectMake(0, 0, SCREEN_CGSIZE_WIDTH, _globalTopViewHeight)];
}

-(void)initCurveGraphViewWithFrame:(CGRect)rect{
    backgroundView = [[UIView alloc]initWithFrame:rect];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:backgroundView];
    grad = [[GradView alloc]initWithFrame:CGRectMake(0, 0, backgroundView.frame.size.width, backgroundView.frame.size.height)];
    [grad setBackgroundColor:[UIColor clearColor]];
    [backgroundView addSubview:grad];
    if (!bg) {
        bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, backgroundView.frame.size.width, backgroundView.frame.size.height)];
        [bg setImage:[UIImage imageNamed:@"bg6"]];
        [bg setContentMode:UIViewContentModeScaleToFill];
        [backgroundView addSubview:bg];
    }
    [self.view addSubview:self.translationMoniterView];
    [self createWorkDataSourceWithTimeInterval:1];
}

-(void)setGraphViewFrame:(CGRect)rect{
    _rectOfGraph = CGRectMake(0, 0, rect.size.width, rect.size.height-20);
    xCoordinateInMoniter = 1;
    [backgroundView setFrame:rect];
    [grad setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [bg setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [self.translationMoniterView setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark -

- (void)createWorkDataSourceWithTimeInterval:(NSTimeInterval )timeInterval
{

    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerTranslationFun) userInfo:nil repeats:YES];
}


//平移方式绘制
- (void)timerTranslationFun
{
    if ([self.dataSource count]<1) {
        return;
    }
    [[PointContainer sharedContainer] addPointAsTranslationChangeform:[self bubbleTranslationPoint]];
    
    [self.translationMoniterView fireDrawingWithPoints:[[PointContainer sharedContainer] translationPointContainer] pointsCount:[[PointContainer sharedContainer] numberOfTranslationElements]];
}

#pragma mark -
#pragma mark - DataSource


- (CGPoint)bubbleTranslationPoint
{
    static NSInteger dataSourceCounterIndex = -1;
    dataSourceCounterIndex ++;
    NSInteger pixelPerPoint = 3;
    CGFloat yCoordinateInMoniter = _rectOfGraph.size.height;
    CGFloat tempY = [[self.dataSource lastObject] floatValue]*0.8;
    if (tempY<1) {
        tempY = 0;
    }
    yCoordinateInMoniter = _rectOfGraph.size.height-tempY;

    CGPoint targetPointToAdd = (CGPoint){xCoordinateInMoniter,yCoordinateInMoniter};
    xCoordinateInMoniter += pixelPerPoint;
    return targetPointToAdd;
}



@end