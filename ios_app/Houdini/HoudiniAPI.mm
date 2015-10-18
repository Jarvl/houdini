
#include "HoudiniAPI.h"
#include "Utils.h"

#define HOUDINI_API_HOST "http://houdini-mongo.cloudapp.net"

std::string HoudiniAPI::deviceToken = "";

void HoudiniAPI::login(const std::string& username, const std::string& password, std::function<void(bool, NSError*)> onfinish)
{
	NSString* username_str = [NSString stringWithUTF8String:username.c_str()];
	NSString* password_str = [NSString stringWithUTF8String:password.c_str()];
	
	NSMutableDictionary* json_dict = [NSMutableDictionary dictionary];
	[json_dict setObject:username_str forKey:@"username"];
	[json_dict setObject:password_str forKey:@"password"];
	NSData* json_data = utils::json_serialize(json_dict);
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:HOUDINI_API_HOST "/login"]]];
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
				if(onfinish)
				{
					onfinish(true, nil);
				}
			}
			else
			{
				NSLog(@"login failed");
				if(onfinish)
				{
					onfinish(false, nil);
				}
			}
		}
		else
		{
			NSLog(@"error sending login request");
			if(onfinish)
			{
				onfinish(false, error);
			}
		}
	});
}

void HoudiniAPI::signup(const std::string& username, const std::string& password, const std::string& first_name, const std::string& last_name, std::function<void(bool, const std::string&, const std::string&, NSError* error)> onfinish)
{
	NSMutableDictionary* json_dict = [NSMutableDictionary dictionary];
	[json_dict setObject:[NSString stringWithUTF8String:username.c_str()] forKey:@"username"];
	[json_dict setObject:[NSString stringWithUTF8String:password.c_str()] forKey:@"password"];
	[json_dict setObject:[NSString stringWithUTF8String:first_name.c_str()] forKey:@"firstName"];
	[json_dict setObject:[NSString stringWithUTF8String:last_name.c_str()] forKey:@"lastName"];
	NSData* json_data = utils::json_serialize(json_dict);
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:HOUDINI_API_HOST "/signup"]]];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accepts"];
	[request setHTTPBody:json_data];
	
	utils::send_http_request(request, [onfinish](NSURLResponse* response, NSData* data, NSError* error){
		if(data!=nil)
		{
			NSDictionary* data_dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
			BOOL success = [[data_dict objectForKey:@"success"] boolValue];
			NSString* url = [data_dict objectForKey:@"url"];
			NSString* errorMessage = [data_dict objectForKey:@"errorMessage"];
			if(success)
			{
				NSLog(@"signup successful");
				if(onfinish)
				{
					onfinish((bool)success, [url UTF8String], "", error);
				}
			}
			else
			{
				if(errorMessage!=nil)
				{
					NSLog(@"signup error %@", errorMessage);
				}
				else
				{
					NSLog(@"signup error");
				}
				
				std::string error_desc;
				if(errorMessage!=nil)
				{
					error_desc = [errorMessage UTF8String];
				}
				
				if(onfinish)
				{
					onfinish((bool)success, "", error_desc, error);
				}
			}
		}
		else
		{
			NSLog(@"error sending signup request");
			if(onfinish)
			{
				onfinish(false, "", "", error);
			}
		}
	});
}

void HoudiniAPI::isLoggedIn(std::function<void(bool logged_in, NSError* error)> onfinish)
{
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:HOUDINI_API_HOST "/api/isLoggedIn"]]];
	[request setHTTPMethod:@"GET"];
	
	utils::send_http_request(request, [onfinish](NSURLResponse* response, NSData* data, NSError* error){
		if(data!=nil)
		{
			NSString* data_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if([data_str isEqualToString:@"true"])
			{
				if(onfinish)
				{
					onfinish(true, error);
				}
			}
			else
			{
				if(onfinish)
				{
					onfinish(false, error);
				}
			}
		}
		else
		{
			if(onfinish)
			{
				onfinish(false, error);
			}
		}
	});
}

void HoudiniAPI::requestPhoneCall(const std::string& phone_number, std::function<void(bool, NSError*)> onfinish)
{
	NSString* phone_number_str = [NSString stringWithUTF8String:phone_number.c_str()];
	
	NSMutableDictionary* json_dict = [NSMutableDictionary dictionary];
	[json_dict setObject:phone_number_str forKey:@"phoneNumber"];
	NSData* json_data = utils::json_serialize(json_dict);
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:HOUDINI_API_HOST "/api/requestPhoneCall"]]];
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
				NSLog(@"phone call request successful");
				if(onfinish)
				{
					onfinish(true, nil);
				}
			}
			else
			{
				NSLog(@"phone call request failed");
				if(onfinish)
				{
					onfinish(false, nil);
				}
			}
		}
		else
		{
			NSLog(@"error sending phone call request");
			if(onfinish)
			{
				onfinish(false, error);
			}
		}
	});
}

void HoudiniAPI::setAvailable(bool available, std::function<void(NSError*)> onfinish)
{
	NSNumber* value = [NSNumber numberWithBool:(BOOL)available];
	
	NSMutableDictionary* json_dict = [NSMutableDictionary dictionary];
	[json_dict setObject:value forKey:@"available"];
	[json_dict setObject:[NSString stringWithUTF8String:deviceToken.c_str()] forKey:@"deviceToken"];
	NSData* json_data = utils::json_serialize(json_dict);
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:HOUDINI_API_HOST "/api/setAvailable"]]];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accepts"];
	[request setHTTPBody:json_data];
	
	utils::send_http_request(request, [onfinish](NSURLResponse* response, NSData* data, NSError* error){
		if(onfinish)
		{
			onfinish(error);
		}
	});
}

void HoudiniAPI::isAvailable(std::function<void(bool, NSError*)> onfinish)
{
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:HOUDINI_API_HOST "/api/isAvailable"]]];
	[request setHTTPMethod:@"GET"];
	
	utils::send_http_request(request, [onfinish](NSURLResponse* response, NSData* data, NSError* error){
		if(error!=nil)
		{
			if(onfinish)
			{
				onfinish(false, error);
			}
		}
		else
		{
			NSString* data_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			bool available = false;
			if([data_str isEqualToString:@"true"])
			{
				available = true;
			}
			if(onfinish)
			{
				onfinish(available, nil);
			}
		}
	});
}

std::string HoudiniAPI::getSiteURL()
{
	return HOUDINI_API_HOST;
}

void HoudiniAPI::setDeviceToken(const std::string& token)
{
	deviceToken = token;
}
