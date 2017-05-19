//
//  TBGamePlayViewController.m
//  llapfly
//
//  Created by KeSun on 16/7/15.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "TBGamePlayViewController.h"
#import "UIView+Extension.h"
#import "TBImageManager.h"
#import "TBBackGroundView.h"
#import "TBConst.h"
#import "TBBullet.h"
#import "TBGameModel.h"
#import "TBHeroView.h"
#import "TBBulletView.h"
#import "TBEnemy.h"
#import "TBEnemyView.h"
#import "AudioController.h"
static long steps;

@interface TBGamePlayViewController ()
{
    //Ultsound based controller
    AudioController *audioController;
}

//Game clock
@property (strong, nonatomic) CADisplayLink    *gameTimer;
//Game resource
@property (nonatomic, strong) TBImageManager   *imageManager;
//Game background
@property (nonatomic, strong) TBBackGroundView *backGroundView;

@property (nonatomic, strong) TBGameModel      *gameModel;
//Game UI view
@property (strong, nonatomic) UIView           *gameView;
//Pause button
@property (strong, nonatomic) UIButton         *button;
//Game score
@property (nonatomic, strong) UILabel          *scoreLabel;
//Hero airplane view
@property (strong, nonatomic) TBHeroView       *heroView;

//Bullet view set
@property (strong, nonatomic) NSMutableSet     *bulletViewSet;

//Enemy view set
@property (strong, nonatomic) NSMutableSet     *enemyViewSet;

@end

@implementation TBGamePlayViewController
- (void)viewWillLayoutSubviews
{
    self.view.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    steps = 0;
    [self loadBackImage];
    //Init set
    self.bulletViewSet = [NSMutableSet set];
    self.enemyViewSet = [NSMutableSet set];
    
    CGSize heroSize = [self.imageManager.heroFlyImages[0] size];
    self.gameModel = [TBGameModel gameModelWithArea:self.view.bounds heroSize:heroSize];
    [self.gameModel.hero setBullteNormalSize:[self.imageManager.bullteNormalImage size]];
    [self.gameModel.hero setBullteEnhancedSize:[self.imageManager.bullteEnhancedImage size]];
    
    
    //Game view
    self.gameView = [[UIView alloc] initWithFrame:self.gameModel.gameArea];
    [self.view addSubview:self.gameView];
    
    
    //Pause button
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setImage:self.imageManager.pauseImage forState:UIControlStateNormal];
    [self.button setImage:self.imageManager.pauseHLImage forState:UIControlStateHighlighted];
    self.button.frame = CGRectMake(20, 20, self.imageManager.pauseImage.size.width, self.imageManager.pauseImage.size.height);
    [self.button addTarget:self action:@selector(pauseGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    //Game score
    self.scoreLabel = [[UILabel alloc] init];
    self.scoreLabel.textAlignment = NSTextAlignmentLeft;
    UIColor *mycolor=[UIColor colorWithRed:137/255.0 green:30/255.0 blue:136/255.0 alpha:1];
    self.scoreLabel.textColor = mycolor;
    self.scoreLabel.font = [UIFont fontWithName:@"Marker Felt" size:20];
    self.scoreLabel.frame = CGRectMake(CGRectGetMaxX(self.button.frame) + 15, CGRectGetMinY(self.button.frame), 150, CGRectGetHeight(self.button.frame));
    [self.view addSubview:self.scoreLabel];
    
    //Hero view
    self.heroView = [[TBHeroView alloc] initWithImages:self.imageManager.heroFlyImages];
    [self.heroView setCenter:self.gameModel.hero.position];
    [self.gameView addSubview:self.heroView];
    
    //Audio controller by ultrasound
    audioController = [[AudioController alloc] init];
    audioController.audiodistance=0;
    [audioController startIOUnit];
    
    //Additional Background music
    //if(_musicOn) [audioController playMySound];
    
    //Keep screen brightness
    [ [ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
    [NSThread sleepForTimeInterval:1.0];
    [self startGameTimer];
}

#pragma mark - puasegame
- (void)pauseGame
{
   self.button.tag = !self.button.tag;
    if (self.button.tag) {
        [self.button setImage:self.imageManager.startImage forState:UIControlStateNormal];
        [self.button setImage:self.imageManager.startHLImage forState:UIControlStateHighlighted];
        [self stopGameTimer];
    } else {
        [self.button setImage:self.imageManager.pauseImage forState:UIControlStateNormal];
        [self.button setImage:self.imageManager.pauseHLImage forState:UIControlStateHighlighted];
        [self startGameTimer];
    }
    
}

#pragma mark - updatescroe
- (void)updateScorel
{
    if (self.gameModel.score == 0) {
        self.scoreLabel.text = @"";
    } else {
        self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.gameModel.score * 100];;
    }
}

- (void)gameStep
{
    steps ++;
    
    //Update hero location
    self.heroView.center = self.gameModel.hero.position;
    
    if (steps % 20 == 0) {
        [self.gameModel.hero fire];
    }
    
    //Check all of the bullets
    if (steps % 3==0)
    {
        [self heroMoved];
    }
    [self checkBullets];
    
    
    //Create enemy
    [self createEnemys];
    
    //Update enemy location
    [self updateEnemyPosition];
    
    //Check collision
    [self checkCollision];
}
#pragma mark - Hero move
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self.gameView];
    
    CGPoint previousLocation = [touch previousLocationInView:self.gameView];
    
    CGPoint offSet = CGPointMake(location.x - previousLocation.x, location.y - previousLocation.y);
    
    CGPoint prePosition = self.gameModel.hero.position;
    
    CGPoint nowPosition = CGPointMake(prePosition.x + offSet.x, prePosition.y + offSet.y);
    
    //Keep hero in the view
    if (nowPosition.x < 0) {
        nowPosition.x = 0;
    }
    if (nowPosition.x > self.gameModel.gameArea.size.width) {
        nowPosition.x = self.gameModel.gameArea.size.width;
    }
    if (nowPosition.y < self.gameModel.hero.size.height / 2) {
        nowPosition.y = self.gameModel.hero.size.height / 2;
    }
    if (nowPosition.y > self.gameModel.gameArea.size.height - self.gameModel.hero.size.height / 2) {
        nowPosition.y = self.gameModel.gameArea.size.height - self.gameModel.hero.size.height / 2;
    }
    self.gameModel.hero.position = nowPosition;
}

//Hero move
- (void)heroMoved
{
    CGPoint prePosition = self.gameModel.hero.position;
    CGPoint nowPosition;
    
    //Control hero by ultrasound
    nowPosition = CGPointMake(audioController.audiodistance*(audioController.audiodistance+100)/100*5, prePosition.y);
    
    
    //Keep hero in the view
    if (nowPosition.x < 0) {
        nowPosition.x = 0;
        audioController.audiodistance=0;
    }
    if (nowPosition.x > self.gameModel.gameArea.size.width) {
        nowPosition.x = self.gameModel.gameArea.size.width;
        audioController.audiodistance = (-100+sqrt(100*100+self.gameModel.gameArea.size.width*4*100/5))/2;
    }
    if (nowPosition.y < self.gameModel.hero.size.height / 2) {
        nowPosition.y = self.gameModel.hero.size.height / 2;
    }
    if (nowPosition.y > self.gameModel.gameArea.size.height - self.gameModel.hero.size.height / 2) {
        nowPosition.y = self.gameModel.gameArea.size.height - self.gameModel.hero.size.height / 2;
    }
    self.gameModel.hero.position = nowPosition;
}

#pragma mark - check bullets
- (void)checkBullets
{
    NSMutableSet *needRemoveSet = [NSMutableSet set];
    
    for (TBBulletView *buview in self.bulletViewSet) {
        
        CGPoint position = CGPointMake(buview.center.x, buview.center.y - 8.0);
        [buview setCenter:position];
        //Check if the bullet is out of the view
        if (CGRectGetMaxY(buview.frame) < 0 ) {
            [needRemoveSet addObject:buview];
        }
        
    }
    
    //Delete the bullets which are out of the view
    for (TBBulletView *bulletView in needRemoveSet) {
        //Delete it from view
        [bulletView removeFromSuperview];
        //Delete it from set
        [self.bulletViewSet removeObject:bulletView];
    }
    
    [needRemoveSet removeAllObjects];
    
    for (TBBullet *bullet in self.gameModel.hero.bullteSet) {
        
        UIImage *bulletImage = self.imageManager.bullteNormalImage;
        
        if (bullet.isEnhanced) {
            bulletImage = self.imageManager.bullteEnhancedImage;
        }
        TBBulletView *bulletView = [[TBBulletView alloc] initWithImage:bulletImage bullet:bullet];
        [bulletView setCenter:bullet.position];
        [self.gameView addSubview:bulletView];
        [self.bulletViewSet addObject:bulletView];
        
    }
    
    [self.gameModel.hero.bullteSet removeAllObjects];
  
}

#pragma  mark - enemy
//Create enemy
- (void)createEnemys
{
    if (steps % 20 == 0) {
        //Create model
        TBEnemy *enemy = nil;
        
        if (steps % (5 * 60) == 0) {
            //Random the type of the enemy
            TBEnemyType type = (arc4random_uniform(2) == 0) ? kEnemyMiddle : kEnemyBig;
            
            CGSize size = self.imageManager.enemyMiddleImage.size;
            if (kEnemyBig == type) {
                size = [self.imageManager.enemyBigImages[0]size];
            }
            enemy = [self.gameModel createEnemyWithType:type size:size];
        } else {
            //Small enemy
            enemy = [self.gameModel createEnemyWithType:kEnemySmall size:self.imageManager.enemySmallImage.size];
            
        }
        
        //Build enemy view
        TBEnemyView *enemyView = [[TBEnemyView alloc] initWithEnemy:enemy imageManager:_imageManager];
        
        //Add enemy into view and set
        [self.enemyViewSet addObject:enemyView];
        [self.gameView addSubview:enemyView];
    }
}

//Update enemy position
- (void)updateEnemyPosition
{
    
    NSMutableSet *neetRemoveEnemySet = [NSMutableSet set];
    for (TBEnemyView *enView in self.enemyViewSet) {
        TBEnemy *en = enView.enemy;
        CGPoint position = CGPointMake(enView.center.x, enView.center.y + en.speed);
        [enView setCenter:position];
        if (CGRectGetMaxY(enView.frame) > self.gameModel.gameArea.size.height) {
            [neetRemoveEnemySet addObject:enView];
        }
    }
    
    //Delete the enemys which are out of the view
    for (TBEnemyView *enView in neetRemoveEnemySet) {
        [enView removeFromSuperview];
        [self.enemyViewSet removeObject:enView];
    }
    
    [neetRemoveEnemySet removeAllObjects];
}

#pragma mark - check collision
- (void)checkCollision
{
    //check the collision between enemy and hero
    for (TBEnemyView *enemyView in self.enemyViewSet) {
        //check hero dead
        if (CGRectIntersectsRect(enemyView.frame, self.gameModel.hero.collisionFrame) && !enemyView.enemy.toBlowup && !self.gameModel.hero.isDead) {
            {   [self gameOver];
            
                self.gameModel.hero.isDead = YES;
            
                [self.heroView stopAnimating];
            
                [self.heroView setImage:self.imageManager.heroBlowupImages[0]];
            
                [self.heroView setAnimationImages:self.imageManager.heroBlowupImages];
            
                [self.heroView setAnimationDuration:1.0];
            
                [self.heroView setAnimationRepeatCount:1];
            
                [self.heroView stopAnimating];
            
                [self performSelector:@selector(stopGameTimer) withObject:nil afterDelay:1.0];
            
                [audioController stopIOUnit];
                //if(_musicOn) [audioController stopMySound];
            }
        }
        break;
    }
    
    if (steps % 10 == 0) {   //slow down the view
        NSMutableSet *removeEnemyViewSet = [NSMutableSet set];
        for (TBEnemyView *enemyView in self.enemyViewSet) {
            TBEnemy *enemy = enemyView.enemy;
            if (enemy.toBlowup) {
                [enemyView setImage:enemyView.blowupImages[enemy.blowupFrames++]];
               
            }
            if (enemy.blowupFrames == enemyView.blowupImages.count) {
                 [removeEnemyViewSet addObject:enemyView];
            }
        }
        
        //delete the enemy
        for (TBEnemyView *enemyView in removeEnemyViewSet) {
            self.gameModel.score += enemyView.enemy.score;
            [self updateScorel];
            [enemyView removeFromSuperview];
            [self.enemyViewSet removeObject:enemyView];
        }
        
        [removeEnemyViewSet removeAllObjects];
        
    }
    
    //check the collision between enemy and bullet
    for (TBBulletView *bulletView in self.bulletViewSet) {
        TBBullet *bullet = bulletView.bullet;
        for (TBEnemyView *enemyView in self.enemyViewSet) {
            TBEnemy *enemy = enemyView.enemy;
            
            //check the collision between enemy and bullet
            if (CGRectIntersectsRect(bulletView.frame, enemyView.frame) && !enemy.toBlowup && !self.gameModel.hero.isDead) {
                //decrease the enemy hp
                 enemy.hp -= bullet.damage;
                if (enemy.hp <= 0) {  //blowup enemy
                    enemy.toBlowup = YES;
                    
                } else {
                    
                    if (enemy.type == kEnemyBig) {  //stop animating
                        [enemyView stopAnimating];
                    }
                    enemyView.image = enemyView.hitImage;
                }
            }
        }
    }
    
}

- (void)gameOver
{

    NSInteger preScore = [[TBConst score] integerValue];
    if ([self.scoreLabel.text integerValue] > preScore) {
        [TBConst saveScore:[NSString stringWithFormat:@"%@", self.scoreLabel.text]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gameOverPojilu" object:nil userInfo:@{@"score":self.scoreLabel.text}];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game over" message:@"Game over" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.view removeFromSuperview];
    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - load background
- (void)loadBackImage
{
    self.backGroundView = [[TBBackGroundView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.backGroundView];
}


#pragma mark - load resource
- (void)loadResources
{
    self.imageManager = [TBImageManager shareManager];
    
}

#pragma mark - Start game clock
- (void)startGameTimer
{
    //init game clock
    self.gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameStep)];
    [self.gameTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.backGroundView startMove];
}

#pragma mark - Stop game clock
- (void)stopGameTimer
{
    [self.gameTimer invalidate];
    [self.backGroundView stopMove];
}
@end
