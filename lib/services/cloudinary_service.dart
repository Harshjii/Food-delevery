import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "qxpis6vk";
  static const String uploadPreset = "zyvo_preset";

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['secure_url']; // CDN direct public URL
      } else {
        print("Cloudinary Error: $responseBody");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}