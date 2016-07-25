//
//  XRefresh.m
//  ObjectCDemo
//
//  Created by XiaoJingYuan on 5/23/16.
//  Copyright © 2016 XiaoJingYuan. All rights reserved.
//

#import "XRefresh.h"
#import <objc/runtime.h>
CGFloat const refreshHeight = 64;
CGFloat const increaseHeight = 40;
static NSTimeInterval const delayTime = 1;
static NSTimeInterval const animateDurationTime = 0.3;
static char *refreshHeadView = "xheadView";
static char *refreshFootView = "xFootView";

@implementation XRefreshView
#pragma mark -- 下拉刷新
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleArray =@[@"下拉刷新",@"松手刷新",@"刷新中……",@"刷新结束",@"下拉刷新"];
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height - refreshHeight, frame.size.width, 30)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        self.state = XRefreshStateEnd;
    }
    return self;
}
- (void)setState:(XRefreshState)state
{
    _state = state;
    self.titleLabel.text = self.titleArray[self.state];
    switch (state) {
        case XRefreshStateEnd:
        {
            
        }
            break;
            
        case XRefreshStateCanTouchUp:
        {
            
        }
            break;
        case XRefreshStateBeganDrag:
        {
            
        }
            break;
            
        case XRefreshStateDragEnd:
        {
            if (self.xRefreshHeadle) {
                self.willStop = NO;
                self.xRefreshHeadle();
            }
            
        }
            break;
            
        case XRefreshStateBack:
        {
        }
            break;
            
            
        default:
            break;
    }
}
- (void)xRefreshScrollViewOff:(UIScrollView *)scroll{
    if (self.state < XRefreshStateDragEnd) {
        NSLog(@"==%f==%f",scroll.contentOffset.y,scroll.contentSize.height-scroll.bounds.size.height+increaseHeight);
        if (scroll.contentOffset.y < -self.edgeInsetTop||(scroll.contentSize.height > scroll.bounds.size.height && scroll.contentOffset.y > scroll.contentSize.height-scroll.bounds.size.height+increaseHeight)) {
            if (self.state!=XRefreshStateCanTouchUp) {
                self.state = XRefreshStateCanTouchUp;
            }
        }
        else
        {
            if (self.state!=XRefreshStateBeganDrag) {
                self.state = XRefreshStateBeganDrag;
            }
            
        }
    }
}
#pragma mark -- 上拉增加更多
- (instancetype)initWithIncreaseFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleArray =@[@"上拉加载更多",@"松手加载",@"加载中……",@"加载结束",@"上拉加载更多"];
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        self.state = XRefreshStateEnd;
    }
    return self;
}

@end
@implementation UIScrollView(XRefresh)

@dynamic xfootView;
@dynamic xheadView;

#pragma mark -- 添加下拉刷新
- (void)addPullDownRefreshViewAutomaticallyAdjustsScrollView:(BOOL)autoAdjust Block:(XRefreshHeadle)refreshHeadle
{
    if (!self.xheadView) {
        XRefreshView *view = [[XRefreshView alloc]initWithFrame:CGRectMake(0, -100-refreshHeight, self.bounds.size.width, refreshHeight+100)];
        view.backgroundColor = [UIColor whiteColor];
        [self addSubview:view];
        self.xheadView = view;
        self.xheadView.xRefreshHeadle = refreshHeadle;
        
        if (autoAdjust) {
            self.xheadView.edgeInsetTop = 64+refreshHeight;
        }
        else
        {
            self.xheadView.edgeInsetTop = refreshHeight;
        }
        
        [self.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        
    }
}
- (void)setXheadView:(XRefreshView *)xheadView
{
    [self willChangeValueForKey:@"xheadView"];
    objc_setAssociatedObject(self, refreshHeadView,
                             xheadView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"xheadView"];
    
}
- (XRefreshView *)xheadView
{
    return objc_getAssociatedObject(self, refreshHeadView);
}

#pragma mark -- 添加上拉更多
- (void)addPullUpRefreshView:(XRefreshHeadle)refreshHeadle
{
    if (!self.xfootView) {
        self.contentInset= UIEdgeInsetsMake(self.xheadView.edgeInsetTop - refreshHeight, 0, 0, increaseHeight);
        
        XRefreshView *footView = [[XRefreshView alloc]initWithIncreaseFrame:CGRectMake(0, self.contentSize.height, self.bounds.size.width, increaseHeight) ];
        footView.backgroundColor = [UIColor whiteColor];
        [self addSubview:footView];
        self.xfootView = footView;
        self.xfootView.xRefreshHeadle = refreshHeadle;
        
        [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    }
}
- (void)setXfootView:(XRefreshView *)xfootView
{
    [self willChangeValueForKey:@"xfootView"];
    objc_setAssociatedObject(self, refreshFootView,
                             xfootView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"xfootView"];
}
- (XRefreshView *)xfootView{
   return objc_getAssociatedObject(self, refreshFootView);
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (self.xheadView) {
          [self.xheadView xRefreshScrollViewOff:self];
        }
        
        
    }else if ([keyPath isEqualToString:@"state"])
    {
        if ([change[NSKeyValueChangeOldKey]integerValue] == 1&&[change[NSKeyValueChangeNewKey]integerValue]==2) {
            //开始滑动
            if (self.xheadView) {
               self.xheadView.state = XRefreshStateBeganDrag;
            }
           
            if (self.xfootView) {
                self.xfootView.state = XRefreshStateBeganDrag;
            }
            
        }
        else
            if ([change[NSKeyValueChangeOldKey]integerValue] == 2&&[change[NSKeyValueChangeNewKey]integerValue]==3) {
                //松开手势
                if (self.contentOffset.y < -self.xheadView.edgeInsetTop) {
                    [self startRefresh];
                    
                }
                else
                    if (self.contentOffset.y > (self.contentSize.height-self.bounds.size.height+increaseHeight/2)) {
                        [self startIncrease];
                    }
                
            }
    }
    else
        if ([keyPath isEqualToString:@"contentSize"]) {
            if (![[change objectForKey:NSKeyValueChangeOldKey ] isEqual:change[NSKeyValueChangeNewKey]]) {
                self.xfootView.frame = CGRectMake(0, self.contentSize.height, self.bounds.size.width, increaseHeight);
            }
        }
}
- (void)timeToBack:(XRefreshView *)view
{
    [self goBackSite:view];
}
- (void)goBackSite:(XRefreshView *)refreshView
{
    if (refreshView.willStop == YES) {
        refreshView.state = XRefreshStateBack;
        [UIView animateWithDuration:animateDurationTime animations:^{
            self.contentInset = UIEdgeInsetsMake(refreshView.edgeInsetTop - refreshHeight, 0, 0, 0);
        }completion:^(BOOL finished) {
            refreshView.state = XRefreshStateEnd;
            refreshView.willStop = NO;
        }];
    }
    else
    {
        refreshView.willStop = YES;
    }
    
}

- (void)startRefresh
{
    self.xheadView.state = XRefreshStateDragEnd;
   
    [UIView animateWithDuration:animateDurationTime animations:^{
        self.contentInset = UIEdgeInsetsMake(self.xheadView.edgeInsetTop, self.contentInset.left, self.contentInset.bottom, self.contentInset.right);
    }completion:^(BOOL finished) {
        [self performSelector:@selector(timeToBack:) withObject:self.xheadView afterDelay:delayTime];
    }];
    
}
- (void)stopRefresh{
    
    [self goBackSite:self.xheadView];
}
- (void)startIncrease
{
    self.xfootView.state = XRefreshStateDragEnd;
    
}
- (void)endIncrease
{
    self.xfootView.titleLabel.text = @"没有更多了……";
}
- (void)dealloc
{

    if (self.xfootView) {
        [self removeObserver:self forKeyPath:@"contentSize"];
    }
    if (self.xheadView) {
        [self removeObserver:self forKeyPath:@"contentOffset"];
        [self.panGestureRecognizer removeObserver:self forKeyPath:@"state"];
    }
    
    
}
//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    if (self.xfootView) {
//        [self removeObserver:self forKeyPath:@"contentSize"];
//    }
//    if (self.xheadView) {
//        [self removeObserver:self forKeyPath:@"contentOffset"];
//        [self.panGestureRecognizer removeObserver:self forKeyPath:@"state"];
//    }
//    
//}


@end
