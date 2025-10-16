import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';  // AGP 8.x compatibility issue
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../presentation/widgets/social_share_bottom_sheet.dart';
import 'package:fortune/core/theme/toss_design_system.dart';

class TalismanShareService {
  // Add watermark to the talisman image
  Future<Uint8List> addWatermark(Uint8List imageData) async {
    try {
      // Decode the image
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Create a canvas to draw on
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Draw the original image
      canvas.drawImage(image, Offset.zero, Paint());
      
      // Add watermark text
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Fortune App',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TossDesignSystem.white.withValues(alpha: 0.8)),
        textDirection: TextDirection.ltr);
      textPainter.layout();
      
      // Position watermark at bottom right
      final watermarkPosition = Offset(
        image.width - textPainter.width - 20,
        image.height - textPainter.height - 20
      );
      textPainter.paint(canvas, watermarkPosition);
      
      // Add date
      final datePainter = TextPainter(
        text: TextSpan(
          text: DateTime.now().toString().split(' '),
          style: TextStyle(
            fontSize: 14,
            color: TossDesignSystem.white.withValues(alpha: 0.6)),
        textDirection: TextDirection.ltr);
      datePainter.layout();
      
      final datePosition = Offset(
        20,
        image.height - datePainter.height - 20
      );
      datePainter.paint(canvas, datePosition);
      
      // Convert to image
      final picture = recorder.endRecording();
      final newImage = await picture.toImage(image.width, image.height);
      final byteData = await newImage.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Fortune cached');
      return imageData; // Return original if watermarking fails
    }
  }
  
  // Share talisman to different platforms
  Future<void> shareTalisman({
    required Uint8List imageData,
    required SharePlatform platform,
    required String talismanType,
    required String userName}) async {
    try {
      switch (platform) {
        case SharePlatform.kakaoTalk:
          await _shareToKakao(imageData, talismanType, userName);
          break;
        case SharePlatform.instagram:
          await _shareToInstagram(imageData, talismanType);
          break;
        case SharePlatform.facebook:
          await _shareToFacebook(imageData, talismanType);
          break;
        case SharePlatform.twitter:
          await _shareToTwitter(imageData, talismanType);
          break;
        case SharePlatform.whatsapp:
          await _shareToWhatsApp(imageData, talismanType);
          break;
        case SharePlatform.gallery:
          await saveToGallery(imageData);
          break;
        case SharePlatform.copy:
          await _copyText(talismanType, userName);
          break;
        case SharePlatform.other:
          await _shareGeneric(imageData, talismanType);
          break;
      }
    } catch (e) {
      debugPrint('Fortune cached');
      rethrow;
    }
  }
  
  // Save to gallery
  Future<void> saveToGallery(Uint8List imageData) async {
    try {
      // Request permission
      final status = await Permission.storage.request();
      if (!status.isGranted && !Platform.isIOS) {
        throw Exception('Storage permission denied');
      }
      
      // Save image - Temporarily disabled due to AGP 8.x compatibility issue
      // final result = await ImageGallerySaver.saveImage(
      //   imageData,
      //   quality: 100,
      //   name: 'talisman_${DateTime.now().millisecondsSinceEpoch}'
      // );
      
      // if (result['isSuccess'] != true) {
      //   throw Exception('Failed to save image');
      // }
      
      // Temporary workaround: Save to app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/talisman_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageData);
    } catch (e) {
      debugPrint('Fortune cached');
      rethrow;
    }
  }
  
  // Share to KakaoTalk
  Future<void> _shareToKakao(Uint8List imageData, String type, String userName) async {
    // Save image temporarily
    final tempFile = await _saveImageToTemp(imageData);
    
    // Share using share_plus
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      text: '$userName님의 $type이 완성되었습니다! 🎯\n\n#부적 #운세 #FortuneApp'
    );
    
    // Clean up
    await tempFile.delete();
  }
  
  // Share to Instagram
  Future<void> _shareToInstagram(Uint8List imageData, String type) async {
    final tempFile = await _saveImageToTemp(imageData);
    
    // Instagram requires saving to gallery first on iOS
    if (Platform.isIOS) {
      await saveToGallery(imageData);
      
      // Open Instagram
      final url = Uri.parse('instagram://library');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } else {
      // Android can share directly
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: '오늘의 $type 🎯\n\n#부적 #운세 #행운 #FortuneApp'
      );
    }
    
    await tempFile.delete();
  }
  
  // Share to Facebook
  Future<void> _shareToFacebook(Uint8List imageData, String type) async {
    final tempFile = await _saveImageToTemp(imageData);
    
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      text: '나만의 $type을 만들었어요! 🎯\n\n#부적 #운세 #FortuneApp'
    );
    
    await tempFile.delete();
  }
  
  // Share to Twitter/X
  Future<void> _shareToTwitter(Uint8List imageData, String type) async {
    final tempFile = await _saveImageToTemp(imageData);
    
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      text: '나만의 $type 완성! 🎯\n\n#부적 #운세 #FortuneApp #행운'
    );
    
    await tempFile.delete();
  }
  
  // Share to WhatsApp
  Future<void> _shareToWhatsApp(Uint8List imageData, String type) async {
    final tempFile = await _saveImageToTemp(imageData);
    
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      text: '오늘의 $type입니다 🎯'
    );
    
    await tempFile.delete();
  }
  
  // Copy text to clipboard
  Future<void> _copyText(String type, String userName) async {
    final text = '$userName님의 $type이 완성되었습니다!\n\n'
        '이 부적은 당신의 소원을 이루어주고 행운을 가져다 줄 것입니다. 🎯\n\n'
        'Fortune App에서 나만의 부적을 만들어보세요!';
    
    await Clipboard.setData(ClipboardData(text: text));
  }
  
  // Generic share
  Future<void> _shareGeneric(Uint8List imageData, String type) async {
    final tempFile = await _saveImageToTemp(imageData);
    
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      text: '나만의 $type을 만들었어요! 🎯\n\nFortune App에서 당신만의 부적을 만들어보세요!'
    );
    
    await tempFile.delete();
  }
  
  // Save image to temporary directory
  Future<File> _saveImageToTemp(Uint8List imageData) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/talisman_${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(imageData);
    return tempFile;
  }
}