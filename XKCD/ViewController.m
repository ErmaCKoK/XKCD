//
//  ViewController.m
//  XKCD
//
//  Created by Andrii Kurshyn on 9/23/14.
//  Copyright (c) 2014 Inamana. All rights reserved.
//

#import "ViewController.h"
#import "XKComicsManager.h"
#import "XKComic.h"

@interface ViewController ()
{
    BOOL _isAnimation;
    
    NSNumber *_lastComicID;
    XKComic *_currentComic;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *comicImageView;
@property (weak, nonatomic) IBOutlet UITextView *translateTextView;

@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _isAnimation = NO;
    
    
    [[XKComicsManager sharedManager] getCurrentComic:^(XKComic *comic){
        _lastComicID = comic.comicID;
        [self updateComic:comic];
    } failure:^(NSError *error){
        NSLog(@"Commic error donwload: %@",error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateComic:(XKComic*)comic
{
    self.titleLabel.text = comic.title;
    self.translateTextView.text = comic.translate;
    
    if ([comic.translate isEqualToString:@""] || comic.translate == nil) {
        self.translateTextView.text = comic.transcript;
    }
    
    _currentComic = comic;
    [self downloadImage:comic.imageURL];
    
    _nextButton.hidden = NO;
    _prevButton.hidden = NO;
    
    if ([_lastComicID isEqualToNumber:comic.comicID]) {
        _nextButton.hidden = YES;
    }
    
    if ([comic.comicID integerValue] <= 0) {
        _prevButton.hidden = YES;
    }
}

- (void)downloadImage:(NSURL*)urlImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //    UIImage *image = [self imageWithData:data size:size];
        NSData *data = [NSData dataWithContentsOfURL:urlImage];
        
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (image) {
                
                _comicImageView.image = image;
                
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3f;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                
                [_comicImageView.layer addAnimation:transition forKey:nil];
                
            } else {
                _comicImageView.image = image;
            }
            
        });
        
    });
}

- (IBAction)downloadComic:(UIButton*)sender
{
    NSNumber *comicID  = nil;
    
    if (sender == self.prevButton) {
        comicID = @([_currentComic.comicID integerValue]-1);
    } else if (sender == self.nextButton && ![_lastComicID isEqualToNumber:_currentComic.comicID]) {
        comicID = @([_currentComic.comicID integerValue]+1);
    }
    
    [[XKComicsManager sharedManager] getComicWithID:comicID
                                            success:^(XKComic *comic){
                                                [self updateComic:comic];
                                            } failure:^(NSError *error){
                                                NSLog(@"Commic error donwload: %@",error);
                                            }];
}

- (IBAction)showTextView:(id)sender
{
    if ( _isAnimation) {
        return;
    }
    
    if ([_translateTextView.text isEqualToString:@""] || _translateTextView.text == nil) {
        return;
    }
    
    _isAnimation = YES;
    
    BOOL isShow = _translateTextView.hidden;
    
    if (isShow) {
        _translateTextView.hidden = NO;
        _translateTextView.alpha = 0.0;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _translateTextView.alpha = isShow ? 1.0f : 0.0f;
    } completion:^(BOOL finished){
        if (!isShow) {
            _translateTextView.hidden = YES;
        }
        
        _isAnimation = NO;
    }];
}

@end
