
#ifndef Utils_hpp
#define Utils_hpp

#import <Foundation/Foundation.h>
#include <string>
#include <functional>

namespace utils
{
	std::string string_replaceall(const std::string& str, const std::string& find, const std::string& replace);
	NSData* json_serialize(NSDictionary* dict);
	void send_http_request(NSURLRequest* request, std::function<void(NSURLResponse* response, NSData* data, NSError* error)> onfinish);
}

#endif /* Utils_hpp */
