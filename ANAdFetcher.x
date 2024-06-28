// https://github.com/appnexus/mobile-sdk-ios/blob/master/sdk/sourcefiles/internal/ANAdFetcher.h
%hook ANAdFetcher

- (instancetype)initWithDelegate:(id)delegate {
    return nil;
}

%end
