//
//  XRefresh.m
//  ObjectCDemo
//
//  Created by XiaoJingYuan on 5/23/16.
//  Copyright © 2016 XiaoJingYuan. All rights reserved.
//

#import "XRefresh.h"
#import <objc/runtime.h>
#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define kScreen_Height [UIScreen mainScreen].bounds.size.height
CGFloat const refreshHeight = 64;
CGFloat const increaseHeight = 30;
static NSTimeInterval const delayTime = 1;
static NSTimeInterval const animateDurationTime = 0.3;
static char *refreshHeadView = "xheadView";
static char *refreshFootView = "xFootView";
static NSString *const noIncreaseStr = @"没有更多了……";
#pragma mark -- 刷新动画界面
@interface XRefreshView ()

@property (nonatomic, strong)UILabel   *titleLabel;
@property (nonatomic, strong)UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, copy)XRefreshHeadle xRefreshHeadle;
//scroll的偏移量,未开拉前的，对应foot是下偏移量，header是上偏移量。
@property (nonatomic, assign)CGFloat  originalOffSetY;
//状态
@property (nonatomic, assign)XRefreshState    state;
/**
 *  下拉刷新，他判断是否符合返回条件。保证最低停留时间。Yes即将停止加载，再次触发就停止加载。
 */
@property (nonatomic, assign)BOOL    willStop;
/**
 *  判断上拉提示语，是否需要改变，是否可以加载更多。默认NO是可以加载更多。Yes停止加载。
 */
@property (nonatomic, assign)BOOL    noIncreae;
//上面显示标题的数组，和状态相对应。
@property (nonatomic, strong)NSArray     *titleArray;
@property (nonatomic, assign)BOOL         sizeObserving;//是否在监听size
@property (nonatomic, assign)BOOL         offsetObserving;//是否在监听offset
- (instancetype)initWithIncreaseFrame:(CGRect)frame;

@end

@implementation XRefreshView
#pragma mark -- 下拉刷新
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleArray =@[@"下拉刷新",@"松手刷新",@"刷新中……",@"刷新结束",@"下拉刷新"];
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width*0.5+20, frame.size.height - 30, frame.size.width*0.6, 20)];
        _titleLabel.font= [UIFont systemFontOfSize:12];
        [self addSubview:self.titleLabel];
        
        UILabel *sloganLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width*0.5+20, frame.size.height -50, frame.size.width*0.6, 20)];
        sloganLabel.text = @"想要写的标语";
        sloganLabel.font = [UIFont boldSystemFontOfSize:13];
        [self addSubview:sloganLabel];
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width*0.4 - 42, frame.size.height - refreshHeight+3, 38,58 )];
        [self addSubview:_imageView];//42  64
        [_imageView setImage:[UIImage imageNamed:@"下拉刷新_00000"]];
        _imageView.animationImages = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"下拉刷新_00000"],
                                    
                                      [UIImage imageNamed:@"下拉刷新_00002"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00004"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00006"],
                                     
                                      [UIImage imageNamed:@"下拉刷新_00008"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00010"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00012"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00014"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00016"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00018"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00020"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00022"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00024"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00026"],
                                      
                                      [UIImage imageNamed:@"下拉刷新_00028"],
                                     
                                      [UIImage imageNamed:@"下拉刷新_00030"],nil];
        _imageView.animationDuration = 0.5;
        _imageView.animationRepeatCount = 0;
        self.state = XRefreshStateEnd;
    }
    return self;
}

- (void)setState:(XRefreshState)state
{
    //没有更多的时候，状态不发生改变。
    if (self.noIncreae) {
        return;
    }
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
            //拖拽结束，开始加载
            if (self.xRefreshHeadle) {
                self.willStop = NO;
                self.xRefreshHeadle();
            }

            if (_imageView) {
              [_imageView startAnimating];
            }
            
            
        }
            break;
            
        case XRefreshStateBack:
        {
            if (_imageView) {
              [_imageView stopAnimating];
            }
            

        }
            break;
            
            
        default:
            break;
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
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.titleLabel];
        self.state = XRefreshStateEnd;
    }
    return self;
}
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil && self.superview) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (self.offsetObserving) {
            [scrollView removeObserver:scrollView forKeyPath:@"contentOffset"context:@"xrefresh"];
            self.offsetObserving = NO;
        }
        if (self.sizeObserving) {
           [scrollView removeObserver:scrollView forKeyPath:@"contentSize"context:@"xrefresh"];
            self.sizeObserving = NO;
        }
    }
}

@end

#pragma mark -- UIScrollView 刷新
@implementation UIScrollView(XRefresh)

@dynamic xfootView;
@dynamic xheadView;

#pragma mark -- 添加下拉刷新
- (void)addPullDownRefreshViewAutomaticallyAdjustsScrollView:(BOOL)autoAdjust Block:(XRefreshHeadle)refreshHeadle {
    [self addPullDownRefreshViewAutomaticallyAdjustsScrollView:autoAdjust withWidth:[UIScreen mainScreen].bounds.size.width Block:refreshHeadle];
    
}


- (void)addPullDownRefreshViewAutomaticallyAdjustsScrollView:(BOOL)autoAdjust withWidth:(CGFloat)width Block:(XRefreshHeadle)refreshHeadle {
    if (!self.xheadView) {
        
        
        XRefreshView *view = [[XRefreshView alloc]initWithFrame:CGRectMake(0, -100-refreshHeight, width, refreshHeight+100)];
        //        view.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:view];
        self.xheadView = view;
        self.xheadView.xRefreshHeadle = refreshHeadle;
        //        self.xheadView.state = XRefreshStateEnd;
        if (autoAdjust) {
            self.xheadView.originalOffSetY = -64;
        }
        else
        {
            self.xheadView.originalOffSetY = 0;
        }
        if (!self.xheadView.offsetObserving&&!self.xfootView.offsetObserving) {
            
            [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:@"xrefresh"];
            self.xheadView.offsetObserving = YES;
        }
        
    }
    
}

- (void)setXheadView:(XRefreshView *)xheadView {
    [self willChangeValueForKey:@"xheadView"];
    objc_setAssociatedObject(self, refreshHeadView,
                             xheadView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"xheadView"];
    
}
- (XRefreshView *)xheadView {
    return objc_getAssociatedObject(self, refreshHeadView);
}

#pragma mark -- 添加上拉更多
- (void)addPullUpRefreshView:(XRefreshHeadle)refreshHeadle {
    //[UIScreen mainScreen].bounds.size.width
    [self addPullUpRefreshView:refreshHeadle withWidth:[UIScreen mainScreen].bounds.size.width];
}

- (void)addPullUpRefreshView:(XRefreshHeadle)refreshHeadle withWidth:(CGFloat)width {
    if (!self.xfootView) {
        
        XRefreshView *footView = [[XRefreshView alloc]initWithIncreaseFrame:CGRectMake(0, self.contentSize.height, width, increaseHeight) ];
        //        footView.backgroundColor = [UIColor whiteColor];
        [self addSubview:footView];
        self.xfootView = footView;
        self.xfootView.xRefreshHeadle = refreshHeadle;
        
        if (!self.xfootView.sizeObserving) {
           [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"xrefresh"];
            self.xfootView.sizeObserving = YES;
        }
        
        if (!self.xfootView.offsetObserving&&!self.xheadView.offsetObserving) {
            
            [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:@"xrefresh"];
            self.xfootView.offsetObserving = YES;
        }
        
    }
    
}





- (void)setXfootView:(XRefreshView *)xfootView {
    [self willChangeValueForKey:@"xfootView"];
    objc_setAssociatedObject(self, refreshFootView,
                             xfootView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"xfootView"];
}
- (XRefreshView *)xfootView{
   return objc_getAssociatedObject(self, refreshFootView);
}
#pragma mark -- 监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
        
    }
    else
        if ([keyPath isEqualToString:@"contentSize"]) {
            if (![[change objectForKey:NSKeyValueChangeOldKey ] isEqual:change[NSKeyValueChangeNewKey]]) {
                if (self.contentSize.height>=self.frame.size.height) {
                    self.xfootView.hidden = NO;
                  self.xfootView.frame = CGRectMake(0, self.contentSize.height, self.bounds.size.width, 30);
                }
                else
                {
                    self.xfootView.hidden = YES;
                }
                
            }
        }
}
- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if (self.contentOffset.y<0) {//只有下拉的时候，才会判断下拉刷新
        
        if (self.xheadView.state == XRefreshStateEnd&&!self.isDragging) {//如果还没有拖拽就发生偏移错误，就进行修正。
            
            if (self.contentOffset.y!=self.xheadView.originalOffSetY) {
                self.contentInset = UIEdgeInsetsMake(-self.xheadView.originalOffSetY, 0, self.contentInset.bottom, 0);
                self.contentOffset = CGPointMake(0, self.xheadView.originalOffSetY);
                 self.xheadView.imageView.frame =CGRectMake(kScreen_Width*0.4 - 42, self.xheadView.frame.size.height - refreshHeight+3, 0,0 );
            }
        }

        if (contentOffset.y <= self.xheadView.originalOffSetY- refreshHeight) {
            
            if (!self.isDragging) {
                
                if (self.xheadView.state == XRefreshStateCanTouchUp) {
                    [self startRefresh];
                    NSLog(@"下拉刷新松手了");
                }
                
            }
            else
            {
                if (self.xheadView.state == XRefreshStateBeganDrag) {
                    self.xheadView.state = XRefreshStateCanTouchUp;

                    self.xheadView.imageView.frame =CGRectMake(kScreen_Width*0.4 - 42, self.xheadView.frame.size.height - refreshHeight+3, 38,58 );

                    
                }
            }
            
            }
        else
        {
            if (self.isDragging) {//在下拉较轻时，正在拉就是开始拉着了，如果手指没有拖拽，就是已经结束归位了。
                self.xheadView.state = XRefreshStateBeganDrag;
            }
            else
            {
                if (self.xheadView.state !=XRefreshStateEnd) {
                  self.xheadView.state = XRefreshStateEnd;
                }
                
            }
            //只要不是刚拖拽结束加载的时候，图都是随动的。
            if (self.xheadView.state != XRefreshStateDragEnd) {
                float height =MIN((self.xheadView.originalOffSetY-contentOffset.y), 58);
               self.xheadView.imageView.frame = CGRectMake(kScreen_Width*0.4 - 42, self.xheadView.frame.size.height - refreshHeight+3+(58-height), 38*height/58, height);
            }
            
        }
        
    }
    else
        if (self.contentOffset.y>self.frame.size.height-100&&self.contentOffset.y<self.frame.size.height+100) {//判断按钮什么时候出现
            UIButton *upTopButton =objc_getAssociatedObject(self, "upTopButton");
            if (self.contentOffset.y>self.frame.size.height&&upTopButton.hidden) {
                upTopButton.hidden = NO;
            }
            else
                if (self.contentOffset.y<self.frame.size.height&& !upTopButton.hidden) {
                    upTopButton.hidden = YES;
                }
        }
    else//上拉加载更多
        if (self.contentOffset.y >= self.contentSize.height-2*self.bounds.size.height && !self.xfootView.noIncreae) {
            
            if (self.isDragging) {
                if (self.xfootView.state != XRefreshStateCanTouchUp) {
                    self.xfootView.state = XRefreshStateCanTouchUp;
                }
            }
            else
            {
                if (self.xfootView.state ==XRefreshStateCanTouchUp ) {
                    [self startIncrease];
                }
            }
            
        }
    

}

- (void)startRefresh {
    
    self.xheadView.state = XRefreshStateDragEnd;
    [UIView animateWithDuration:0.1 animations:^{
        //顺序是 上左下右
        self.contentInset = UIEdgeInsetsMake(-self.xheadView.originalOffSetY+refreshHeight,0,  self.contentInset.bottom, 0) ;
        
    } completion:^(BOOL finished) {
        
    }];
    //如果刷新了界面那么就再次可以加载更多了
    if (self.xfootView) {
        self.xfootView.noIncreae = NO;
    }
    [self performSelector:@selector(goBackSite) withObject:self.xheadView afterDelay:delayTime];
    
}
- (void)stopRefresh {
    
    [self goBackSite];
    if (self.xfootView) {
        self.xfootView.state = XRefreshStateEnd;
    }
}
//加载结束返回原来的位置。
- (void)goBackSite {
    
    if (self.xheadView.willStop == YES) {
        self.xheadView.state = XRefreshStateBack;
        [UIView animateWithDuration:animateDurationTime animations:^{
            self.contentInset = UIEdgeInsetsMake(-self.xheadView.originalOffSetY, 0, self.contentInset.bottom, 0);
        }completion:^(BOOL finished) {
            self.xheadView.state = XRefreshStateEnd;
            self.xheadView.willStop = NO;
        }];
    }
    else
    {
        self.xheadView.willStop = YES;
        if (self.xfootView.state != XRefreshStateBack) {
            self.xfootView.state = XRefreshStateBack;
        }
    }
    
    
}
- (void)startIncrease {
    if (self.xfootView.state == XRefreshStateCanTouchUp) {
     self.xfootView.state = XRefreshStateDragEnd;
//        NSLog(@"========startIncrease=======");
    }
    
}
- (void)noIncrease {
    self.xfootView.noIncreae = YES;
    self.xfootView.state = XRefreshStateEnd;
    self.xfootView.titleLabel.text = noIncreaseStr;
}
- (void)canIncrease {
    self.xfootView.noIncreae = NO;
}

- (void)addBackTopButton {
   
    UIButton *upTopButton =objc_getAssociatedObject(self, "upTopButton");
    if (!upTopButton) {
        upTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        upTopButton.frame = CGRectMake(kScreen_Width-60, kScreen_Height -180, 50, 50);
//        upTopButton.backgroundColor = [UIColor redColor];
        [upTopButton setImage:[UIImage imageNamed:@"返回顶部快捷按钮"] forState:UIControlStateNormal];
        [upTopButton setImage:[UIImage imageNamed:@"返回顶部快捷按钮触发"] forState:UIControlStateHighlighted];
        [upTopButton addTarget:self action:@selector(upTopButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.superview addSubview:upTopButton];
        objc_setAssociatedObject(self, "upTopButton",
                                 upTopButton,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    upTopButton.hidden = YES;
   [self.superview bringSubviewToFront:upTopButton];
}
- (void)upTopButtonAction:(UIButton *)button {
    XRefreshView *headerView = objc_getAssociatedObject(self, refreshHeadView);
    [self setContentOffset:CGPointMake(0,headerView.originalOffSetY) animated:YES];
}


@end
