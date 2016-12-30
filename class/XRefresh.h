//
//  XRefresh.h
//  ObjectCDemo
//  Version 1.2.0
//  Created by XiaoJingYuan on 12/30/16.
//  Copyright © 2016 XiaoJingYuan. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class RACSignal;
typedef NS_ENUM(NSInteger, XRefreshState) {
    XRefreshStateBeganDrag = 0,     // 开始拉。
    XRefreshStateCanTouchUp,     //手势所处位置，松手可以开始刷新
    XRefreshStateDragEnd,       //松手,开始加载。
    XRefreshStateBack,       //加载完毕开始复位。
    XRefreshStateEnd        //回到原位，整个环节结束。
};

typedef void (^XRefreshHeadle)(void);


#pragma mark -- 下拉刷新的头视图。
@interface XRefreshView : UIView

@end

@interface UIScrollView(XRefresh)

/**
 *  添加下拉刷新的控件
 *
 *  @param autoAdjust   视图中的scrollview是否自动适应了navigation
 *  @param refreshHeadle 下拉刷新需要处理的事件
 */
- (void)addPullDownRefreshViewAutomaticallyAdjustsScrollView:(BOOL)autoAdjust Block:(XRefreshHeadle)refreshHeadle;

- (void)addPullDownRefreshViewAutomaticallyAdjustsScrollView:(BOOL)autoAdjust withWidth:(CGFloat)width Block:(XRefreshHeadle)refreshHeadle;

/**
 *  上拉加载更多
 *
 *  @param refreshHeadle 上拉后需要处理的事件
 */
- (void)addPullUpRefreshView:(XRefreshHeadle)refreshHeadle;


- (void)addPullUpRefreshView:(XRefreshHeadle)refreshHeadle withWidth:(CGFloat)width;

/**
 *  已经没有更多了，结束上拉增加价更多。
 */
- (void)noIncrease;
- (void)canIncrease;

/**
 *  开始上拉刷新
 */
- (void)startRefresh;
/**
 * 结束下拉刷新。
 */
- (void)stopRefresh;


/**
 *  当滑动scrollview时加一个button 点击直接返回到顶。
 */
- (void)addBackTopButton;
@property (nonatomic, strong)XRefreshView  *xheadView;
@property (nonatomic, strong)XRefreshView  *xfootView;
@end
