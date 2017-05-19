//
//  ViewController.m
//  llap
//
//  Created by Ke Sun on 5/18/17.
//  Copyright © 2016 Nanjing University. All rights reserved.
//

#import "ViewController.h"
#import "AudioController.h"

@interface ViewController (){
    AudioController *audioController;
}

@property (weak, nonatomic) IBOutlet UISlider *slider;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    audioController = [[AudioController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performDisUpdate:) name:@"AudioDisUpdate" object:nil];
    [_slider setValue: 0.0];
    [self.view addSubview: _slider];
}
- (IBAction)playbutton:(UIButton *)sender {
    audioController.audiodistance=0;
    [audioController startIOUnit];
    
}
- (IBAction)stopbutton:(UIButton *)sender {
    [audioController stopIOUnit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performDisUpdate:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
    int tempdis=(int) audioController.audiodistance/DISPLAY_SCALE;
        
     _slider.value=(audioController.audiodistance-DISPLAY_SCALE*tempdis)/DISPLAY_SCALE;
    }
        );

}

@end
