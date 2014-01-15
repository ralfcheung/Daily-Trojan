#import "FlickrFetcher.h"
#import "FlickrAPIKey.h"

#define FLICKR_PLACE_ID @"place_id"
#define FLICKR_ACCOUNT @"68624379@N05"

@implementation FlickrFetcher

+ (NSDictionary *)executeFlickrFetch:(NSString *)query
{
    query = [NSString stringWithFormat:@"%@&format=json&nojsoncallback=1&api_key=%@", query, FlickrAPIKey];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);

    return results;
}


+ (NSArray *)uscPhotos
{
    
    NSString* request = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?user_id=%@&format=json&nojsoncallback=1&extras=original_format,tags,description,geo,date_upload,owner_name&page=1&method=flickr.photos.search", FLICKR_ACCOUNT];

    return [[self executeFlickrFetch:request] valueForKeyPath:@"photos.photo"];

}

+ (NSArray *)photoEXIF:(NSString *)photoid{
    NSString *request = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getExif&photo_id=%@&format=json&nojsoncallback=1", photoid];

    return [[self executeFlickrFetch:request] valueForKeyPath:@"photo.exif"];

}

+ (void)urlString:(NSArray *)photo{
    for (NSDictionary *dict in photo) {
        if ([[dict objectForKey:@"label"] isEqualToString:@"Model"] || [[dict objectForKey:@"label"] isEqualToString:@"Exposure"] ||
            [[dict objectForKey:@"label"] isEqualToString:@"Aperture"] ||
            [[dict objectForKey:@"label"] isEqualToString:@"Focal Length"]) {
//            NSLog(@"%@", [[dict objectForKey:@"raw"] objectForKey:@"_content"]);
        }
    }
}

+ (NSString *)urlStringForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format
{
	id farm = [photo objectForKey:@"farm"];
	id server = [photo objectForKey:@"server"];
	id photo_id = [photo objectForKey:@"id"];
//    NSArray *a = [self photoEXIF:(NSString *)photo_id];
//    [self urlString:a];
    
	id secret = [photo objectForKey:@"secret"];
	if (format == FlickrPhotoFormatOriginal) secret = [photo objectForKey:@"originalsecret"];
    
	NSString *fileType = @"jpg";
	if (format == FlickrPhotoFormatOriginal) fileType = [photo objectForKey:@"originalformat"];
	
	if (!farm || !server || !photo_id || !secret) return nil;
	
	NSString *formatString = @"s";
	switch (format) {
		case FlickrPhotoFormatSquare:    formatString = @"s"; break;
		case FlickrPhotoFormatLarge:     formatString = @"b"; break;
        case FlickrPhotoFormatThumbnail: formatString = @"t"; break;
        case FlickrPhotoFormatSmall:     formatString = @"m"; break;
            // case FlickrPhotoFormatMedium500: formatString = @"-"; break;
            // case FlickrPhotoFormatMedium640: formatString = @"z"; break;
		case FlickrPhotoFormatOriginal:  formatString = @"o"; break;
	}
	return [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_%@.%@", farm, server, photo_id, secret, formatString, fileType];
}

+ (NSURL *)urlForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format
{
    return [NSURL URLWithString:[self urlStringForPhoto:photo format:format]];
}

@end
