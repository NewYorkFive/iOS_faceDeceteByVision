//
//  ViewController.m
//  faceVisionOC
//
//  Created by DoubleL on 2019/3/20.
//  Copyright © 2019 DoubleL. All rights reserved.
//

#import "ViewController.h"
#import "FaceDetector.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _imageView.backgroundColor = [UIColor colorWithRed: 1 / 255.0 green: 150 / 255.0 blue: 1  alpha: 1];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    self.selectedImage = [UIImage imageNamed:@"tim"];
    
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [testBtn addTarget:self action:@selector(selectImageBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    testBtn.center = self.view.center;
}

- (void)setSelectedImage:(UIImage *)selectedImage{
    self.imageView.image = selectedImage;
    FaceDetector *detector = [[FaceDetector alloc] init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [detector highlightFaces:selectedImage resultBlock:^(UIImage * _Nonnull resultImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = resultImage;
            });
        }];
    });
}


- (void)selectImageBtnAction{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pickerController animated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [self dismissViewControllerAnimated:true completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.selectedImage = image;
    }else{
        NSLog(@"error");
    }
}


@end
