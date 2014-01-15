//
//  PhotoCollectionViewController.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 8/25/13.
//
//

#import "PhotoCollectionViewController.h"
#import "FlickrFetcher.h"
#import "FlickrAlbumCollectionViewCell.h"
#import "UIImage+Resize.h"
#import "RFQuiltLayout.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface PhotoCollectionViewController ()
@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, retain) NSArray *photoDict;
@property (nonatomic, strong) NSMutableArray *photos;
@end

@implementation PhotoCollectionViewController
@synthesize photoCollectionView;
@synthesize photoDict;
@synthesize photos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    photoDict = [FlickrFetcher uscPhotos];

//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    RFQuiltLayout *layout = [[RFQuiltLayout alloc] init];
    layout.delegate = self;
    photoCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [photoCollectionView setDataSource:self];
    [photoCollectionView setDelegate:self];
//    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake(50, 50);
    
//    layout.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5);
//    layout.minimumInteritemSpacing = 0.0;
//    layout.minimumLineSpacing = 0.0;
    [photoCollectionView registerClass:[FlickrAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [photoCollectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:photoCollectionView];
    photos = [[NSMutableArray alloc] init];
    [self downloadThumbsFromFlickr:^(NSMutableArray *results) {
        //        photos = results;
        
    }];

    
}
- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 10 == 0)
        return CGSizeMake(3, 1);
    if (indexPath.row % 11 == 0)
        return CGSizeMake(2, 1);
    else if (indexPath.row % 7 == 0)
        return CGSizeMake(1, 3);
    else if (indexPath.row % 8 == 0)
        return CGSizeMake(1, 2);
    else if(indexPath.row % 11 == 0)
        return CGSizeMake(2, 2);
//    if (indexPath.row == 0) return CGSizeMake(5, 5);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [photos count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FlickrAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];

    NSLog(@"%f %f", cell.frame.size.height, cell.frame.size.width);
    if (photos[indexPath.row] != nil) {
        UIImage* image = ((FlickrPhoto*)[photos objectAtIndex:indexPath.row]).thumbnail;
        cell.imageView.image = image;
        if (cell.frame.size.height > cell.frame.size.width) {
            cell.imageView.image = [image resizedImageByHeight:cell.frame.size.height * 20];
        }else cell.imageView.image = [image resizedImageByHeight:cell.frame.size.width * 20];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }

    
    cell.backgroundColor = [UIColor grayColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSLog(@"%@", ((FlickrPhoto *)[photos objectAtIndex:indexPath.row]).url);
    
}



-(void) downloadThumbsFromFlickr: (FlickrSearchCompletionBlock)completionBlock{
    dispatch_queue_t downloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(downloadQueue, ^{
        for (NSDictionary *dict in photoDict) {
            NSURL *url = [FlickrFetcher urlForPhoto:dict format:FlickrPhotoFormatLarge];
            NSData *data = [NSData dataWithContentsOfURL:url];
            FlickrPhoto *photo = [[FlickrPhoto alloc] init];
            photo.url = [url absoluteString];
            photo.thumbnail = [UIImage imageWithData:data];
            [photos addObject:photo];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.photoCollectionView reloadData];
//                NSLog(@"%i", [photos count]);
            });

            if([photos count] == 50)
                break;
        }

        completionBlock(nil);
    });

}

-(void) viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}


- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
