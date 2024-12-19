import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  late final nodeUrl;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    final nodeHost = dotenv.get("NODE_HOST");
    final nodePort = dotenv.get("NODE_PORT");
    nodeUrl = 'http://$nodeHost:$nodePort';
  }
  // GET /my-image
  Future<String> fetchData() async {
    final response = await http.get(Uri.parse('$nodeUrl/my-image'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body); // Parsing in JSON foramt
      return data['message']; // return 'message'
    } else {
      throw Exception('Failed to load data');
    }
  }

  // POST /auth/join
  Future<String> signup({
    required String email,
    required String password,
    required String phoneNumber,
    required String name,
    required String gender,
    required String nickname,
    String? profilePhoto,
    String? address,
    String? payment,
  }) async {
    final url = Uri.parse('$nodeUrl/auth/join');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'name': name,
      'gender': gender,
      'nick': nickname,
      'profile_photo': profilePhoto ?? "/public/default_image.png",
      'address': address,
      'payment': payment,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: 'jwt_token', value: responseBody['token']);
        print(responseBody['token']);
        return 'Signup successful!';
      } else {

        return 'Successfully: ${responseBody['message']}';
      }
    } catch (e) {
      return 'Error: Could not connect to server';
    }
  }

  Future<Map<String, dynamic>> sendLoginRequest(String email, String password) async {
    final url = Uri.parse('$nodeUrl/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = {'email': email, 'password': password};

    try {
      final response = await http.post(url, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['token'] != null) {
          await _storage.write(key: 'jwt_token', value: responseBody['token']);
        }

        print(responseBody);

        return {
          'status':true,
          'message':'Login successful!'};
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          'status': false, // 요청 성공 여부
          'message': 'Error: ${responseBody['message']}' // 메시지
        };
      }
    } catch (e) {

      return {
        'status': false, // 요청 성공 여부
        'message': 'Error: Could not connect to server', // 메시지
      };
    }
  }


  Future<bool> uploadImage({
    required File image,
    required String clothingName,
    required int rating,
    required List<String> clothingTypes, // 다중 선택
    required List<String> clothingStyles, // 다중 선택
    required String memo,
    required Offset includePoint, // 추가된 포함 좌표
    required Offset excludePoint, // 추가된 제외 좌표
  }) async {
    try {
      // JWT 토큰 읽기
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // JWT에서 이메일 추출 (옵션)
      final userId = await _getUserIdFromJwt(token);

      // 이미지를 Base64로 인코딩
      String base64Image = base64Encode(await image.readAsBytesSync());

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // JWT 인증 헤더 추가
      };
      // JSON 데이터 생성
      final body = jsonEncode({
        'userId' : userId,
        'base64Image': base64Image,
        'clothingName' : clothingName,
        'rating' : rating,
        'clothingType' : clothingTypes,
        'clothingStyle' : clothingStyles,
        'imageMemo' : memo,
        'includePoint': {'x': includePoint.dx, 'y': includePoint.dy}, // 포함 좌표
        'excludePoint': {'x': excludePoint.dx, 'y': excludePoint.dy}, // 제외 좌표
      });



      // 요청 전송
      final response = await http.post(
        Uri.parse('$nodeUrl/clothes/upload_image'),
        headers: headers,
        body: body,
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("${responseBody['message']}");
        return true;
      } else {
        // 실패한 경우 응답 로그
        print("Failed to upload. Status code: ${response.statusCode}");
        try {
          final responseBody = jsonDecode(response.body);
          print("Error message: ${responseBody['message']}");
        } catch (e) {
          print("Error decoding response: $e");
        }
        return false;
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 에러 처리
      print("Error occurred while uploading: $e");
      return false;
    }
  }

  Future<List<dynamic>?> getClothesInfo() async {
   try{
     final token = await _storage.read(key: 'jwt_token');

     if (token == null) {
       throw Exception('User not authenticated');
     }

     final userId = await _getUserIdFromJwt(token);

     final headers = {
       'Content-Type': 'application/json',
       'Authorization': 'Bearer $token', // JWT 인증 헤더 추가
     };

     final body = jsonEncode({
       'userId' : userId,
     });
     final response = await http.post(
       Uri.parse('$nodeUrl/clothes/info'),
       headers: headers,
       body: body,
     );
     final responseBody = jsonDecode(response.body);
     if(response.statusCode == 200) {
       print(responseBody["clothes"].runtimeType);
       return responseBody["clothes"];
     } else {
       try {
         print("Error message: ${responseBody['message']}");
       } catch (e) {
         print("Error decoding response: $e");
       }
       return null;
     }
   }catch (e) {
     return null;
   }
  }

  Future<String> getAiFitting({
    required File personImage,
    required String clothingImageName,
  }) async {

    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('User not authenticated');
      }
      final userId = await _getUserIdFromJwt(token);
      String base64Image = base64Encode(await personImage.readAsBytesSync());

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // JWT 인증 헤더 추가
      };

      final body = jsonEncode({
        'cloth_image_name' : clothingImageName,
        'person_base64_image': base64Image,
        'userId' : userId,
      });

      final response = await http.post(
        Uri.parse('$nodeUrl/clothes/virtual_fitting'),
        headers: headers,
        body: body,
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("${responseBody['message']}");
        return responseBody['base64_image'];
      } else {
        print("Failed to AiFit. Status code: ${response.statusCode}");
        return "";
      }

    } catch(e){
      print("error");
      return "";
    }
  }
// JWT 디코딩 및 유저 ID 추출
  Future <int> _getUserIdFromJwt(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT');
      }

      // JWT의 payload 부분 디코딩
      final payload = jsonDecode(
        utf8.decode(
          base64Url.decode(
            base64Url.normalize(parts[1]),
          ),
        ),
      );

      // 'user_id' 필드 반환
      return payload['user_id'];
    } catch (e) {
      print('Error decoding JWT: $e');
      return 0;
    }
  }

  Future<bool> SaleClothes({
    required int clothesId,
    required String postName,
    required List<String> saleType, // 다중 선택
    required int price,
    required String bankAccount,
  }) async {
    try {
      // JWT 토큰 읽기
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // JWT에서 이메일 추출 (옵션)
      final userId = await _getUserIdFromJwt(token);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // JWT 인증 헤더 추가
      };
      // JSON 데이터 생성
      final body = jsonEncode({
        'clothes_id' : clothesId,
        'post_name' : postName,
        'sale_type' : saleType,
        'price' : price,
        'bank_account' : bankAccount,
        'userId' : userId,
      });

      // 요청 전송
      final response = await http.post(
        Uri.parse('$nodeUrl/market/sale'),
        headers: headers,
        body: body,
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("${responseBody['message']}");
        return true;
      } else {
        // 실패한 경우 응답 로그
        print("Failed to upload. Status code: ${response.statusCode}");
        try {
          final responseBody = jsonDecode(response.body);
          print("Error message: ${responseBody['message']}");
        } catch (e) {
          print("Error decoding response: $e");
        }
        return false;
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 에러 처리
      print("Error occurred while uploading: $e");
      return false;
    }
  }

  Future<List<dynamic>?> getMarketPlaceInfo() async {
    try{
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final userId = await _getUserIdFromJwt(token);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // JWT 인증 헤더 추가
      };

      final body = jsonEncode({
        'userId' : userId,
      });
      final response = await http.post(
        Uri.parse('$nodeUrl/market/info'),
        headers: headers,
        body: body,
      );
      final responseBody = jsonDecode(response.body);
      if(response.statusCode == 200) {
        print(responseBody["clothes"].runtimeType);
        return responseBody["clothes"];
      } else {
        try {
          print("Error message: ${responseBody['message']}");
        } catch (e) {
          print("Error decoding response: $e");
        }
        return null;
      }
    }catch (e) {
      return null;
    }

  }

  Future<bool> uploadWishList({
    required int clothesId
  }) async {
    try {
      // JWT 토큰 읽기
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // JWT에서 이메일 추출 (옵션)
      final userId = await _getUserIdFromJwt(token);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // JWT 인증 헤더 추가
      };
      // JSON 데이터 생성
      final body = jsonEncode({
        'userId' : userId,
        'clothes_id' : clothesId,
      });

      // 요청 전송
      final response = await http.post(
        Uri.parse('$nodeUrl/wishlist/add'),
        headers: headers,
        body: body,
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("${responseBody['message']}");
        return true;
      } else {
        // 실패한 경우 응답 로그
        print("Failed to upload. Status code: ${response.statusCode}");
        try {
          final responseBody = jsonDecode(response.body);
          print("Error message: ${responseBody['message']}");
        } catch (e) {
          print("Error decoding response: $e");
        }
        return false;
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 에러 처리
      print("Error occurred while uploading: $e");
      return false;
    }
  }

  Future<List<dynamic>?> getWishListInfo() async {
    try{
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final userId = await _getUserIdFromJwt(token);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // JWT 인증 헤더 추가
      };

      final body = jsonEncode({
        'userId' : userId,
      });
      final response = await http.post(
        Uri.parse('$nodeUrl/wishlist/info'),
        headers: headers,
        body: body,
      );
      final responseBody = jsonDecode(response.body);
      if(response.statusCode == 200) {
        print(responseBody["clothes"].runtimeType);
        return responseBody["clothes"];
      } else {
        try {
          print("Error message: ${responseBody['message']}");
        } catch (e) {
          print("Error decoding response: $e");
        }
        return null;
      }
    }catch (e) {
      return null;
    }

  }

  Future<bool> purchaseClothes({
    required int clothesId
  }) async {
    try {
      // JWT 토큰 읽기
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // JWT에서 이메일 추출 (옵션)
      final userId = await _getUserIdFromJwt(token);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // JWT 인증 헤더 추가
      };
      // JSON 데이터 생성
      final body = jsonEncode({
        'userId' : userId,
        'clothes_id' : clothesId,
      });

      // 요청 전송
      final response = await http.post(
        Uri.parse('$nodeUrl/market/purchase'),
        headers: headers,
        body: body,
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("${responseBody['message']}");
        return true;
      } else {
        // 실패한 경우 응답 로그
        print("Failed to upload. Status code: ${response.statusCode}");
        try {
          final responseBody = jsonDecode(response.body);
          print("Error message: ${responseBody['message']}");
        } catch (e) {
          print("Error decoding response: $e");
        }
        return false;
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 에러 처리
      print("Error occurred while buying: $e");
      return false;
    }
  }
}