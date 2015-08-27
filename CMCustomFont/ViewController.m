//
//  ViewController.m
//  CMCustomFont
//
//  Created by CMBaiDu on 15/8/26.
//  Copyright (c) 2015年 CMBaiDu. All rights reserved.
//

#import "ViewController.h"
#import "UIFont+CMCustom.h"

@import CoreText;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *pacifico;

@property (weak, nonatomic) IBOutlet UILabel *windsong;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.pacifico setFont:[UIFont pacificoFontWithSize:self.pacifico.font.pointSize]];
    
    [self.windsong setFont:[UIFont windsongFontWithSize:self.windsong.font.pointSize]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
