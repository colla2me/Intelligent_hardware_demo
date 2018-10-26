//
//  TabPageViewController.m
//  EFNEHotspotHelperDemo
//
//  Created by Samuel on 2018/10/21.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

#import "TabPageViewController.h"

@interface TabPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger beforeIndex;
@property (nonatomic, assign) CGFloat defaultContentOffsetX;
//@property (nonatomic, assign) BOOL shouldScrollCurrentBar;

@end

@implementation TabPageViewController

- (instancetype)init {
    return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
}

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options {
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (self) {
        _isInfinity = NO;
        _beforeIndex = 0;
        _defaultContentOffsetX = CGRectGetWidth(self.view.bounds);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPageViewControleller];
//    [self setupScrollView];
}

- (NSInteger)currentIndex {
    UIViewController *viewController = self.viewControllers.firstObject;
    if (!viewController) {
        return NSNotFound;
    }
    return [self.tabItems indexOfObject:viewController];
}

- (NSUInteger)tabItemsCount {
    return self.tabItems.count;
}

- (void)setupPageViewControleller {
    self.dataSource = self;
    self.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setTabItems:(NSArray<UIViewController *> *)tabItems {
    _tabItems = tabItems;
    [self setViewControllers:@[_tabItems[_beforeIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}

- (void)setupScrollView {
    UIScrollView *scrollView = nil;
    for (UIView *sv in self.view.subviews) {
        if ([sv isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)sv;
            break;
        }
    }
    
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
}

- (void)displayControllerWithIndex:(NSInteger)index direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated {
    self.beforeIndex = index;
    NSArray<UIViewController *> *nextViewControllers = @[self.tabItems[index]];
    
    __weak typeof(self) weakSelf = self;
    void(^completion)(BOOL) = ^(BOOL finished) {
        weakSelf.beforeIndex = index;
    };
    
    [self setViewControllers:nextViewControllers direction:direction animated:animated completion:completion];
//    if (!self.isViewLoaded) return;
}

- (void)configureTabView {
    // TODO:
}

#pragma mark - UIPageViewControllerDataSource

- (nullable UIViewController *)nextViewController:(UIViewController *)viewController isAfter:(BOOL)isAfter {
    NSInteger index = [self.tabItems indexOfObject:viewController];
    if (index == NSNotFound) return nil;
    
    if (isAfter) {
        index += 1;
    } else {
        index -= 1;
    }
    
    if (_isInfinity) {
        if (index < 0) {
            index = self.tabItemsCount - 1;
        } else if (index == self.tabItemsCount) {
            index = 0;
        }
    }
    
    if (index >= 0 && index < self.tabItemsCount) {
        return self.tabItems[index];
    }
    
    return nil;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return [self nextViewController:viewController isAfter:NO];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return [self nextViewController:viewController isAfter:YES];
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
