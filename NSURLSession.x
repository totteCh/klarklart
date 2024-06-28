#import <Foundation/Foundation.h>

%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    void (^interceptedCompletionHandler)(NSData *, NSURLResponse *, NSError *) = nil;
    if (![url.absoluteString hasPrefix:@"https://api.klart.se"]) {
        return %orig;
    }

    if ([url.absoluteString hasPrefix:@"https://api.klart.se/v2/calendarsponsors"] || [url.absoluteString hasPrefix:@"https://api.klart.se/v2/sponsors"]) {
        // Return empty array
        interceptedCompletionHandler = ^void(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *payload = @{
                @"_metadata": @{
                    @"totalCount": @0
                },
                @"items": @[]
            };
            data = [NSJSONSerialization dataWithJSONObject:payload options:kNilOptions error:&error];
            completionHandler(data, response, error);
        };
    } else if ([url.absoluteString isEqualToString:@"https://api.klart.se/v2/config/ios"]) {
        // Remove ads in payload
        interceptedCompletionHandler = ^void(NSData *data, NSURLResponse *response, NSError *error) {
            if (!data || error) {
                return completionHandler(data, response, error);
            }

            NSError *jsonError;
            NSMutableDictionary *payload = [[NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:&jsonError] mutableCopy];
            if (jsonError || ![payload isKindOfClass:[NSDictionary class]]) {
                return completionHandler(data, response, error);
            }

            NSArray *items = payload[@"items"];
            if (![items isKindOfClass:[NSArray class]]) {
                return completionHandler(data, response, error);
            }

            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                    // Remove the ads key
                    [obj removeObjectForKey:@"ads"];

                    // Remove the appnexusMemberID key from settings
                    NSMutableDictionary *settings = [obj[@"settings"] mutableCopy];
                    if ([settings isKindOfClass:[NSDictionary class]]) {
                        [settings removeObjectForKey:@"appnexusMemberID"];
                        obj[@"settings"] = settings;
                    }
                }
            }];

            // Convert the modified payload back to NSData
            data = [NSJSONSerialization dataWithJSONObject:payload options:kNilOptions error:&jsonError];
            completionHandler(data, response, error);
        };
    }

    if (interceptedCompletionHandler) {
        return %orig(url, interceptedCompletionHandler);
    }
    return %orig;
}

%end
