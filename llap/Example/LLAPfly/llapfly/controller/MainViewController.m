//
//  MainViewController.m
//  llapfly
//
//  Created by KeSun on 16/7/15.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "MainViewController.h"
#import "LoadingView.h"
#import "TBLogoView.h"
#import "TBImageManager.h"
#import "TBConst.h"
#import "TBGamePlayViewController.h"
#import "TBConst.h"

@interface MainViewController ()

@property (nonatomic, weak  ) LoadingView              *loadingView;

//Logo view
@property (nonatomic, strong  ) TBLogoView               *logoView;

//Game play view
@property (nonatomic, strong) TBGamePlayViewController *playVC;

//Socre label
@property (nonatomic, weak  ) UILabel              *scoreLabel;

//Background music
//@property (nonatomic) BOOL                    musicOn;
@end

@implementation MainViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillLayoutSubviews
{
    self.view.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.view.backgroundColor = [UIColor whiteColor];
    LoadingView *load = [[LoadingView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:load];
    self.loadingView = load;
    
    //Additional background music
    //_musicOn = false;
    [self performSelectorInBackground:@selector(buildLogoView) withObject:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScore:) name:@"gameOverPojilu" object:nil];
    
}

- (void)updateScore:(NSNotification *)info
{
    NSDictionary *dic = info.userInfo;
    NSString *score = [dic valueForKey:@"score"];
    self.scoreLabel.text = [NSString stringWithFormat:@"Best score:   %@",score];

}

- (void)buildLogoView
{
    [NSThread sleepForTimeInterval:2.0];
    
    [self.view addSubview:self.logoView];
    [self buildGameNameLabel];
    [self buildScoreLabel];
    [self buildButton];
    
    //Additional background music
    //[self buildMusicButton];
}

/*-(void) buildMusicButton
{   UILabel *testLabel = [[UILabel alloc] init];
    testLabel.frame = CGRectMake(kScreenWidth/2-120, kScreenHeight-290 , 100,  20);
    testLabel.text = [NSString stringWithFormat:@"Music"];
    testLabel.font = [UIFont fontWithName:@"Marker Felt" size:24];
    UIColor *mycolor=[UIColor colorWithRed:137/255.0 green:30/255.0 blue:136/255.0 alpha:1];
    testLabel.textColor = mycolor;
    testLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel = testLabel;
    [self.view addSubview:testLabel];
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth/2+20, kScreenHeight-300, 100, 20)];
    [mySwitch addTarget:self action:@selector(changeMusic:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:mySwitch];
}*/

//Additional background music
/*- (void) changeMusic:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        _musicOn= true;
    } else {
        _musicOn= false;
    }
}*/

- (void)buildGameNameLabel
{
    UILabel *testLabel = [[UILabel alloc] init];
    testLabel.frame = CGRectMake((kScreenWidth - 180)/2 , 40, 180, 60);
    
    testLabel.text = [NSString stringWithFormat:@"Llap Fly"];
    testLabel.font = [UIFont fontWithName:@"Marker Felt" size:50];
    UIColor *mycolor=[UIColor colorWithRed:137/255.0 green:30/255.0 blue:136/255.0 alpha:1];
    testLabel.textColor = mycolor;
    testLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel = testLabel;
    [self.view addSubview:testLabel];
}

//Best Score Label
- (void)buildScoreLabel
{
    UILabel *testLabel = [[UILabel alloc] init];
    testLabel.frame = CGRectMake((kScreenWidth - 180)/2 , 140, 180, 40);
    
    testLabel.text = [NSString stringWithFormat:@"Best score:   %@",[[TBConst score] integerValue] <= 0 ? @(0) : [TBConst score]];
    testLabel.font = [UIFont fontWithName:@"Marker Felt" size:20];
    UIColor *mycolor=[UIColor colorWithRed:137/255.0 green:30/255.0 blue:136/255.0 alpha:1];
    testLabel.textColor = mycolor;
    testLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel = testLabel;
    [self.view addSubview:testLabel];
}

//Start Button
- (void)buildButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.layer.cornerRadius = 20.0;
    button.layer.masksToBounds = YES;
    button.frame = CGRectMake( (kScreenWidth - 140)/2, kScreenHeight-100 , 140, 40);
    [button setTitle:@"Start Game" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor grayColor];
    button.titleLabel.font = [UIFont fontWithName:@"Marker Felt" size:25];
    UIColor *mycolor=[UIColor colorWithRed:137/255.0 green:30/255.0 blue:136/255.0 alpha:1];
    [button setTitleColor:mycolor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gameBegin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)gameBegin
{
    self.playVC = [[TBGamePlayViewController alloc] init];
    [self.playVC loadResources];
    //Additional background music
    //self.playVC.musicOn  = _musicOn;
    [self.view addSubview:self.playVC.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scoreLabel.text = [NSString stringWithFormat:@"Best score:   %@",[TBConst score]];
}
@end
