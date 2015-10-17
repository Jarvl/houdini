//
//  Utils.cpp
//  Houdini
//
//  Created by Apple on 10/17/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#include "Utils.h"

namespace utils
{
	std::string string_replaceall(const std::string& str, const std::string& find, const std::string& replace)
	{
		std::string str_new = str;
		std::string::size_type n = 0;
		while ((n=str_new.find(find, n)) != std::string::npos)
		{
			str_new.replace(n, str_new.length(), replace);
			n += replace.size();
		}
		return str_new;
	}
	
	NSData* json_serialize(NSDictionary* dict)
	{
		return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
	}
	
	void send_http_request(NSURLRequest* request, std::function<void(NSURLResponse* response, NSData* data, NSError* error)> onfinish)
	{
		[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
			onfinish(response, data, connectionError);
		}];
	}
}
