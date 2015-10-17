//
//  HoudiniAPI.cpp
//  Houdini
//
//  Created by Apple on 10/17/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#include "HoudiniAPI.h"
#include "Utils.h"

#define HOUDINI_API_HOST "http://houdini-mongo.cloudapp.net"

void HoudiniAPI::login(const std::string& username, const std::string& password, std::function<void(BOOL success, NSError* error)> onfinish)
{
	NSString* username_str = [NSString stringWithUTF8String:username.c_str()];
	NSString* password_str = [NSString stringWithUTF8String:password.c_str()];
	
	NSMutableDictionary* json_dict = [NSMutableDictionary dictionary];
	[json_dict setObject:username_str forKey:@"username"];
	[json_dict setObject:password_str forKey:@"password"];
	NSData* json_data = utils::json_serialize(json_dict);
	
	std::string login_url_str = HOUDINI_API_HOST "/login";
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:login_url_str.c_str()]]];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accepts"];
	[request setHTTPBody:json_data];
	
	utils::send_http_request(request, [onfinish](NSURLResponse* response, NSData* data, NSError* error){
		if(data!=nil)
		{
			NSString* data_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if([data_str isEqualToString:@"true"])
			{
				NSLog(@"login successful");
				onfinish(YES, nil);
			}
			else
			{
				NSLog(@"login failed");
				onfinish(NO, nil);
			}
		}
		else
		{
			NSLog(@"error sending login request");
			onfinish(NO, error);
		}
	});
}